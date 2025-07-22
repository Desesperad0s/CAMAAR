require 'rails_helper'

RSpec.describe AdminsController, type: :controller do
  let(:user) { FactoryBot.create(:user, :admin) }
  let(:token) { JwtService.encode(user_id: user.id) }
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_request).and_return(true)
    controller.instance_variable_set(:@current_user, user)
  end
  
  let!(:admin) { Admin.create!(registration: 123456, name: 'Admin Teste', email: 'admin@test.com', password: 'password123') }
  let(:valid_attributes) { { registration: 789012, name: 'Novo Admin', email: 'novo@admin.com', password: 'senha123' } }

  describe 'GET #index' do
    it 'returns a success response with all admins' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns the requested admin' do
      get :show, params: { id: admin.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(admin.id)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Admin' do
        expect {
          post :create, params: { admin: valid_attributes }
        }.to change(Admin, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates the requested admin' do
        patch :update, params: { id: admin.id, admin: { name: 'Admin Atualizado' } }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested admin' do
      expect {
        delete :destroy, params: { id: admin.id }
      }.to change(Admin, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
