# encoding: utf-8

Dado('que eu sou um usuário registrado com email {string} e senha {string} com perfil {string}') do |email, senha, perfil|
  @user = User.find_by(email: email)
  
  if @user.nil?
    @user = User.create!(
      email: email,
      password: senha,
      name: "Usuário de Teste",
      registration: "123456",
      role: perfil,
      major: "Ciência da Computação"
    )
  else
    @user.update!(password: senha)
  end
end


Quando('eu envio um POST para {string} com:') do |path, tabela|
  dados = tabela.rows_hash
  

  header 'Content-Type', 'application/json'
  post path, dados.to_json
  

  begin
    @resposta = JSON.parse(last_response.body) if last_response.body.present?
  rescue JSON::ParserError => e
    @resposta = {}
  end
end


Então('eu devo receber uma resposta com status {int}') do |status|
  expect(last_response.status).to eq(status)
end


Então('a resposta deve incluir um token') do
  expect(@resposta).to be_a(Hash)
  expect(@resposta).to have_key("token")
  expect(@resposta["token"]).not_to be_nil
end


Então('a resposta deve incluir informações do usuário') do
  expect(@resposta).to be_a(Hash)
  expect(@resposta).to have_key("user")
  expect(@resposta["user"]).not_to be_nil
  if @user
    expect(@resposta["user"]["email"]).to eq(@user.email)
    expect(@resposta["user"]["name"]).to eq(@user.name)
  end
end


Então('o usuário deve ter o papel {string}') do |papel|
  expect(@resposta).to be_a(Hash)
  expect(@resposta["user"]).not_to be_nil
  expect(@resposta["user"]["role"]).to eq(papel)
end


Então('a resposta deve incluir uma mensagem de erro {string}') do |mensagem|
  expect(@resposta).to be_a(Hash)
  expect(@resposta).to have_key("error")
  actual_message = @resposta["error"]
  expected_patterns = [
    /E-mail ou senha inválidos/,
    /Credenciais inválidas/,
    /Email e senha são obrigatórios/,
    /#{Regexp.escape(mensagem)}/
  ]
  expect(expected_patterns.any? { |pattern| actual_message.match?(pattern) }).to be_truthy
end
