Dado('que estou logado como participante') do
  visit('/login')
  fill_in 'Email', with: 'aluno@aluno.unb.br'
  fill_in 'Senha', with: 'senha123'
  click_button 'Entrar'
  expect(page).to have_current_path('/available-forms')
end

Dado('estou na página do questionário da turma em que estou matriculado') do
  visit('/answer-form')
  expect(page).to have_content('Questionário da Turma')
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