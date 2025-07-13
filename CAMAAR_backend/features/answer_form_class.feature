# language: pt

Funcionalidade: Usuário (participante de uma turma) responder questionário da turma

  Como Participante de uma turma
  Quero responder o questionário sobre a turma em que estou matriculado
  Para submeter minha avaliação da turma

  Cenário: Participante responde o questionário com sucesso
    Dado que estou logado como participante
    E estou na página do questionário da turma em que estou matriculado
    Quando preencho todas as perguntas obrigatórias
    E clico no botão "Enviar"
    Então devo ver uma mensagem "Questionário enviado com sucesso"
    E minhas respostas devem ser salvas no sistema

  Cenário: Tentativa de enviar questionário sem preencher campos obrigatórios
    Dado que estou logado como participante
    E estou na página do questionário da turma em que estou matriculado
    Quando não preencho uma ou mais perguntas obrigatórias
    E clico no botão "Enviar"
    Então devo ver uma mensagem de erro "Por favor, responda todas as perguntas obrigatórias"
    E o questionário não deve ser enviado
