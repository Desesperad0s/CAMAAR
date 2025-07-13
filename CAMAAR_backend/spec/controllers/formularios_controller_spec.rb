require 'rails_helper'

RSpec.describe FormulariosController, type: :controller do
  before(:each) do
    allow_any_instance_of(described_class).to receive(:authenticate_request).and_return(true)
    allow_any_instance_of(described_class).to receive(:current_user).and_return(create(:user, :admin))
  end

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
    let!(:questao1) { create(:questao, templates_id: template.id) }
    let!(:questao2) { create(:questao, templates_id: template.id) }
    
    before do
      create(:alternativa, content: "Alternativa 1", questao: questao1)
      create(:alternativa, content: "Alternativa 2", questao: questao1)
      create(:alternativa, content: "Alternativa 3", questao: questao2)
      create(:alternativa, content: "Alternativa 4", questao: questao2)
    end
    
    let(:valid_question_params) {
      {
        name: "Formulário com Questões",
        date: Date.today.to_s,
        template_id: template.id,
        respostas: [
          {
            questao_id: questao1.id,
            content: "Resposta para primeira questão"
          },
          {
            questao_id: questao2.id,
            content: "Resposta para segunda questão"
          }
        ]
      }
    }

    context "com parâmetros válidos" do
      it "cria um formulário com respostas para questões existentes" do
        expect {
          post :create_with_questions, params: valid_question_params
        }.to change(Formulario, :count).by(1)
          .and change(Questao, :count).by(0) 
          .and change(Resposta, :count).by(2)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        
        # Verificar a presença do template_id
        expect(json_response["template_id"]).to eq(template.id)
        
        # Verificar as respostas e suas questões
        expect(json_response["respostas"].size).to eq(2)
        expect(json_response["respostas"][0]["questao"]["alternativas"].size).to eq(2)
        expect(json_response["respostas"][0]["questao_id"]).to be_present
        
        # Verificar que as associações estão corretamente estabelecidas
        formulario = Formulario.last
        expect(formulario.template_id).to eq(template.id)
        expect(formulario.respostas.count).to eq(2)
        expect(formulario.questoes.count).to eq(2) # via the through association
        
        # Verificar que cada resposta está vinculada a uma questão existente
        formulario.respostas.each do |resposta|
          expect(resposta.questao).to be_present
          expect([questao1.id, questao2.id]).to include(resposta.questao_id)
        end
        
        # Verificar o conteúdo das respostas
        resposta_contents = formulario.respostas.pluck(:content)
        expect(resposta_contents).to include("Resposta para primeira questão")
        expect(resposta_contents).to include("Resposta para segunda questão")
      end

      it "cria um formulário com template associado e conteúdo de resposta" do
        # Criando um template específico para este teste
        specific_template = create(:template)
        # Criar uma questão para o template específico
        specific_questao = create(:questao, templates_id: specific_template.id)
        # Criar alternativas para a questão
        create_list(:alternativa, 2, questao: specific_questao)
        
        params_with_template = {
          name: "Formulário com Template",
          date: Date.today.to_s,
          template_id: specific_template.id,
          respostas: [
            {
              questao_id: specific_questao.id,
              content: "Conteúdo da resposta personalizada"
            }
          ]
        }
        
        post :create_with_questions, params: params_with_template
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        
        # Verificar a associação com o template
        expect(json_response["template_id"]).to eq(specific_template.id)
        expect(json_response).to have_key("template")
        expect(json_response["template"]["id"]).to eq(specific_template.id)
        
        # Verificar o conteúdo da resposta
        expect(json_response["respostas"].size).to eq(1)
        expect(json_response["respostas"][0]).to have_key("content")
        expect(json_response["respostas"][0]["content"]).to eq("Conteúdo da resposta personalizada")
        expect(json_response["respostas"][0]["questao_id"]).to eq(specific_questao.id)
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

  describe "POST #create with nested questoes e respostas" do
    let(:template) { create(:template) }
    let!(:questao1) { create(:questao, templates_id: template.id) }
    let!(:questao2) { create(:questao, templates_id: template.id) }
    
    before do
      create(:alternativa, content: "Alternativa 1", questao: questao1)
      create(:alternativa, content: "Alternativa 2", questao: questao1)
      create(:alternativa, content: "Alternativa 3", questao: questao2)
      create(:alternativa, content: "Alternativa 4", questao: questao2)
    end
    
    let(:valid_nested_attributes) {
      {
        formulario: {
          name: 'Formulário com Questões',
          date: Date.today,
          template_id: template.id,
          respostas_attributes: [
            {
              questao_id: questao1.id,
              content: "Resposta para primeira questão"
            },
            {
              questao_id: questao2.id,
              content: "Resposta para segunda questão"
            }
          ]
        }
      }
    }
    
  end

  describe "PUT #update with nested respostas" do
    let(:template) { create(:template) }
    let!(:questao1) { create(:questao, templates_id: template.id) }
    let!(:questao2) { create(:questao, templates_id: template.id) }
    let!(:questao3) { create(:questao, templates_id: template.id, enunciado: "Questão adicional") }
    let(:formulario) { create(:formulario, template_id: template.id) }
    
    before do
      create(:alternativa, content: "Alt 1", questao: questao1)
      create(:alternativa, content: "Alt 2", questao: questao2)
      create(:alternativa, content: "Alt 3", questao: questao3)
      
      create(:resposta, formulario: formulario, questao: questao1, content: "Resposta inicial 1")
      create(:resposta, formulario: formulario, questao: questao2, content: "Resposta inicial 2")
    end
    
    let(:update_attributes) {
      resposta1 = formulario.respostas.find_by(questao: questao1)
      resposta2 = formulario.respostas.find_by(questao: questao2)
      
      {
        formulario: {
          name: 'Formulário Atualizado',
          respostas_attributes: [
            {
              id: resposta1.id, 
              questao_id: questao1.id,
              content: "Resposta atualizada" 
            },
            {
              questao_id: questao3.id,
              content: "Resposta para questão adicional"
            },
            {
              id: resposta2.id,
              _destroy: '1'
            }
          ],
          remove_missing_respostas: true
        }
      }
    }
    
  end
end
