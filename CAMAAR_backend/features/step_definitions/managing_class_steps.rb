
Dado('que o administrador acessa a interface de gestão de turmas') do
  visit('/login')
  fill_in 'Email', with: 'admin@cic.unb.br'
  fill_in 'Senha', with: 'senha_admin'
  click_button 'Entrar'

  visit('/gerenciamento/turmas')
  expect(page).to have_current_path('/gerenciamento/turmas')

  @admin_departamento = page.find('#departamento-atual').text
end

Quando('o sistema carrega a lista de turmas') do
  expect(page).to have_css('.turmas-list')
  
  @turmas_exibidas = all('.turma-item').map { |turma| 
    {
      nome: turma.find('.turma-nome').text,
      departamento: turma.find('.turma-departamento').text
    }
  }
end

Então('devem ser exibidas apenas as turmas vinculadas ao seu departamento') do
  expect(@turmas_exibidas).not_to be_empty
  @turmas_exibidas.each do |turma|
    expect(turma[:departamento]).to eq(@admin_departamento)
  end

  expect(page).not_to have_css('.turma-item', text: /Departamento de Sociologia/)
end

Quando('ele tenta procurar pela turma {string}') do |nome_turma|
  fill_in 'busca-turma', with: nome_turma
  
  find('#busca-turma').native.send_keys(:return)

  @turma_buscada = nome_turma
end

Quando('ele é do {string}') do |departamento|
  expect(@admin_departamento).to eq(departamento)
end

Então('uma mensagem de erro de permissão deve aparecer {string}') do |mensagem|
  expect(page).to have_content(mensagem)

  expect(page).not_to have_css('.turma-item', text: @turma_buscada)
end