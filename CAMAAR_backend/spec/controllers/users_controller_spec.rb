require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_attributes) {
    {
      registration: '12345678',
      name: 'Teste Usuario',
      email: 'teste@example.com',
      password: 'senha123',
      major: 'Ciência da Computação',
      role: 'student'
    }
  }

  let(:invalid_attributes) {
    {
      registration: nil,
      name: '',
      email: 'invalido',
      password: '',
      major: nil,
      role: nil
    }
  }

  # Ignorar autenticação para testes de controller
  before(:each) do
    allow_any_instance_of(described_class).to receive(:authenticate_request).and_return(true)
    # Usar um usuário mockado em vez de criar um no banco
    allow_any_instance_of(described_class).to receive(:current_user).and_return(mock_admin_user)
  end

  describe "GET #index" do
    it "retorna uma resposta de sucesso" do
      User.create! valid_attributes
      get :index
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it "retorna todos os usuários" do
      user1 = User.create! valid_attributes
      user2 = User.create! valid_attributes.merge(registration: '87654321', email: 'outro@example.com')
      
      get :index
      json_response = JSON.parse(response.body)
      
      expect(json_response.length).to eq(2)
      expect(json_response.map { |u| u['id'] }).to include(user1.id, user2.id)
    end
  end

  describe "GET #show" do
    it "retorna uma resposta de sucesso" do
      user = User.create! valid_attributes
      get :show, params: { id: user.id }
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it "retorna o usuário solicitado" do
      user = User.create! valid_attributes
      get :show, params: { id: user.id }
      
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(user.id)
      expect(json_response['name']).to eq(user.name)
      expect(json_response['email']).to eq(user.email)
    end
  end

  describe "POST #create" do
    context "com parâmetros válidos" do
      it "cria um novo User" do
        expect {
          post :create, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it "retorna um status :created" do
        post :create, params: { user: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it "retorna o novo usuário como JSON" do
        post :create, params: { user: valid_attributes }
        
        json_response = JSON.parse(response.body)
        expect(json_response['user']['name']).to eq(valid_attributes[:name])
        expect(json_response['user']['email']).to eq(valid_attributes[:email])
      end
    end

    context "com parâmetros inválidos" do
      it "não cria um novo User" do
        expect {
          post :create, params: { user: invalid_attributes }
        }.to change(User, :count).by(0)
      end

      it "retorna um status :unprocessable_entity" do
        post :create, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "retorna os erros de validação" do
        post :create, params: { user: invalid_attributes }
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
        expect(json_response['errors']).to have_key('registration')
        expect(json_response['errors']).to have_key('name')
        expect(json_response['errors']).to have_key('email')
      end
    end
  end

  describe "PUT #update" do
    context "com parâmetros válidos" do
      let(:new_attributes) {
        {
          name: 'Nome Atualizado',
          email: 'atualizado@example.com'
        }
      }

      it "atualiza o usuário solicitado" do
        user = User.create! valid_attributes
        put :update, params: { id: user.id, user: new_attributes }
        user.reload
        
        expect(user.name).to eq('Nome Atualizado')
        expect(user.email).to eq('atualizado@example.com')
      end

      it "retorna um status :ok" do
        user = User.create! valid_attributes
        put :update, params: { id: user.id, user: new_attributes }
        expect(response).to have_http_status(:ok)
      end

      it "retorna o usuário atualizado como JSON" do
        user = User.create! valid_attributes
        put :update, params: { id: user.id, user: new_attributes }
        
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Nome Atualizado')
        expect(json_response['email']).to eq('atualizado@example.com')
      end
    end

    context "com parâmetros inválidos" do
      it "retorna um status :unprocessable_entity" do
        user = User.create! valid_attributes
        put :update, params: { id: user.id, user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "retorna os erros de validação" do
        user = User.create! valid_attributes
        put :update, params: { id: user.id, user: invalid_attributes }
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
        expect(json_response['errors']).to have_key('registration')
        expect(json_response['errors']).to have_key('name')
        expect(json_response['errors']).to have_key('email')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destrói o usuário solicitado" do
      user = User.create! valid_attributes
      expect {
        delete :destroy, params: { id: user.id }
      }.to change(User, :count).by(-1)
    end

    it "retorna um status :no_content" do
      user = User.create! valid_attributes
      delete :destroy, params: { id: user.id }
      expect(response).to have_http_status(:no_content)
    end
  end
end
