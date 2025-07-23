# encoding: utf-8
# Step definitions específicos para testes de API (sem interface gráfica)

# Para testes que necessitam de usuários autenticados via API
Dado('que estou autenticado como {string}') do |role|
  @user = User.create!(
    email: "test_#{role}@exemplo.com",
    password: "senha123",
    name: "#{role.capitalize} de Teste",
    registration: "123456",
    role: role == 'administrador' ? 'admin' : role,
    major: "Ciência da Computação"
  )
  
  # Fazer login via API para obter token
  post '/auth/login', params: { 
    email: @user.email, 
    password: "senha123" 
  }, as: :json
  
  response_data = JSON.parse(last_response.body)
  @token = response_data['token']
  @current_user = @user
end

# Para testes de API que precisam verificar dados de resposta
Então('a resposta deve conter {string}') do |conteudo|
  expect(last_response.body).to include(conteudo)
end

# Para verificar status codes
Então('o status da resposta deve ser {int}') do |status|
  expect(last_response.status).to eq(status)
end

# Para fazer requisições autenticadas
Quando('eu envio um {string} para {string} com token de autenticação') do |metodo, endpoint|
  headers = @token ? { 'Authorization' => "Bearer #{@token}" } : {}
  send(metodo.downcase, endpoint, headers: headers, as: :json)
end

# Para criar dados de teste necessários
Dado('que existem dados básicos no sistema') do
  # Criar departamento
  @departamento = Departamento.create!(
    code: 'CIC',
    name: 'Departamento de Ciência da Computação',
    abreviation: 'CIC'
  )
  
  # Criar disciplina
  @disciplina = Disciplina.create!(
    name: 'Algoritmos e Programação',
    departamento: @departamento
  )
  
  # Criar turma
  @turma = Turma.create!(
    codigo: 'APC001',
    nome: 'Algoritmos e Programação - Turma 1',
    periodo: '2025.1',
    disciplina: @disciplina
  )
end
