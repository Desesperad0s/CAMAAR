# encoding: utf-8
# Step definitions genéricas para interface de usuário

Dado('que estou na página de login') do
  # Para API, não precisamos navegar para uma página
  # Apenas preparamos o ambiente para fazer requisições
  @login_endpoint = '/auth/login'
end

Dado('não sou um Admin') do
  @current_user = User.create!(
    email: 'usuario@exemplo.com',
    password: 'senha123',
    name: 'Usuário Comum',
    registration: '123456',
    role: 'student',
    major: 'Ciência da Computação'
  )
end

Dado('sou um Admin') do
  @current_user = User.create!(
    email: 'admin@exemplo.com',
    password: 'senha123',
    name: 'Administrador',
    registration: '123456',
    role: 'admin',
    major: 'Administração'
  )
end

Dado('não sou um usuário cadastrado no sistema') do
  @email_nao_cadastrado = 'naocadastrado@exemplo.com'
  @senha_nao_cadastrada = 'senhaerrada'
end

Quando('preencho o campo {string} com meu e-mail cadastrado') do |campo|
  fill_in campo, with: @current_user.email
end

Quando('preencho o campo {string} com a minha senha cadastrada') do |campo|
  fill_in campo, with: @current_user.password
end

Quando('preencho o campo {string} com um email não cadastrado') do |campo|
  fill_in campo, with: @email_nao_cadastrado
end

Quando('preencho o campo {string} com uma senha não cadastrada') do |campo|
  fill_in campo, with: @senha_nao_cadastrada
end

Quando('clico no botão {string}') do |botao|
  click_button botao
end

Então('eu devo ver a página de Avaliações com os formulários para eu responder') do
  expect(page).to have_current_path('/avaliacoes')
  expect(page).to have_content('Avaliações')
end

Então('eu devo ver a página de Avaliações com a barra no menu lateral com as opções {string} e {string}') do |opcao1, opcao2|
  expect(page).to have_current_path('/avaliacoes')
  expect(page).to have_content('Avaliações')
  expect(page).to have_link(opcao1)
  expect(page).to have_link(opcao2)
end

Então('deve aparecer a mensagem {string} na tela') do |mensagem|
  expect(page).to have_content(mensagem)
end

# Step definitions para reset de senha
Dado('que solicitei a redefinição da minha senha') do
  @usuario = {
    email: 'usuario@exemplo.com'
  }
  
  @user = User.create!(
    email: @usuario[:email],
    password: 'senha_antiga',
    name: 'Usuário Teste',
    registration: '123456',
    role: 'student',
    major: 'Ciência da Computação'
  )
end

Dado('recebi um e-mail com o link para redefinir a senha') do
  @reset_token = SecureRandom.hex(20)
  @user.reset_password_token = @reset_token
  @reset_link = "/redefinir-senha?token=#{@reset_token}"
end

Quando('confirmo a nova senha com {string}') do |senha|
  fill_in 'Confirmar nova senha', with: senha
end

Então('devo conseguir acessar o sistema com a nova senha') do
  visit '/login'
  fill_in 'Email', with: @usuario[:email]
  fill_in 'Senha', with: 'SenhaValida123'
  click_button 'Entrar'
  
  expect(page).to have_current_path('/avaliacoes')
end

Dado('que recebi um e-mail de redefinição de senha') do
  @usuario = {
    email: 'usuario@exemplo.com'
  }
  
  @user = User.create!(
    email: @usuario[:email],
    password: 'senha_antiga',
    name: 'Usuário Teste',
    registration: '123456',
    role: 'student',
    major: 'Ciência da Computação'
  )
  
  @reset_token = SecureRandom.hex(20)
  @user.reset_password_token = @reset_token
  @reset_link = "/redefinir-senha?token=#{@reset_token}"
end

Então('minha senha não deve ser alterada') do
  # Verifica que a senha original ainda é válida
  expect(User.authenticate(@usuario[:email], 'senha_antiga')).not_to be_nil
  expect(User.authenticate(@usuario[:email], 'SenhaValida123')).to be_nil
end

# Step definitions para cadastro de usuários
Dado('que eu ainda ainda não importei\/atualizei os dados de alguns participantes.') do
  @novos_usuarios = [
    { email: 'novo1@exemplo.com', name: 'Novo Usuário 1' },
    { email: 'novo2@exemplo.com', name: 'Novo Usuário 2' }
  ]
end

Quando('eu apertar o botão {string} \(ou fazer a ação de atualização)') do |botao|
  click_button botao
end

Então('será encaminhado para os emails cadastrados um texto com link para a conclusão do cadastro \(definição de senha)') do
  # Simula o envio de emails
  expect(page).to have_content('E-mails de cadastro enviados com sucesso')
end

Dado('que eu ainda  importei\/atualizei os dados de alguns participantes.') do
  @usuarios_existentes = User.all
end

Então('não será encaminhado para os emails cadastrados um texto com link para a conclusão do cadastro \(definição de senha)') do
  # Verifica que não houve envio de emails
  expect(page).not_to have_content('E-mails de cadastro enviados')
end

Então('eu devo visualizar uma mensagem dizendo  {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
