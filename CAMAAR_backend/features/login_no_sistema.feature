# language: pt

@api
Funcionalidade: Login no sistema
  Como um usuário do sistema CAMAAR
  Eu quero me autenticar na aplicação
  Para que eu possa acessar as funcionalidades específicas do meu perfil

  Cenário: Login bem-sucedido como estudante
    Dado que eu sou um usuário registrado com email "estudante@exemplo.com" e senha "senha123" com perfil "student"
    Quando eu envio um POST para "/auth/login" com:
      | email    | estudante@exemplo.com |
      | password | senha123              |
    Então eu devo receber uma resposta com status 200
    E a resposta deve incluir um token
    E a resposta deve incluir informações do usuário
    E o usuário deve ter o papel "student"

  Cenário: Login bem-sucedido como professor
    Dado que eu sou um usuário registrado com email "professor@exemplo.com" e senha "senha123" com perfil "professor"
    Quando eu envio um POST para "/auth/login" com:
      | email    | professor@exemplo.com |
      | password | senha123              |
    Então eu devo receber uma resposta com status 200
    E a resposta deve incluir um token
    E a resposta deve incluir informações do usuário
    E o usuário deve ter o papel "professor"

  Cenário: Login bem-sucedido como administrador
    Dado que eu sou um usuário registrado com email "admin@exemplo.com" e senha "senha123" com perfil "admin"
    Quando eu envio um POST para "/auth/login" com:
      | email    | admin@exemplo.com |
      | password | senha123          |
    Então eu devo receber uma resposta com status 200
    E a resposta deve incluir um token
    E a resposta deve incluir informações do usuário
    E o usuário deve ter o papel "admin"

  Cenário: Falha no login com senha incorreta
    Dado que eu sou um usuário registrado com email "estudante@exemplo.com" e senha "senha123" com perfil "student"
    Quando eu envio um POST para "/auth/login" com:
      | email    | estudante@exemplo.com |
      | password | senhaerrada           |
    Então eu devo receber uma resposta com status 401
    E a resposta deve incluir uma mensagem de erro "Credenciais inválidas"

  Cenário: Falha no login com email não cadastrado
    Quando eu envio um POST para "/auth/login" com:
      | email    | naocadastrado@exemplo.com |
      | password | senha123                  |
    Então eu devo receber uma resposta com status 401
    E a resposta deve incluir uma mensagem de erro "Credenciais inválidas"

  Cenário: Falha no login com campos vazios
    Quando eu envio um POST para "/auth/login" com:
      | email    |  |
      | password |  |
    Então eu devo receber uma resposta com status 400
    E a resposta deve incluir uma mensagem de erro "Email e senha são obrigatórios"
