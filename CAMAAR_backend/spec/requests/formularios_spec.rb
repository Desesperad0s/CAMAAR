require 'rails_helper'

RSpec.describe "Formularios", type: :request do
  let(:valid_attributes) {
    {
      name: "Formulário de Teste",
      date: Date.today.to_s
    }
  }

  let(:invalid_attributes) {
    {
      name: nil,
      date: nil
    }
  }

  let(:valid_headers) {
    { "Accept" => "application/json" }.merge(auth_headers)
  }

  describe "GET /formularios" do
    it "retorna uma lista de formulários" do
      # Criar alguns formulários para o teste
      create_list(:formulario, 3)

      # Fazer a requisição
      get formularios_path, headers: valid_headers

      # Verificar se a resposta é bem-sucedida (código 200)
      expect(response).to have_http_status(:ok)

      # Verificar se o conteúdo JSON é uma lista e tem o tamanho esperado
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.size).to eq(3)
    end
  end

  describe "GET /formularios/:id" do
    it "retorna o formulário solicitado" do
      formulario = create(:formulario)
      
      get formulario_path(formulario), headers: valid_headers
      
      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(formulario.id)
      expect(json_response["name"]).to eq(formulario.name)
      expect(json_response["date"]).to eq(formulario.date.to_s)
    end

    it "retorna status 404 para formulário inexistente" do
      get formulario_path(id: 999), headers: valid_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /formularios" do
    context "com parâmetros válidos" do
      it "cria um novo formulário" do
        expect {
          post formularios_path, 
               params: { formulario: valid_attributes }, 
               headers: valid_headers
        }.to change(Formulario, :count).by(1)
        
        expect(response).to have_http_status(:created)
        
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq(valid_attributes[:name])
      end
    end

    context "com parâmetros inválidos" do
      it "não cria um novo formulário" do
        expect {
          post formularios_path, 
               params: { formulario: invalid_attributes }, 
               headers: valid_headers
        }.not_to change(Formulario, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT /formularios/:id" do
    context "com parâmetros válidos" do
      let(:new_attributes) {
        { name: "Formulário Atualizado" }
      }

      it "atualiza o formulário solicitado" do
        formulario = create(:formulario)
        
        put formulario_path(formulario), 
            params: { formulario: new_attributes }, 
            headers: valid_headers
        
        formulario.reload
        expect(formulario.name).to eq("Formulário Atualizado")
        expect(response).to have_http_status(:ok)
      end
    end

    context "com parâmetros inválidos" do
      it "não atualiza o formulário" do
        formulario = create(:formulario)
        original_name = formulario.name
        
        put formulario_path(formulario), 
            params: { formulario: invalid_attributes }, 
            headers: valid_headers
        
        formulario.reload
        expect(formulario.name).to eq(original_name)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /formularios/:id" do
    it "exclui o formulário solicitado" do
      formulario = create(:formulario)
      
      expect {
        delete formulario_path(formulario), headers: valid_headers
      }.to change(Formulario, :count).by(-1)
      
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /formularios/create_with_questions" do
    let(:template) { create(:template) }
    
    let(:valid_form_with_questions) {
      {
        name: "Formulário com Questões",
        date: Date.today.to_s,
        template_id: template.id,
        questoes: [
          {
            enunciado: "Primeira questão",
            template_id: template.id,
            alternativas: [
              { content: "Alternativa 1" },
              { content: "Alternativa 2" }
            ]
          },
          {
            enunciado: "Segunda questão",
            template_id: template.id,
            alternativas: [
              { content: "Alternativa 3" },
              { content: "Alternativa 4" }
            ]
          }
        ]
      }
    }

    let(:invalid_form_with_questions) {
      {
        name: nil,
        date: Date.today.to_s,
        questoes: [
          {
            enunciado: "Primeira questão",
            template_id: template.id
          }
        ]
      }
    }

    context "com parâmetros válidos" do
      it "cria um formulário com questões e alternativas" do
        expect {
          post create_with_questions_formularios_path, 
               params: valid_form_with_questions, 
               headers: valid_headers
        }.to change(Formulario, :count).by(1)
          .and change(Questao, :count).by(2)
          .and change(Alternativa, :count).by(4)
        
        expect(response).to have_http_status(:created)
        
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq(valid_form_with_questions[:name])
        expect(json_response["questoes"].size).to eq(2)
        expect(json_response["questoes"][0]["alternativas"].size).to eq(2)
      end
    end

    context "com parâmetros inválidos" do
      it "não cria um formulário quando os dados são inválidos" do
        expect {
          post create_with_questions_formularios_path, 
               params: invalid_form_with_questions, 
               headers: valid_headers
        }.not_to change(Formulario, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
