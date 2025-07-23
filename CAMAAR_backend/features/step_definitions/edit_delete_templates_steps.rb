Dado('que eu pressionei o botão {string} na tela de edição.') do |botao|
  visit('/templates')
  
  within('.templates-list') do
    first('.template-item .edit-button').click
  end
  
  @template_original = find('.template-name').text

  fill_in 'template-title', with: 'Template Editado'

  click_button botao
end

Então('os formularios criados usando o template antigo são marcados') do
  visit('/formularios')
  expect(page).to have_selector('.formulario-item.template-modificado')
end

Então('eu devo visualizar o novo template na tela de templates.') do
  visit('/templates')
  expect(page).to have_content('Template Editado')
  expect(page).not_to have_content(@template_original)
end

Dado('que eu pressionei o botão de {string}') do |botao|
  visit('/templates')

  @template_para_deletar = first('.template-item .template-name').text
  
  within('.templates-list') do
    first('.template-item .delete-button').click
  end
end

Dado('confirmei a deleção de um template pressionando o botão de {string}.') do |botao|

  within('.confirmation-modal') do
    click_button botao
  end
end

Então('os formularios criados usando esse template devem estar marcados') do
  visit('/formularios')
  expect(page).to have_selector('.formulario-item.template-deletado')
end

Então('esse template não deve aparecer mais na tela de templates.') do
  visit('/templates')
  expect(page).not_to have_content(@template_para_deletar)
end

Dado('que estou na página de edição do template') do
  visit('/templates')
  within('.templates-list') do
    first('.template-item .edit-button').click
  end
  expect(page).to have_content('Edição de Template')
end

Quando('eu clico no botão {string}') do |botao|
  click_button botao
end

Quando('seleciono a opção {string} do campo {string}') do |opcao, campo|
  select opcao, from: campo
end

Quando('não preencho o campo {string}') do |campo|
  # Garante que o campo está vazio
  fill_in campo, with: ''
end

Quando('clico no botão {string}') do |botao|
  click_button botao
end

Então('deve aparecer uma mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end