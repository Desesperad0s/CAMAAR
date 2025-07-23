Dado('que o administrador está na tela de templates') do

  visit('/login')
  fill_in 'Email', with: 'admin@admin.unb.br'
  fill_in 'Senha', with: 'senha_admin'
  click_button 'Entrar'

  visit('/templates')
  expect(page).to have_content('Templates')
end

Quando('ele escolhe a turma desejada') do
  select 'Engenharia de Software - 2025.1', from: 'turma'
end

Quando('ele não escolhe a turma desejada') do
  select '', from: 'turma'
end

Quando('seleciona se o formulário será destinado aos alunos ou professores') do
  choose 'Alunos'
end

Quando('seleciona o template') do
  select 'Template de Avaliação Semestral', from: 'template'
end

Quando('define a data de envio e prazo de resposta') do
  fill_in 'data_envio', with: Date.today.strftime('%Y-%m-%d')
  fill_in 'prazo_resposta', with: (Date.today + 15).strftime('%Y-%m-%d')
end

Quando('envia o formulário') do
  click_button 'Enviar Formulário'
end

Então('o formulário é enviado com sucesso') do
  expect(page).to have_content('Formulário enviado com sucesso')
  
  expect(page).to have_current_path('/admin/forms')
  
  expect(page).to have_content('Engenharia de Software - 2025.1')
  expect(page).to have_content('Template de Avaliação Semestral')
end

Então('uma mensagem de erro deverá ser mostrada {string}') do |mensagem|
  expect(page).to have_content(mensagem)
  expect(page).to have_current_path('/templates')
end