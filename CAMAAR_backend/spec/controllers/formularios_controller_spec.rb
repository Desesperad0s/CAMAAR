require 'rails_helper'

RSpec.describe FormulariosController, type: :controller do
  before do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  let(:valid_attributes) {
    { name: 'Formulário de Teste', date: Date.today, template_id: create(:template).id }
  }

  let(:invalid_attributes) {
    { name: nil, date: nil }
  }

  describe "GET #index" do
    it "retorna uma lista de formulários" do
      formulario = create(:formulario)
      get :index
      expect(response).to be_successful
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.size).to eq(1)
    end
  end

  describe "GET #show" do
    it "retorna um formulário específico" do
      formulario = create(:formulario)
      get :show, params: { id: formulario.id }
      expect(response).to be_successful
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(formulario.id)
    end

    it "retorna 404 para um formulário inexistente" do
      get :show, params: { id: 999 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST #create" do
    context "com parâmetros válidos" do
      it "cria um novo formulário" do
        expect {
          post :create, params: { formulario: valid_attributes }
        }.to change(Formulario, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "com parâmetros inválidos" do
      it "não cria um formulário" do
        expect {
          post :create, params: { formulario: invalid_attributes }
        }.to change(Formulario, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "com parâmetros válidos" do
      it "atualiza o formulário solicitado" do
        formulario = create(:formulario)
        new_name = "Formulário Atualizado"
        put :update, params: { id: formulario.id, formulario: { name: new_name } }
        formulario.reload
        expect(formulario.name).to eq(new_name)
        expect(response).to be_successful
      end
    end

    context "com parâmetros inválidos" do
      it "não atualiza o formulário" do
        formulario = create(:formulario)
        original_name = formulario.name
        put :update, params: { id: formulario.id, formulario: invalid_attributes }
        formulario.reload
        expect(formulario.name).to eq(original_name)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destrói o formulário solicitado" do
      formulario = create(:formulario)
      expect {
        delete :destroy, params: { id: formulario.id }
      }.to change(Formulario, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST #create_with_questions" do
    let(:template) { create(:template) }
    let(:valid_question_params) {
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

    context "com parâmetros válidos" do
      it "cria um formulário com questões e alternativas" do
        expect {
          post :create_with_questions, params: valid_question_params
        }.to change(Formulario, :count).by(1)
          .and change(Questao, :count).by(2)
          .and change(Alternativa, :count).by(4)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["questoes"].size).to eq(2)
        expect(json_response["questoes"][0]["alternativas"].size).to eq(2)
      end
    end

    context "com parâmetros inválidos" do
      it "não cria um formulário quando o nome está ausente" do
        invalid_params = valid_question_params.merge(name: nil)
        expect {
          post :create_with_questions, params: invalid_params
        }.to change(Formulario, :count).by(0)
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
