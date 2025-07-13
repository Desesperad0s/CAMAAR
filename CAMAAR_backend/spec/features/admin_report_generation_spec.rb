
RSpec.describe 'Geração de Relatórios', type: :feature do
  let(:admin) { create(:user, :admin) }
  let(:formulario) { create(:formulario_with_responses) }

  before do
    login_as(admin)
  end

  scenario 'admin gera relatório de respostas' do
    visit formulario_path(formulario)

    click_button 'Gerar Relatório'
    select 'PDF', from: 'Formato'
    click_button 'Exportar'

    expect(page.response_headers['Content-Type']).to eq('application/pdf')
    expect(page).to have_content('Relatório gerado com sucesso')
  end
end