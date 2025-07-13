
RSpec.describe 'Autenticação', type: :feature do
  scenario 'usuário faz login com sucesso' do
    user = create(:user, email: 'user@unb.br', password: 'senha123')

    visit login_path

    fill_in 'Email', with: 'user@unb.br'
    fill_in 'Senha', with: 'senha123'
    click_button 'Entrar'

    expect(page).to have_content('Login realizado com sucesso')
    expect(current_path).to eq(dashboard_path)
  end

  scenario 'usuário redefine senha' do
    visit new_password_reset_path

    fill_in 'Email', with: 'user@unb.br'
    click_button 'Enviar link de redefinição'

    expect(page).to have_content('Instruções enviadas para seu email')
  end
end



