Quando('eu acesso a página de recuperação de senha') do
  visit recuperar_senha_path
end

Quando('clico no botão {string}') do |texto_botao|
  click_button texto_botao
end

Quando('clico no link {string}') do |texto_link|
  click_link texto_link
end

Então('devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
