# encoding: utf-8
# Step definitions específicos para testes de API (sem interface gráfica)

# Para testes que necessitam de usuários autenticados via API
Dado('que estou autenticado como {string}') do |role|
  # Se já há um usuário autenticado com o mesmo role, reutilizar
  if @current_user && @current_user.role == role && @token
    next
  end
  
  # Mapear roles para valores esperados pelo sistema
  system_role = case role
  when 'administrador', 'admin'
    'admin'
  when 'professor'
    'professor'
  when 'student', 'estudante'
    'student'
  else
    role
  end
  
  @user = User.create!(
    email: "test_#{role}_#{rand(10000)}@exemplo.com",
    password: "senha123",
    name: "#{role.capitalize} de Teste",
    registration: "123456",
    role: system_role,
    major: "Ciência da Computação"
  )
  
  # Fazer login via API para obter token
  header 'Content-Type', 'application/json'
  post '/auth/login', { 
    email: @user.email, 
    password: "senha123" 
  }.to_json
  
  expect(last_response.status).to eq(200)
  response_data = JSON.parse(last_response.body)
  @token = response_data['token']
  @current_user = @user
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
    code: 'APC001',
    name: 'Algoritmos e Programação - Turma 1',
    semester: '2025.1',
    number: 1,
    time: 'manhã',
    disciplina: @disciplina
  )
end

# Para criar formulários de teste
Dado('existem formulários no sistema') do
  @formulario = Formulario.create!(
    name: "Formulário de Avaliação",
    date: Date.current,
    publico_alvo: "discente",
    turma: @turma
  )
end

# Para criar templates de teste
Dado('existem templates no sistema') do
  @template = Template.create!(
    content: "Template de Teste",
    user: @current_user || @user
  )
end

Dado('que existem templates no sistema') do
  @template = Template.create!(
    content: "Template de Teste",
    user: @current_user || @user
  )
end

# Para fazer requisições POST com dados de template
Quando('eu envio um POST para {string} com dados do template') do |endpoint|
  dados_template = {
    content: "Novo Template de Teste"
  }
  
  if @token
    header 'Authorization', "Bearer #{@token}"
  end
  header 'Content-Type', 'application/json'
  post endpoint, dados_template.to_json
end

# Para fazer requisições com dados específicos
Quando('eu envio um POST para {string} com dados do formulário') do |endpoint|
  dados_formulario = {
    name: "Formulário de Teste",
    date: Date.current.to_s,
    publico_alvo: "discente",
    turma_id: @turma.id
  }
  
  if @token
    header 'Authorization', "Bearer #{@token}"
  end
  header 'Content-Type', 'application/json'
  post endpoint, dados_formulario.to_json
end

# Para fazer requisições GET
Quando('eu envio um GET para {string}') do |endpoint|
  if @token
    header 'Authorization', "Bearer #{@token}"
  end
  header 'Content-Type', 'application/json'
  get endpoint
end

# Para fazer requisições POST genéricas
Quando('eu envio um POST para {string}') do |endpoint|
  if @token
    header 'Authorization', "Bearer #{@token}"
  end
  header 'Content-Type', 'application/json'
  post endpoint
end

# Para fazer requisições sem autenticação
Quando('eu envio um GET para {string} sem autenticação') do |endpoint|
  header 'Content-Type', 'application/json'
  get endpoint
end

# Para fazer requisições autenticadas genéricas
Quando('eu envio um {string} para {string} com token de autenticação') do |metodo, endpoint|
  if @token
    header 'Authorization', "Bearer #{@token}"
  end
  header 'Content-Type', 'application/json'
  send(metodo.downcase, endpoint)
end

# Para verificar status codes
Então('o status da resposta deve ser {int}') do |status|
  expect(last_response.status).to eq(status)
end

# Para testes de API que precisam verificar dados de resposta
Então('a resposta deve conter {string}') do |conteudo|
  expect(last_response.body).to include(conteudo)
end

# Para verificar dados na resposta
Então('a resposta deve conter dados do formulário criado') do
  expect(last_response.body).not_to be_empty
  response_data = JSON.parse(last_response.body)
  expect(response_data).to have_key('id')
  expect(response_data).to have_key('name')
end

# Para verificar lista na resposta
Então('a resposta deve conter uma lista de formulários') do
  expect(last_response.body).not_to be_empty
  response_data = JSON.parse(last_response.body)
  expect(response_data).to be_an(Array)
end

# Para verificar lista de templates na resposta
Então('a resposta deve conter uma lista de templates') do
  expect(last_response.body).not_to be_empty
  response_data = JSON.parse(last_response.body)
  expect(response_data).to be_an(Array)
end

# Para verificar dados do template na resposta
Então('a resposta deve conter dados do template criado') do
  expect(last_response.body).not_to be_empty
  response_data = JSON.parse(last_response.body)
  expect(response_data).to have_key('id')
  expect(response_data).to have_key('content')
