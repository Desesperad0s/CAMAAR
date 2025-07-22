require 'rails_helper'

RSpec.describe TurmasController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:token) { JwtService.encode(user_id: user.id) }
  let!(:departamento) { Departamento.create!(name: 'Exatas', code: 'EXA', abreviation: 'EXA') }
  let!(:disciplina) { Disciplina.create!(name: 'Matemática', departamento_id: departamento.id) }
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end
  
  let!(:turma) { Turma.create!(code: 'MAT001', number: 1, semester: '2024.1', time: '08:00', name: 'Turma A', disciplina_id: disciplina.id) }
  let(:valid_attributes) { { code: 'FIS001', number: 2, semester: '2024.1', time: '10:00', name: 'Turma B', disciplina_id: disciplina.id } }

  describe 'GET #index' do
    it 'returns a success response with all turmas' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns the requested turma' do
      get :show, params: { id: turma.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(turma.id)
    end
  end

  describe 'GET #find_by_code' do
    it 'returns the turma when found by code' do
      get :find_by_code, params: { code: turma.code }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['code']).to eq(turma.code)
    end

    it 'returns not found when turma does not exist' do
      get :find_by_code, params: { code: 'INEXISTENTE' }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Turma não encontrada')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Turma' do
        expect {
          post :create, params: { turma: valid_attributes }
        }.to change(Turma, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates the requested turma' do
        patch :update, params: { id: turma.id, turma: { name: 'Nova Turma' } }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested turma' do
      expect {
        delete :destroy, params: { id: turma.id }
      }.to change(Turma, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET #formularios' do
    let!(:formulario) { Formulario.create!(name: 'Form Test', date: Date.current, turma_id: turma.id) }
    
    it 'returns all formularios for a turma' do
      get :formularios, params: { id: turma.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end
end
