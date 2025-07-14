Então('devo ver o erro {string}') do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
end

