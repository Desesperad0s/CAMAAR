require 'rails_helper'

RSpec.describe QuestaosController, type: :controller do
  let(:user) { FactoryBot.create(:user, :admin) }
  let(:token) { JwtService.encode(user_id: user.id) }
  let!(:template) { Template.create!(content: 'Template teste', user_id: user.id) }
  let!(:departamento) { Departamento.create!(name: 'Exatas', code: 'EXA', abreviation: 'EXA') }
  let!(:disciplina) { Disciplina.create!(name: 'Matemática', departamento_id: departamento.id) }
  let!(:turma) { Turma.create!(code: 'MAT001', number: 1, semester: '2024.1', time: '08:00', name: 'Turma A', disciplina_id: disciplina.id) }
  let!(:formulario) { Formulario.create!(name: 'Form Test', date: Date.current, turma_id: turma.id, template_id: template.id) }
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_request).and_return(true)
  end
  
  let!(:questao) { Questao.create!(enunciado: 'Pergunta teste', templates_id: template.id) }
  let(:valid_attributes) { { enunciado: 'Nova pergunta', templates_id: template.id } }

  describe 'GET #index' do
    context 'without formulario_id parameter' do
      it 'returns a success response with all questoes' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to be_an(Array)
      end
    end

    context 'with formulario_id parameter' do
      it 'returns questoes for the specific formulario template' do
        get :index, params: { formulario_id: formulario.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to be_an(Array)
      end

      it 'returns empty array for non-existent formulario' do
        get :index, params: { formulario_id: 99999 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end
  end

  describe 'GET #show' do
    it 'returns the requested questao' do
      get :show, params: { id: questao.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(questao.id)
    end
  end
end
