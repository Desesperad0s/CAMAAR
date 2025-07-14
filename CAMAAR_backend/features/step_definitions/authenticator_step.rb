Dado('que existe um usuário cadastrado com email {string} e senha {string}') do |email, senha|
  FactoryBot.create(:user, email: email, password: senha)
end

Quando('eu acesso a página de login') do
  visit login_path
end

Quando('preencho o campo {string} com {string}') do |campo, valor|
  fill_in campo, with: valor
end

Dado('que estou logado no sistema') do
  steps %Q{
    Dado que existe um usuário cadastrado com email "user@unb.br" e senha "senha123"
    Quando eu acesso a página de login
    E preencho o campo "Email" com "user@unb.br"
    E preencho o campo "Senha" com "senha123"
    E clico no botão "Entrar"
  }
end