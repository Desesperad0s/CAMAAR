# language: pt

@api
Funcionalidade: API de Relatório Excel
  Como um usuário autenticado da API
  Quero gerar e baixar relatórios em Excel
  Para analisar dados dos formulários de forma offline

  Contexto:
    Dado que existem dados básicos no sistema

  Cenário: Usuário autenticado gera relatório Excel com dados
    Dado que estou autenticado como "admin"
    E existem formulários com respostas no sistema
    Quando eu envio um GET para "/formularios/report/excel"
    Então o status da resposta deve ser 200
    E a resposta deve ser um arquivo Excel
    E o arquivo deve conter cabeçalhos adequados

  Cenário: Usuário autenticado gera relatório Excel sem dados
    Dado que estou autenticado como "admin"
    E não existem formulários no sistema
    Quando eu envio um GET para "/formularios/report/excel"
    Então o status da resposta deve ser 200
    E a resposta deve ser um arquivo Excel
    E o arquivo deve conter apenas cabeçalhos

  Cenário: Acesso não autorizado ao relatório Excel
    Quando eu envio um GET para "/formularios/report/excel" sem autenticação
    Então o status da resposta deve ser 401
    E a resposta deve conter uma mensagem de erro

  Cenário: Estudante pode acessar relatório Excel
    Dado que estou autenticado como "student"
    E existem formulários com respostas no sistema
    Quando eu envio um GET para "/formularios/report/excel"
    Então o status da resposta deve ser 200
    E a resposta deve ser um arquivo Excel
