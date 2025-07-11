require 'rails_helper'

RSpec.describe "Templates API", type: :request do
  describe "GET /templates" do
    before do
      create_list(:template_with_questions, 3, questions_count: 2)
    end
    
    it "retorna todos os templates" do
      get "/templates"
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)
    end
    
    it "inclui questões nos templates" do
      get "/templates"
      json_response = JSON.parse(response.body)
      expect(json_response.first['questoes'].length).to eq(2)
    end
  end
  
  describe "GET /templates/:id" do
    let(:template) { create(:template_with_questions) }
    
    it "retorna o template específico" do
      get "/templates/#{template.id}"
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(template.id)
    end
    
    it "retorna erro 404 para template inexistente" do
      get "/templates/99999"
      expect(response).to have_http_status(404)
    end
  end
  
  describe "POST /templates" do
    let(:admin) { create(:admin) }
    let(:formulario) { create(:formulario) }
    
    it "cria um novo template" do
      expect {
        post "/templates", params: { 
          template: { content: "Novo template", admin_id: admin.id } 
        }
      }.to change(Template, :count).by(1)
      
      expect(response).to have_http_status(201)
    end
    
    it "cria um template com questões aninhadas" do
      expect {
        post "/templates", params: { 
          template: { 
            content: "Template com questões aninhadas", 
            admin_id: admin.id,
            questoes_attributes: [
              { enunciado: "Questão aninhada 1" },
              { enunciado: "Questão aninhada 2" }
            ]
          } 
        }
      }.to change(Questao, :count).by(2)
      
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response['questoes'].length).to eq(2)
    end
    
    it "cria um template com questões em array separado" do
      expect {
        post "/templates", params: { 
          template: { 
            content: "Template com questões em array", 
            admin_id: admin.id
          },
          questoes: [
            { enunciado: "Questão array 1" },
            { enunciado: "Questão array 2", formularios_id: formulario.id }
          ]
        }
      }.to change(Questao, :count).by(2)
      
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response['questoes'].length).to eq(2)
      
      questao_com_formulario = Questao.find_by(enunciado: "Questão array 2")
      expect(questao_com_formulario.formularios_id).to eq(formulario.id)
    end
    
    it "retorna erro para templates inválidos" do
      post "/templates", params: { template: { content: "", admin_id: nil } }
      expect(response).to have_http_status(422)
    end
  end
  
  describe "PUT /templates/:id" do
    let(:template) { create(:template_with_questions) }
    
    it "atualiza um template existente" do
      put "/templates/#{template.id}", params: { 
        template: { content: "Template atualizado" } 
      }
      
      expect(response).to have_http_status(200)
      expect(template.reload.content).to eq("Template atualizado")
    end
    
    it "adiciona novas questões ao template" do
      # First destroy all existing questions to have a clean slate
      template.questoes.destroy_all
      # Then add exactly 3 questions to start with
      3.times { |i| template.questoes.create!(enunciado: "Questão original #{i+1}") }
      
      expect {
        put "/templates/#{template.id}", params: { 
          template: { 
            questoes_attributes: [
              { enunciado: "Nova questão no update" }
            ]
          } 
        }
      }.to change(Questao, :count).by(1)
      
      expect(response).to have_http_status(200)
      expect(template.reload.questoes.count).to eq(4) # 3 originais + 1 nova
    end
  end
  
  describe "DELETE /templates/:id" do
    let!(:template) { create(:template_with_questions, questions_count: 2) }
    
    it "remove o template e suas questões" do
      expect {
        delete "/templates/#{template.id}"
      }.to change(Template, :count).by(-1)
      .and change(Questao, :count).by(-2)
      
      expect(response).to have_http_status(204)
    end
  end
end
