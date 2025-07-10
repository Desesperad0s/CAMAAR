Funcionalidade: Usuário definir senha no primeiro acesso via e-mail de cadastro

  Como Usuário
  Quero definir uma senha para o meu usuário a partir do e-mail do sistema de solicitação de cadastro
  Para acessar o sistema

  Cenário: Usuário define a senha com sucesso no primeiro acesso
    Dado que recebi um e-mail de cadastro no sistema com um link para definir minha senha
    Quando acesso o link do e-mail
    E preencho o campo "Senha" com "SenhaValida123"
    E confirmo a senha com "SenhaValida123"
    E clico no botão "Definir senha"
    Então devo ver uma mensagem "Senha definida com sucesso"
    E devo conseguir acessar o sistema com minha nova senha

  Cenário: Tentativa de definir senha com link expirado ou inválido
    Dado que recebi um e-mail de cadastro no sistema
    E o link para definição de senha está expirado ou inválido
    Quando acesso o link do e-mail
    Então devo ver uma mensagem de erro "Link expirado ou inválido"
    E não devo conseguir definir minha senha
