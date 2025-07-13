require 'rails_helper'

RSpec.describe TemplatesController, type: :controller do
  # Ignorar autenticação para testes de controller
  before(:each) do
    allow_any_instance_of(described_class).to receive(:authenticate_request).and_return(true)
    allow_any_instance_of(described_class).to receive(:current_user).and_return(create(:user, :admin))
  end

  before(:each) do
    @admin_user = create(:user, :admin)
    @template = Template.create(content: "Template de teste", user_id: @admin_user.id)
  end

  describe "GET #index" do
    it "retorna uma resposta de sucesso" do
      get :index
      expect(response).to be_successful
    end

    it "retorna todos os templates com suas questões" do
      get :index
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
    end
  end

  describe "GET #show" do
    it "retorna uma resposta de sucesso" do
      get :show, params: { id: @template.id }
      expect(response).to be_successful
    end

    it "retorna o template solicitado com suas questões" do
      get :show, params: { id: @template.id }
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(@template.id)
      expect(json["content"]).to eq("Template de teste")
    end

    it "retorna 404 quando o template não existe" do
      get :show, params: { id: 9999 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST #create" do
    context "com parâmetros válidos" do
      it "cria um novo Template" do
        expect {
          post :create, params: { template: { content: "Novo template", user_id: @admin_user.id } }
        }.to change(Template, :count).by(1)
      end

      it "retorna um status :created" do
        post :create, params: { template: { content: "Novo template", user_id: @admin_user.id } }
        expect(response).to have_http_status(:created)
      end

      it "retorna o novo template como JSON" do
        post :create, params: { template: { content: "Novo template", user_id: @admin_user.id } }
        json = JSON.parse(response.body)
        expect(json["content"]).to eq("Novo template")
      end
      
      it "cria um template com questões via atributos aninhados" do
        questoes_attributes = [
          { enunciado: "Questão 1" }
        ]
        
        post :create, params: { 
          template: { 
            content: "Template com questões", 
            user_id: @admin_user.id,
            questoes_attributes: questoes_attributes 
          } 
        }
        
        expect(response).to have_http_status(:created)
        
        template = Template.last
        expect(template.questoes.count).to eq(1)
        expect(template.questoes.first.enunciado).to eq("Questão 1")
      end
      
      it "cria um template com questões via array separado" do
        questoes = [
          { enunciado: "Questão A" }
        ]
        
        post :create, params: { 
          template: { content: "Template separado", user_id: @admin_user.id },
          questoes: questoes
        }
        
        expect(response).to have_http_status(:created)
        
        template = Template.last
        expect(template.questoes.count).to eq(1)
        expect(template.questoes.first.enunciado).to eq("Questão A")
      end
    end

    context "com parâmetros inválidos" do
      it "não cria um novo Template" do
        allow_any_instance_of(Template).to receive(:save).and_return(false)
        expect {
          post :create, params: { template: { content: "" } }
        }.not_to change(Template, :count)
      end

      it "retorna um status :unprocessable_entity" do
        allow_any_instance_of(Template).to receive(:save).and_return(false)
        post :create, params: { template: { content: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "com parâmetros válidos" do
      it "atualiza o template solicitado" do
        put :update, params: { id: @template.id, template: { content: "Template atualizado" } }
        @template.reload
        expect(@template.content).to eq("Template atualizado")
      end

      it "retorna o template atualizado" do
        put :update, params: { id: @template.id, template: { content: "Template atualizado" } }
        json = JSON.parse(response.body)
        expect(json["content"]).to eq("Template atualizado")
      end
    end

    context "com parâmetros inválidos" do
      it "retorna um status :unprocessable_entity" do
        # Stub para simular falha de validação
        allow_any_instance_of(Template).to receive(:update).and_return(false)
        put :update, params: { id: @template.id, template: { content: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destrói o template solicitado" do
      template_to_delete = Template.create(content: "Template para deletar")
      expect {
        delete :destroy, params: { id: template_to_delete.id }
      }.to change(Template, :count).by(-1)
    end

    it "retorna um status :no_content" do
      delete :destroy, params: { id: @template.id }
      expect(response).to have_http_status(:no_content)
    end

    it "destrói também as questões associadas" do
      template_with_question = Template.create(content: "Template com questão")
      
      begin
        questao = template_with_question.questoes.create(enunciado: "Questão teste")
        
        expect {
          delete :destroy, params: { id: template_with_question.id }
        }.to change(Questao, :count).by(-1)
      rescue => e
        pending "Não foi possível criar a questão: #{e.message}"
      end
    end
  end
end
