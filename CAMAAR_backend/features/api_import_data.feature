# language: pt

@api
Funcionalidade: API de Importação de Dados
  Como um administrador da API
  Quero importar dados através de arquivos JSON
  Para carregar informações de disciplinas, turmas e alunos no sistema

  Contexto:
    Dado que existem dados básicos no sistema
    E que estou autenticado como "admin"

  Cenário: Administrador importa dados com sucesso
    Dado que existem arquivos JSON válidos no sistema
    Quando eu envio um POST para "/import-data"
    Então o status da resposta deve ser 200
    E a resposta deve conter dados de importação bem-sucedida
    E a resposta deve conter estatísticas de processamento

  Cenário: Falha na importação por arquivos JSON não encontrados
    Dado que não existem arquivos JSON no sistema
    Quando eu envio um POST para "/import-data"
    Então o status da resposta deve ser 404
    E a resposta deve conter mensagem de arquivos não encontrados

  Cenário: Usuário comum não pode importar dados
    Dado que estou autenticado como "student"
    Quando eu envio um POST para "/import-data"
    Então o status da resposta deve ser 403
    E a resposta deve conter mensagem de acesso negado

  Cenário: Falha na importação por JSON inválido
    Dado que existem arquivos JSON inválidos no sistema
    Quando eu envio um POST para "/import-data"
    Então o status da resposta deve ser 422
    E a resposta deve conter mensagem de JSON inválido
