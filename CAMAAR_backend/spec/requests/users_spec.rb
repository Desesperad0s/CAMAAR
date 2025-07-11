require 'rails_helper'

RSpec.describe "Users API", type: :request do
  let(:valid_headers) {
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  }

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

  describe "GET /users" do
    it "retorna uma lista de usuários" do
      User.create! valid_attributes
      User.create! valid_attributes.merge(registration: '87654321', email: 'outro@example.com')

      get '/users', headers: valid_headers
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe "GET /users/:id" do
    it "retorna um usuário específico" do
      user = User.create! valid_attributes
      
      get "/users/#{user.id}", headers: valid_headers
      
      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(user.id)
      expect(json_response['name']).to eq(user.name)
    end

    it "retorna 404 para usuário não existente" do
      get "/users/999", headers: valid_headers
      
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /users" do
    context "com parâmetros válidos" do
      it "cria um novo usuário" do
        expect {
          post '/users', params: { user: valid_attributes }.to_json, headers: valid_headers
        }.to change(User, :count).by(1)
        
        expect(response).to have_http_status(:created)
        
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq(valid_attributes[:name])
        expect(json_response['email']).to eq(valid_attributes[:email])
      end
    end

    context "com parâmetros inválidos" do
      it "não cria o usuário e retorna erros" do
        expect {
          post '/users', params: { user: invalid_attributes }.to_json, headers: valid_headers
        }.not_to change(User, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('errors')
      end
    end
  end

  describe "PUT /users/:id" do
    context "com parâmetros válidos" do
      let(:new_attributes) {
        {
          name: 'Nome Atualizado',
          email: 'atualizado@example.com'
        }
      }

      it "atualiza o usuário solicitado" do
        user = User.create! valid_attributes
        
        put "/users/#{user.id}", params: { user: new_attributes }.to_json, headers: valid_headers
        
        expect(response).to have_http_status(:ok)
        
        user.reload
        expect(user.name).to eq('Nome Atualizado')
        expect(user.email).to eq('atualizado@example.com')
      end
    end

    context "com parâmetros inválidos" do
      it "retorna erros de validação" do
        user = User.create! valid_attributes
        
        put "/users/#{user.id}", params: { user: invalid_attributes }.to_json, headers: valid_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /users/:id" do
    it "deleta o usuário" do
      user = User.create! valid_attributes
      
      expect {
        delete "/users/#{user.id}", headers: valid_headers
      }.to change(User, :count).by(-1)
      
      expect(response).to have_http_status(:no_content)
    end
  end
end
