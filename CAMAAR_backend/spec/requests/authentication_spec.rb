require 'rails_helper'

RSpec.describe 'Autenticação', type: :request do
  let(:user) { create(:user, password: 'senha123') }
  let(:valid_credentials) { { email: user.email, password: 'senha123' } }
  let(:invalid_credentials) { { email: user.email, password: 'senha_errada' } }

  describe 'POST /auth/login' do
    context 'com credenciais válidas' do
      it 'retorna um token JWT' do
        post '/auth/login', params: valid_credentials
        expect(response).to have_http_status(:ok)
        expect(json_response).to include('token')
        expect(json_response['user']).to include('id', 'name', 'email')
      end
    end

    context 'com credenciais inválidas' do
      it 'retorna erro de autenticação' do
        post '/auth/login', params: invalid_credentials
        expect(response).to have_http_status(:unauthorized)
        expect(json_response).to include('error')
      end
    end
  end

  describe 'GET /auth/me' do
    context 'quando autenticado' do
      it 'retorna os dados do usuário atual' do
        post '/auth/login', params: valid_credentials
        token = json_response['token']
        
        get '/auth/me', headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:ok)
        expect(json_response['user']).to include('id', 'name', 'email')
        expect(json_response['user']['id']).to eq(user.id)
      end
    end

    context 'quando não autenticado' do
      it 'retorna erro de não autorizado' do
        get '/auth/me'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /auth/logout' do
    it 'retorna mensagem de sucesso' do
      post '/auth/login', params: valid_credentials
      token = json_response['token']
      
      delete '/auth/logout', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)
      expect(json_response).to include('message')
    end
  end

  # Helper para converter o corpo da resposta em hash
  def json_response
    JSON.parse(response.body)
  end
end
