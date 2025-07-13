RSpec.describe 'Gerenciamento de Formulários', type: :feature do
  let(:admin) { create(:user, :admin) }
  let(:template) { create(:template) }
  let(:turma) { create(:turma) }

  before do
    login_as(admin)
  end

  scenario 'admin cria formulário a partir de template' do
    visit new_formulario_path

    fill_in 'Nome', with: 'Formulário de Avaliação 2025.1'
    fill_in 'Data', with: Date.today
    select template.nome, from: 'Template'
    select turma.codigo, from: 'Turma'

    click_button 'Criar Formulário'

    expect(page).to have_content('Formulário criado com sucesso')
  end
end
