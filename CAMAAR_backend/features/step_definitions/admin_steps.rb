# encoding: utf-8
# Step definitions para gerenciamento de templates

Dado('que o administrador está na interface de templates') do
  @admin = User.create!(
    email: 'admin@exemplo.com',
    password: 'senha123',
    name: 'Administrador',
    registration: '123456',
    role: 'admin',
    major: 'Administração'
  )
  
  # Cria alguns templates de exemplo
  @templates = [
    Template.create!(content: 'Template 1', user: @admin),
    Template.create!(content: 'Template 2', user: @admin)
  ]
  
  visit '/templates'
end

Quando('o sistema carrega os templates') do
  expect(page).to have_current_path('/templates')
end

Então('ele deverá ver somente os templates criados por ele') do
  @templates.each do |template|
    expect(page).to have_content(template.content)
  end
  
  # Verifica se não aparecem templates de outros usuários
  outros_templates = Template.where.not(user: @admin)
  outros_templates.each do |template|
    expect(page).not_to have_content(template.content)
  end
end

Então('deverá ter a opção de deletar ou editar esse template') do
  expect(page).to have_link('Editar')
  expect(page).to have_link('Deletar')
end

Dado('que o administrador está na interface de template') do
  step 'que o administrador está na interface de templates'
end

Quando('ele tenta acessar um template criado por outro administrador') do
  outro_admin = User.create!(
    email: 'outro_admin@exemplo.com',
    password: 'senha123',
    name: 'Outro Administrador',
    registration: '123457',
    role: 'admin',
    major: 'Administração'
  )
  
  template_outro_admin = Template.create!(content: 'Template Privado', user: outro_admin)
  
  visit "/templates/#{template_outro_admin.id}"
end

Então('ele deverá ver uma mensagem de erro de permissão {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

# Step definitions para formulários e turmas
Dado('que eu sou um participante de uma turma') do
  @participante = User.create!(
    email: 'participante@exemplo.com',
    password: 'senha123',
    name: 'Participante',
    registration: '123456',
    role: 'student',
    major: 'Ciência da Computação'
  )
  
  # Cria uma turma e associa o participante
  @turma = Turma.create!(
    code: 'CIC0001',
    number: 1,
    semester: '2024.1',
    time: '14:00-16:00',
    name: 'Introdução à Programação'
  )
  
  TurmaAluno.create!(turma: @turma, aluno: @participante)
end

Dado('existem formulários não respondidos na turma em que eu estou matriculado') do
  @template = Template.create!(content: 'Template de Avaliação', user_id: 1)
  @formulario = Formulario.create!(
    name: 'Avaliação da Turma',
    date: Date.current,
    template: @template,
    turma: @turma
  )
end

Quando('eu acessar a tela de formulários pendentes') do
  visit '/formularios_pendentes'
end

Então('devo visualizar uma lista de formulários não respondidos E poder escolher um formulário pra responder') do
  expect(page).to have_content(@formulario.name)
  expect(page).to have_link('Responder')
end

Dado('que sou participante de uma turma') do
  step 'que eu sou um participante de uma turma'
end

Dado('não existem formulários não respondidos na turma em que eu estou matriculado') do
  # Não cria formulários para a turma
end

Quando('eu acessar a tela de visualização de formulários pendentes') do
  visit '/formularios_pendentes'
end

Então('eu devo visualizar uma mensagem dizendo  {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

# Step definitions para atualização de banco de dados
Dado('que existe uma base de dados já existente no sistema') do
  # Simula dados existentes no sistema
  expect(User.count).to be > 0
end

Quando('eu solicitar a atualização com os dados atuais do SIGAA') do
  click_button 'Atualizar Dados do SIGAA'
end

Então('o sistema deve importar e corrigir os registros automaticamente') do
  expect(page).to have_content('Dados atualizados com sucesso')
end

Então('uma mensagem com o texto {string} deve aparecer') do |mensagem|
  expect(page).to have_content(mensagem)
end

Dado('que eu sou um administrador') do
  @admin = User.create!(
    email: 'admin@exemplo.com',
    password: 'senha123',
    name: 'Administrador',
    registration: '123456',
    role: 'admin',
    major: 'Administração'
  )
  
  visit '/admin'
end

Dado('que a conexão com o SIGAA não está disponível no momento da atualização') do
  # Simula falha na conexão
  allow_any_instance_of(SigaaService).to receive(:conectar).and_raise(StandardError, 'Conexão indisponível')
end

Quando('eu tentar atualizar a base de dados') do
  click_button 'Atualizar Base de Dados'
end

Então('não alterar a base de dados') do
  # Verifica que os dados não foram alterados
  expect(page).not_to have_content('Dados atualizados')
end

# Step definitions para relatórios
Dado('que estou na tela de {string} Quando clico em {string} Então devo ver a tela com os formulários criados') do |tela1, botao|
  visit "/#{tela1.downcase}"
  click_link botao
  expect(page).to have_content('Formulários')
end

Quando('clico em um formulário') do
  formulario = Formulario.first || Formulario.create!(
    name: 'Formulário Teste',
    date: Date.current,
    template: Template.first || Template.create!(content: 'Template', user_id: 1)
  )
  
  click_link formulario.name
end

Então('devo ver as perguntas daquele formulário') do
  expect(page).to have_content('Perguntas')
end

Quando('clico em {string}') do |botao|
  click_button botao
end

Então('um arquivo contendo o relatório das respostas deve ser gerado') do
  expect(page.response_headers['Content-Type']).to include('application')
end

Dado('que estou na tela de {string}') do |tela|
  visit "/#{tela.downcase}"
end

Então('devo ver a tela com os formulários criados') do
  expect(page).to have_content('Formulários')
end

Quando('este formulário não teve nenhuma resposta') do
  # Garante que não há respostas para o formulário
  expect(Resposta.count).to eq(0)
end

Então('devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
