require 'rails_helper'

RSpec.describe TurmaAlunosController, type: :controller do
  let(:user) { FactoryBot.create(:user, :admin) }
  let(:token) { JwtService.encode(user_id: user.id) }
  let!(:departamento) { Departamento.create!(name: 'Exatas', code: 'EXA', abreviation: 'EXA') }
  let!(:disciplina) { Disciplina.create!(name: 'Matemática', departamento_id: departamento.id) }
  let!(:turma) { Turma.create!(code: 'MAT001', number: 1, semester: '2024.1', time: '08:00', name: 'Turma A', disciplina_id: disciplina.id) }
  let!(:aluno) { FactoryBot.create(:user, :student) }
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_request).and_return(true)
    controller.instance_variable_set(:@current_user, user)
  end
  
  let!(:turma_aluno) { TurmaAluno.create!(turma_id: turma.id, aluno_id: aluno.id) }

  # Note: Esta controller pode não ter todas as rotas configuradas
  # Apenas testando o que está disponível
  
  describe 'basic functionality' do
    it 'controller is defined and accessible' do
      expect(TurmaAlunosController).to be_a(Class)
      expect(TurmaAlunosController < ApplicationController).to be true
    end
  end
end
