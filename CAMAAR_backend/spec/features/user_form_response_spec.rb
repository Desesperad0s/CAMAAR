
RSpec.describe 'Resposta de Formulários', type: :feature do
  let(:aluno) { create(:user, :aluno) }
  let(:turma) { create(:turma) }
  let(:formulario) { create(:formulario, turma: turma) }

  before do
    login_as(aluno)
    turma.alunos << aluno
  end

  scenario 'aluno responde formulário da turma' do
    visit turma_formularios_path(turma)

    click_link formulario.nome

    formulario.questoes.each do |questao|
      within("#questao_#{questao.id}") do
        fill_in 'Resposta', with: 'Minha resposta para a questão'
      end
    end

    click_button 'Enviar Respostas'

    expect(page).to have_content('Respostas enviadas com sucesso')
  end
end