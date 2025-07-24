Dado('que recebi um e-mail de cadastro no sistema com um link para definir minha senha') do
  @usuario = {
    email: 'novo.usuario@unb.br',
    token: SecureRandom.hex(20),
    token_expiracao: Time.now + 24.hours
  }
  
  @user = User.create!(
    email: @usuario[:email],
    password: 'senha_temporaria',
    name: 'Usuário Teste',
    registration: '123456',
    role: 'student',
    major: 'Ciência da Computação'
  )
  
  # Simula o token de reset
  @user.reset_password_token = @usuario[:token]

  @reset_link = "/definir-senha?token=#{@usuario[:token]}"
end

Dado('que recebi um e-mail de cadastro no sistema') do
  @usuario = {
    email: 'novo.usuario@unb.br',
    token: SecureRandom.hex(20),
    token_expiracao: Time.now - 1.hour
  }
  
  @user = User.create!(
    email: @usuario[:email],
    password: 'senha_temporaria',
    name: 'Usuário Teste',
    registration: '123456',
    role: 'student',
    major: 'Ciência da Computação'
  )
  
  # Simula o token de reset
  @user.reset_password_token = @usuario[:token]
  
  @reset_link = "/definir-senha?token=#{@usuario[:token]}"
end

Dado('o link para definição de senha está expirado ou inválido') do
  expect(@usuario[:token_expiracao]).to be < Time.now
end

Quando('acesso o link do e-mail') do
  visit(@reset_link)
  expect(page).to have_current_path(@reset_link)
end

Quando('preencho o campo {string} com {string}') do |campo, valor|
  fill_in campo, with: valor
end

Quando('confirmo a senha com {string}') do |senha|
  fill_in 'Confirmar senha', with: senha
end

Quando('clico no botão {string}') do |botao|
  click_button botao
end

Então('devo ver uma mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('devo conseguir acessar o sistema com minha nova senha') do
  visit('/login')
  fill_in 'Email', with: @usuario[:email]
  fill_in 'Senha', with: 'SenhaValida123'
  click_button 'Entrar'
  
  expect(page).to have_current_path('/inicio')
  expect(page).to have_content('Bem-vindo')
end

Então('devo ver uma mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
  expect(page).to have_css('.error-message')
end

Então('não devo conseguir definir minha senha') do
  expect(page).not_to have_button('Definir senha')
  
  visit('/login')
  fill_in 'Email', with: @usuario[:email]
  fill_in 'Senha', with: 'SenhaValida123'
  click_button 'Entrar'

  expect(page).to have_content('Email ou senha inválidos')
end