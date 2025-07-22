require 'rails_helper'

RSpec.describe RespostaController, type: :controller do
  let(:user) { FactoryBot.create(:user, :admin) }
  let(:token) { JwtService.encode(user_id: user.id) }
  let!(:departamento) { Departamento.create!(name: 'Exatas', code: 'EXA', abreviation: 'EXA') }
  let!(:disciplina) { Disciplina.create!(name: 'Matemática', departamento_id: departamento.id) }
  let!(:turma) { Turma.create!(code: 'MAT001', number: 1, semester: '2024.1', time: '08:00', name: 'Turma A', disciplina_id: disciplina.id) }
  let!(:template) { Template.create!(content: 'Template teste', user_id: user.id) }
  let!(:formulario) { Formulario.create!(name: 'Form Test', date: Date.current, turma_id: turma.id, template_id: template.id) }
  let!(:questao) { Questao.create!(enunciado: 'Pergunta teste', templates_id: template.id) }
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_request).and_return(true)
    controller.instance_variable_set(:@current_user, user)
  end
  
  let!(:resposta) { Resposta.create!(content: 'Resposta teste', questao_id: questao.id, formulario_id: formulario.id) }
  let(:valid_attributes) { { content: 'Nova resposta', questao_id: questao.id, formulario_id: formulario.id } }

  describe 'GET #index' do
    it 'returns a success response with all respostas' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns the requested resposta' do
      get :show, params: { id: resposta.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(resposta.id)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Resposta' do
        expect {
          post :create, params: { resposta: valid_attributes }
        }.to change(Resposta, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates the requested resposta' do
        patch :update, params: { id: resposta.id, resposta: { content: 'Resposta atualizada' } }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested resposta' do
      expect {
        delete :destroy, params: { id: resposta.id }
      }.to change(Resposta, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST #batch_create' do
    context 'with valid respostas' do
      it 'creates multiple respostas' do
        respostas_params = [
          { content: 'Resposta 1', questao_id: questao.id, formulario_id: formulario.id },
          { content: 'Resposta 2', questao_id: questao.id, formulario_id: formulario.id }
        ]
        
        expect {
          post :batch_create, params: { respostas: respostas_params }
        }.to change(Resposta, :count).by(2)
        expect(response).to have_http_status(:created)
      end
    end

    context 'without respostas param' do
      it 'returns unprocessable_entity' do
        post :batch_create
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Respostas not provided')
      end
    end
  end

  describe 'GET #by_formulario' do
    it 'returns respostas grouped by questao for a formulario' do
      get :by_formulario, params: { formulario_id: formulario.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it 'returns not found for non-existent formulario' do
      get :by_formulario, params: { formulario_id: 99999 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Formulário não encontrado')
    end
  end
end