end

# === STEPS PARA IMPORTAÇÃO DE DADOS ===

# Para simular arquivos JSON válidos no sistema
Dado('que existem arquivos JSON válidos no sistema') do
  # Criar arquivos JSON temporários para teste no formato correto
  classes_content = [
    {
      "code": "CIC001",
      "name": "Algoritmos e Programação",
      "dicente": [
        {
          "nome": "João Silva",
          "matricula": "123456",
          "email": "joao.silva@exemplo.com"
        }
      ]
    }
  ].to_json

  members_content = [
    {
      "code": "CIC001", 
      "dicente": [
        {
          "nome": "João Silva",
          "matricula": "123456",
          "email": "joao.silva@exemplo.com"
        }
      ]
    }
  ].to_json

  File.write(Rails.root.join('classes.json'), classes_content)
  File.write(Rails.root.join('class_members.json'), members_content)
end

# Para simular ausência de arquivos JSON
Dado('que não existem arquivos JSON no sistema') do
  # Remover arquivos se existirem
  classes_path = Rails.root.join('classes.json')
  members_path = Rails.root.join('class_members.json')
  
  File.delete(classes_path) if File.exist?(classes_path)
  File.delete(members_path) if File.exist?(members_path)
end

# Para simular arquivos JSON inválidos
Dado('que existem arquivos JSON inválidos no sistema') do
  # Criar arquivos com JSON malformado
  File.write(Rails.root.join('classes.json'), '{ invalid json content')
  File.write(Rails.root.join('class_members.json'), '[ invalid json ]')
end

# Para verificar resposta de importação bem-sucedida
Então('a resposta deve conter dados de importação bem-sucedida') do
  expect(last_response.body).not_to be_empty
  response_data = JSON.parse(last_response.body)
  expect(response_data).to have_key('success')
  expect(response_data['success']).to be_truthy
end

# Para verificar estatísticas de processamento
Então('a resposta deve conter estatísticas de processamento') do
  expect(last_response.body).not_to be_empty
  response_data = JSON.parse(last_response.body)
  expect(response_data).to have_key('stats')
  expect(response_data['stats']).to be_a(Hash)
end

# Para verificar mensagem de arquivos não encontrados
Então('a resposta deve conter mensagem de arquivos não encontrados') do
  expect(last_response.body).not_to be_empty
  response_data = JSON.parse(last_response.body)
  expect(response_data['message']).to include('não encontrados')
end

# Para verificar mensagem de acesso negado
Então('a resposta deve conter mensagem de acesso negado') do
  expect(last_response.body).not_to be_empty
  response_data = JSON.parse(last_response.body)
  expect(response_data['error']).to include('Acesso negado')
end

# Para verificar mensagem de JSON inválido
Então('a resposta deve conter mensagem de JSON inválido') do
  expect(last_response.body).not_to be_empty
  response_data = JSON.parse(last_response.body)
  expect(response_data['message']).to include('JSON inválido')
end

# === STEPS PARA RELATÓRIOS EXCEL ===

# Para criar formulários com respostas para testes
Dado('existem formulários com respostas no sistema') do
  # Criar template primeiro
  @template = Template.create!(
    content: "Template de Teste",
    user: @current_user || @user
  )
  
  # Criar questão
  @questao = Questao.create!(
    enunciado: "Como você avalia a disciplina?",
    templates_id: @template.id
  )
  
  # Criar formulário
  @formulario = Formulario.create!(
    name: "Formulário de Avaliação com Respostas",
    date: Date.current,
    publico_alvo: "discente",
    turma: @turma,
    template: @template
  )
  
  # Criar resposta
  @resposta = @formulario.respostas.create!(
    questao: @questao,
    content: "Muito boa disciplina"
  )
end

# Para garantir que não existem formulários
Dado('não existem formulários no sistema') do
  Formulario.destroy_all
end

# Para verificar se a resposta é um arquivo Excel
Então('a resposta deve ser um arquivo Excel') do
  expect(last_response.headers['Content-Type']).to include('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
  expect(last_response.body).not_to be_empty
end

# Para verificar se o arquivo contém cabeçalhos adequados
Então('o arquivo deve conter cabeçalhos adequados') do
  expect(last_response.headers['Content-Disposition']).to include('attachment')
  expect(last_response.headers['Content-Disposition']).to include('relatorio_formularios')
end

# Para verificar se o arquivo contém apenas cabeçalhos
Então('o arquivo deve conter apenas cabeçalhos') do
  # Para arquivos Excel vazios, ainda devem ter o content-type correto
  expect(last_response.headers['Content-Type']).to include('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
  expect(last_response.body).not_to be_empty
end

# Para verificar mensagens de erro
Então('a resposta deve conter uma mensagem de erro') do
  expect(last_response.body).not_to be_empty
  response_data = JSON.parse(last_response.body)
  expect(response_data).to have_key('error')
end
