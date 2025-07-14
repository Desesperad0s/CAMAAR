Dado('que eu estou logado como administrador') do
  @admin = FactoryBot.create(:user, :admin)
  login_as(@admin)
end

Dado('existe um formulário com respostas cadastradas') do
  @formulario = FactoryBot.create(:formulario_with_responses)
end

Quando('eu acesso a página do formulário') do
  visit formulario_path(@formulario)
end

Quando('clico no botão {string}') do |button_name|
  click_button button_name
end

Quando('seleciono o formato {string}') do |format|
  select format, from: 'Formato'
end

Então('devo ver a mensagem {string}') do |message|
  expect(page).to have_content(message)
end

Então('devo ver a mensagem de erro {string}') do |message|
  expect(page).to have_content(message)
  expect(page).to have_css('.error-message', text: message)
end

Então('o arquivo deve ser baixado no formato PDF') do
  expect(page.response_headers['Content-Type']).to eq('application/pdf')
end

Então('o arquivo deve ser baixado no formato Excel') do
  expect(page.response_headers['Content-Type']).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
end