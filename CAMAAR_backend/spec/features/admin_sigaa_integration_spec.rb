RSpec.describe 'Integração com SIGAA', type: :feature do
  let(:admin) { create(:user, :admin) }

  before do
    login_as(admin)
  end

  scenario 'admin importa dados do SIGAA' do
    visit sigaa_import_path

    click_button 'Importar Dados do SIGAA'

    expect(page).to have_content('Dados importados com sucesso')
    expect(Turma.count).to be > 0
  end
end
