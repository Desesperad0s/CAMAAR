Dado('que tentei fazer login {int} vezes com senha incorreta') do |numero_tentativas|
  numero_tentativas.times do
    steps %Q{
      Quando eu acesso a página de login
      E preencho o campo "Email" com "user@unb.br"
      E preencho o campo "Senha" com "senha_incorreta"
      E clico no botão "Entrar"
    }
  end
end