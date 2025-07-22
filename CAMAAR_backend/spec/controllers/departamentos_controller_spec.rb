
require 'rails_helper'

RSpec.describe DepartamentosController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:token) { JwtService.encode(user_id: user.id) }
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end
  
  let!(:departamento) { Departamento.create!(name: 'Exatas', code: 'EXA', abreviation: 'EXA') }
  let(:valid_attributes) { { name: 'Humanas', code: 'HUM', abreviation: 'HUM' } }
  let(:invalid_attributes) { { name: '', code: '', abreviation: '' } }

  describe 'GET #index' do
    it 'returns a success response with all departamentos' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do
    it 'returns the requested departamento' do
      get :show, params: { id: departamento.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(departamento.id)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Departamento' do
        expect {
          post :create, params: { departamento: valid_attributes }
        }.to change(Departamento, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates the requested departamento' do
        patch :update, params: { id: departamento.id, departamento: { name: 'Atualizado' } }
        expect(response).to have_http_status(:ok)
        expect(departamento.reload.name).to eq('Atualizado')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested departamento' do
      expect {
        delete :destroy, params: { id: departamento.id }
      }.to change(Departamento, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
