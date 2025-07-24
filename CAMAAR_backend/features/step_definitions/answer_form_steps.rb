Dado('que estou logado como participante') do
  # Para testes de API, criar usuário e fazer login programaticamente
  @current_user = User.create!(
    email: 'aluno@aluno.unb.br',
    password: 'senha123',
    name: 'Aluno Teste',
    registration: '123456',
    role: 'student',
    major: 'Ciência da Computação'
  )
  
  # Fazer requisição de login para obter token
  post '/auth/login', params: {
    email: @current_user.email,
    password: 'senha123'
  }.to_json, headers: { 'Content-Type' => 'application/json' }
  
  @auth_response = JSON.parse(last_response.body)
  @auth_token = @auth_response['token']
end

Dado('estou na página do questionário da turma em que estou matriculado') do
  # Para API, criamos uma turma e formulário programaticamente
  @departamento = Departamento.create!(name: 'Teste', code: 'TST', abreviation: 'TST')
  @disciplina = Disciplina.create!(name: 'Disciplina Teste', departamento: @departamento)
  @turma = Turma.create!(
    code: 'TST001',
    number: 1,
    semester: '2024.1',
    time: '08:00',
    name: 'Turma Teste',
    disciplina: @disciplina
  )
  @formulario = Formulario.create!(
    name: 'Questionário Teste',
    date: Date.current,
    turma: @turma
  )
end

Quando('preencho todas as perguntas obrigatórias') do
  all('input[type="radio"][required]').each_with_index do |radio, index|
    radio.click
  end
  
  all('textarea[required]').each_with_index do |textarea, index|
    textarea.fill_in with: "Resposta para questão #{index + 1}"
  end
  
  all('input[type="text"][required]').each_with_index do |text_input, index|
    text_input.fill_in with: "Resposta texto #{index + 1}"
  end
end

Quando('não preencho uma ou mais perguntas obrigatórias') do
  all('input[type="radio"][required]').each_with_index do |radio, index|
    radio.click if index.even?
  end
  
  all('textarea[required]').each_with_index do |textarea, index|
    textarea.fill_in with: "Resposta para questão #{index + 1}" if index.even?
  end
end

Quando('clico no botão {string}') do |botao|
  click_button botao
end

Então('devo ver uma mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('minhas respostas devem ser salvas no sistema') do
  expect(page).to have_content('Questionário enviado com sucesso')
  expect(page).to have_current_path('/available-forms')
end

Então('o questionário não deve ser enviado') do
  expect(page).to have_current_path('/answer-form')
  expect(page).to have_css('.error-field')
end