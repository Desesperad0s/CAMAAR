# language: pt

@api
Funcionalidade: API de Formulários
  Como um cliente da API
  Quero gerenciar formulários através de endpoints REST
  Para criar, listar e obter informações sobre formulários

  Contexto:
    Dado que existem dados básicos no sistema

  Cenário: Administrador cria formulário via API
    Dado que estou autenticado como "admin"
    Quando eu envio um POST para "/formularios" com dados do formulário
    Então o status da resposta deve ser 201
    E a resposta deve conter dados do formulário criado

  Cenário: Usuário lista formulários via API
    Dado que estou autenticado como "student"
    E existem formulários no sistema
    Quando eu envio um GET para "/formularios"
    Então o status da resposta deve ser 200
    E a resposta deve conter uma lista de formulários

  Cenário: Acesso não autorizado aos formulários
    Quando eu envio um GET para "/formularios" sem autenticação
    Então o status da resposta deve ser 401
    E a resposta deve conter uma mensagem de erro
