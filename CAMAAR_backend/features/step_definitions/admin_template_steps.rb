Dado('que estou na página de criar template') do
  visit('/templates/new')
end

Quando('eu preencho o campo {string}') do |campo|
  if campo == 'Nome do template:'
    fill_in campo, with: 'Template de Avaliação'
  end
end

Quando('clico no botão {string}') do |botao|
  if botao == '+'
    click_button botao
  elsif botao == 'Criar'
    click_button botao
  end
end

Quando('seleciono a opção {string} do campo {string}') do |opcao, campo|
  within_fieldset(campo) do
    select opcao
  end
end

Quando('preencho o campo {string}') do |campo|
  if campo == 'Texto:'
    fill_in campo, with: 'Como você avalia o desempenho da turma?'
  end
end

Quando('não preencho o campo {string}') do |campo|
  if campo == 'Texto:'
    fill_in campo, with: ''
  end
end

Então('o novo template deve aparecer na tela de {string}') do |pagina|
  expect(page).to have_current_path('/templates')
  expect(page).to have_content('Template de Avaliação')
end

Então('deve aparecer uma mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end