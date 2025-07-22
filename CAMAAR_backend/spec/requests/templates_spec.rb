require 'rails_helper'

RSpec.describe "Templates API", type: :request do
  describe "GET /templates" do
    before do
      create_list(:template_with_questions, 3, questions_count: 2)
    end
    
    it "retorna todos os templates" do
      get "/templates", headers: auth_headers
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)
    end
    
    it "inclui questões nos templates" do
      get "/templates", headers: auth_headers
      json_response = JSON.parse(response.body)
      expect(json_response.first['questoes'].length).to eq(2)
    end
  end
  
  describe "GET /templates/:id" do
    let(:template) { create(:template_with_questions) }
    
    it "retorna o template específico" do
      get "/templates/#{template.id}", headers: auth_headers
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(template.id)
    end
    
    it "retorna erro 404 para template inexistente" do
      get "/templates/99999", headers: auth_headers
      expect(response).to have_http_status(404)
    end
  end
  
  describe "POST /templates" do
    let(:admin_user) { create(:user, :admin) }
    let(:formulario) { create(:formulario) }
    
    it "cria um novo template" do
      expect {
        post "/templates", 
             params: { template: { content: "Novo template", user_id: admin_user.id } },
             headers: auth_headers(admin_user)
      }.to change(Template, :count).by(1)
      
      expect(response).to have_http_status(201)
    end
    
    it "cria um template com questões aninhadas" do
      expect {
        post "/templates", 
             params: { 
               template: { 
                 content: "Template com questões aninhadas", 
                 user_id: admin_user.id,
                 questoes_attributes: [
                   { enunciado: "Questão aninhada 1" },
                   { enunciado: "Questão aninhada 2" }
                 ]
               } 
             },
             headers: auth_headers(admin_user)
      }.to change(Questao, :count).by(2)
      
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response['questoes'].length).to eq(2)
    end
    
    it "cria um template com questões em array separado" do
      expect {
        post "/templates", 
             params: { 
               template: { 
                 content: "Template com questões em array", 
                 user_id: admin_user.id
               },
               questoes: [
                 { enunciado: "Questão array 1" },
                 { enunciado: "Questão array 2" }
               ]
             },
             headers: auth_headers(admin_user)
      }.to change(Questao, :count).by(2)
      
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response['questoes'].length).to eq(2)
      
      # Verificar que as questões foram criadas com sucesso
      questao = Questao.find_by(enunciado: "Questão array 2")
      expect(questao).to be_present
    end
    
    it "cria um template com questões e alternativas aninhadas" do
      expect {
        post "/templates", 
             params: { 
               template: { 
                 content: "Template com questões e alternativas", 
                 user_id: admin_user.id,
                 questoes_attributes: [
                   { 
                     enunciado: "Questão com alternativas 1", 
                     alternativas_attributes: [
                       { content: "Alternativa 1" },
                       { content: "Alternativa 2" }
                     ]
                   },
                   { 
                     enunciado: "Questão com alternativas 2", 
                     alternativas_attributes: [
                       { content: "Alternativa 3" },
                       { content: "Alternativa 4" }
                     ]
                   }
                 ]
               } 
             },
             headers: auth_headers(admin_user)
      }.to change(Questao, :count).by(2).and change(Alternativa, :count).by(4)
      
      expect(response).to have_http_status(201)
      json_response = JSON.parse(response.body)
      expect(json_response['questoes'].length).to eq(2)
      
      questao_ids = json_response['questoes'].map { |q| q['id'] }
      alternativas_count = Alternativa.where(questao_id: questao_ids).count
      expect(alternativas_count).to eq(4)
    end
    
    it "retorna erro para templates inválidos" do
      post "/templates", 
           params: { template: { content: "", user_id: nil } },
           headers: auth_headers(admin_user)
      expect(response).to have_http_status(422)
    end
  end
  
  describe "PUT /templates/:id" do
    let(:template) { create(:template_with_questions) }
    
    it "atualiza um template existente" do
      put "/templates/#{template.id}", 
          params: { template: { content: "Template atualizado" } },
          headers: auth_headers
      
      expect(response).to have_http_status(200)
      expect(template.reload.content).to eq("Template atualizado")
    end
    
    it "adiciona novas questões ao template" do
      # First destroy all existing questions to have a clean slate
      template.questoes.destroy_all
      # Then add exactly 3 questions to start with
      3.times { |i| template.questoes.create!(enunciado: "Questão original #{i+1}") }
      
      expect {
        put "/templates/#{template.id}", 
            params: { 
              template: { 
                questoes_attributes: [
                  { enunciado: "Nova questão no update" }
                ]
              } 
            },
            headers: auth_headers
      }.to change(Questao, :count).by(1)
      
      expect(response).to have_http_status(200)
      expect(template.reload.questoes.count).to eq(4)
    end
  end
  
  describe "DELETE /templates/:id" do
    let!(:template) { create(:template_with_questions, questions_count: 2) }
    
    it "remove o template mas preserva as questões" do
      questoes_ids = template.questoes.pluck(:id)
      
      expect {
        delete "/templates/#{template.id}", headers: auth_headers
      }.to change(Template, :count).by(-1)
      .and change(Questao, :count).by(0) 
      
      expect(response).to have_http_status(200)
      
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq("Template deletado com sucesso")
      
      questoes_ids.each do |questao_id|
        questao = Questao.find(questao_id)
        expect(questao.templates_id).to be_nil
      end
    end
  end
end
