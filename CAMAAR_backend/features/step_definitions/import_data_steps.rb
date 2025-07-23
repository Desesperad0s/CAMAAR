Dado('que estou na pagina de gerenciamento') do
  visit('/login')
  fill_in 'Email', with: 'admin@admin.unb.br'
  fill_in 'Senha', with: 'senha_admin'
  click_button 'Entrar'
  
  visit('/gerenciamento')
  expect(page).to have_current_path('/gerenciamento')

  @initial_data = {
    turmas: all('.turma-row').count,
    materias: all('.materia-row').count,
    participantes: all('.participante-row').count
  }

  @outros_botoes = ['Editar Formularios', 'Enviar Formulários', 'Resultados']
  @outros_botoes.each do |botao|
    expect(page).to have_button(botao, disabled: true)
  end
end

Quando('eu aperto o botão {string}') do |botao|

  click_button botao

  expect(page).to have_content('Importação concluída com sucesso')
end

Então('os novos dados com matérias, discentes e docentes devem ser salvos') do

  visit(current_path)
  
  expect(all('.turma-row').count).to be > @initial_data[:turmas]
  expect(all('.materia-row').count).to be > @initial_data[:materias]
  expect(all('.participante-row').count).to be > @initial_data[:participantes]
 
  within('.dados-importados') do
    expect(page).to have_css('.turma-item')
    expect(page).to have_css('.materia-item')
    expect(page).to have_css('.participante-item')
  end
  
  expect(page).to have_content(/[A-Z]{3}[0-9]{4}/) 
  expect(page).to have_content(/20[0-9]{2}\.{1,2}/) 
end

Então('os demais botões presentes nessa tela devem ser liberados') do
  @outros_botoes.each do |botao|
    expect(page).to have_button(botao, disabled: false)
  end

  @outros_botoes.each do |botao|
    expect(page).to have_css("button:not([disabled])", text: botao)
  end
end