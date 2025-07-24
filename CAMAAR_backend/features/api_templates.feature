# language: pt

@api
Funcionalidade: API de Templates
  Como um administrador da API
  Quero gerenciar templates através de endpoints REST
  Para criar modelos reutilizáveis de formulários

  Contexto:
    Dado que existem dados básicos no sistema
    E que estou autenticado como "admin"

  Cenário: Administrador cria template via API
    Quando eu envio um POST para "/templates" com dados do template
    Então o status da resposta deve ser 201
    E a resposta deve conter dados do template criado

  Cenário: Administrador lista templates via API
    Dado que existem templates no sistema
    Quando eu envio um GET para "/templates"
    Então o status da resposta deve ser 200
    E a resposta deve conter uma lista de templates

  Cenário: Usuário comum não pode criar templates
    Dado que estou autenticado como "student"
    Quando eu envio um POST para "/templates" com dados do template
    Então o status da resposta deve ser 403
