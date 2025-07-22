Dado('que sou administrador') do
  visit('/login')
  fill_in 'Email', with: 'admin@admin.unb.br'
  fill_in 'Senha', with: 'senha_admin'
  click_button 'Entrar'
  expect(page).to have_current_path('/admin/create-form')
end

Dado('que sou um administrador') do
  step 'que sou administrador'
end

Dado('existe pelo menos um template criado') do
  expect(page).to have_selector('#template option:not([value=""])')
end

Dado('existe pelo menos uma turma cadastrada') do
  expect(page).to have_selector('.turmas-list .turma-row')
end

Dado('estou criando um formulário') do
  visit('/admin/create-form')
  expect(page).to have_content('Template')
  expect(page).to have_content('Turmas')
end

Quando('eu selecionar o template e as turmas desejadas') do

  find('#template option:not([value=""])').click

  within('.turmas-list') do
    first('.turma-row').click
  end
end

Quando('eu tentar criar um formulário sem selecionar nenhum template') do

  select '', from: 'template'

  within('.turmas-list') do
    first('.turma-row').click
  end
  
  click_button 'Criar'
end

Quando('eu tentar criar um formulário sem selecionar nenhuma turma') do

  find('#template option:not([value=""])').click
 
  within('.turmas-list') do
    all('.turma-row.selected').each do |turma|
      turma.click
    end
  end
  
  click_button 'Criar'
end

Quando('clicar no botão {string}') do |botao|
  click_button botao
end

Então('devo ver uma mensagem dizendo {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('o sistema deve exibir uma mensagem dizendo {string}') do |mensagem|
  expect(page).to have_content(mensagem)
  expect(page).to have_current_path('/admin/create-form')
end

Então('o sistema deve exibir uma mensagem com o texto {string}') do |mensagem|
  expect(page).to have_content(mensagem)
  expect(page).to have_current_path('/admin/create-form')
end