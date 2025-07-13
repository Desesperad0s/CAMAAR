require 'rails_helper'

RSpec.describe "Respostas", type: :request do
  let(:valid_headers) { { "Accept" => "application/json" }.merge(auth_headers) }
  
  let(:template) { create(:template) }
  let(:formulario) { create(:formulario, template: template) }
  let(:questao) { create(:questao, templates_id: template.id) }
  
  let(:valid_attributes) {
    {
      resposta: {
        content: "Resposta de teste",
        questao_id: questao.id,
        formulario_id: formulario.id
      }
    }
  }

  let(:invalid_attributes) {
    {
      resposta: {
        content: nil,
        questao_id: nil,
        formulario_id: nil
      }
    }
  }

  describe "GET /resposta" do
    it "retorna uma lista de respostas" do
      create_list(:resposta, 3, questao: questao, formulario: formulario)
      
      get resposta_path, headers: valid_headers
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(3)
    end
  end

  describe "GET /resposta/:id" do
    it "retorna uma resposta específica" do
      resposta = create(:resposta, questao: questao, formulario: formulario)
      
      get respostum_path(resposta), headers: valid_headers
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(resposta.id)
    end

    it "retorna 404 para resposta inexistente" do
      # Garantir que estamos usando um ID que não existe
      max_id = Resposta.maximum(:id) || 0
      non_existent_id = max_id + 1000
      
      get "/resposta/#{non_existent_id}", headers: valid_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /resposta" do
    context "com parâmetros válidos" do
      it "cria uma nova resposta" do
        expect {
          post resposta_path, params: valid_attributes, headers: valid_headers
        }.to change(Resposta, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end
    end

    context "com parâmetros inválidos" do
      it "não cria uma nova resposta" do
        expect {
          post resposta_path, params: invalid_attributes, headers: valid_headers
        }.not_to change(Resposta, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /resposta/batch_create" do
    let(:batch_attributes) {
      {
        respostas: [
          {
            content: "Resposta 1",
            questao_id: questao.id,
            formulario_id: formulario.id
          },
          {
            content: "Resposta 2",
            questao_id: questao.id,
            formulario_id: formulario.id
          }
        ]
      }
    }

    let(:invalid_batch_attributes) {
      {
        respostas: [
          {
            content: "Resposta válida",
            questao_id: questao.id,
            formulario_id: formulario.id
          },
          {
            content: nil,
            questao_id: nil,
            formulario_id: nil
          }
        ]
      }
    }

    context "com parâmetros válidos" do
      it "cria múltiplas respostas" do
        expect {
          post "/resposta/batch_create", params: batch_attributes, headers: valid_headers
        }.to change(Resposta, :count).by(2)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(2)
      end
    end

    context "com parâmetros inválidos" do
      it "não cria nenhuma resposta se alguma for inválida" do
        expect {
          post "/resposta/batch_create", params: invalid_batch_attributes, headers: valid_headers
        }.not_to change(Resposta, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
