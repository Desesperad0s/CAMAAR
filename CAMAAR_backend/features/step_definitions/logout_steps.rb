Quando('eu clico em sair') do
  click_link 'Sair'
end

Então('devo ser redirecionado para a página de login') do
  expect(current_path).to eq login_path
end
