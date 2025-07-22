require 'rails_helper'

RSpec.describe DisciplinasController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:token) { JwtService.encode(user_id: user.id) }
  let!(:departamento) { Departamento.create!(name: 'Exatas', code: 'EXA', abreviation: 'EXA') }
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end
  
  let!(:disciplina) { Disciplina.create!(name: 'Matemática', departamento_id: departamento.id) }
  let(:valid_attributes) { { name: 'Física', departamento_id: departamento.id } }
  let(:invalid_attributes) { { name: '', departamento_id: nil } }

  describe 'GET #index' do
    it 'returns a success response with all disciplinas' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns the requested disciplina' do
      get :show, params: { id: disciplina.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(disciplina.id)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Disciplina' do
        expect {
          post :create, params: { disciplina: valid_attributes }
        }.to change(Disciplina, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates the requested disciplina' do
        patch :update, params: { id: disciplina.id, disciplina: { name: 'Nova Disciplina' } }
        expect(response).to have_http_status(:ok)
        expect(disciplina.reload.name).to eq('Nova Disciplina')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested disciplina' do
      expect {
        delete :destroy, params: { id: disciplina.id }
      }.to change(Disciplina, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
