# language: pt
Funcionalidade: Usuário redefinir senha a partir do e-mail

  Como Usuário
  Quero redefinir uma senha para o meu usuário a partir do e-mail recebido após a solicitação da troca de senha
  Para recuperar o meu acesso ao sistema

  Cenário: Usuário redefine a senha com sucesso a partir do link do e-mail
    Dado que solicitei a redefinição da minha senha
    E recebi um e-mail com o link para redefinir a senha
    Quando acesso o link do e-mail
    E preencho o campo "Nova senha" com "SenhaValida123"
    E confirmo a nova senha com "SenhaValida123"
    E clico no botão "Redefinir senha"
    Então devo ver uma mensagem "Senha alterada com sucesso"
    E devo conseguir acessar o sistema com a nova senha

  Cenário: Tentativa de redefinir senha com senhas não coincidentes
    Dado que recebi um e-mail de redefinição de senha
    E acesso o link do e-mail
    Quando preencho o campo "Nova senha" com "SenhaValida123"
    E confirmo a nova senha com "SenhaDiferente456"
    E clico no botão "Redefinir senha"
    Então devo ver uma mensagem de erro "As senhas não coincidem"
    E minha senha não deve ser alterada
