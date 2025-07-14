# language: pt
Funcionalidade: Admin ver os formulários criados e gerar relatório das respostas
   
    Eu como Administrador
    Quero visualizar os formulários criados
    A fim de poder gerar um relatório a partir das respostas

    Cenário: Administrador visualiza os formulários e gera relatório de um formulário com sucesso
        Dado que estou na tela de 'Gerenciamento' Quando clico em 'Resultados' Então devo ver a tela com os formulários criados
        Quando clico em um formulário
        Então devo ver as perguntas daquele formulário
        Quando clico em 'Gerar resultado'
        Então um arquivo contendo o relatório das respostas deve ser gerado

    Cenário: Administrador tenta gerar relatório de um formulário sem perguntas
        Dado que estou na tela de 'Gerenciamento'
        Quando clico em 'Resultados'
        Então devo ver a tela com os formulários criados
        Quando clico em um formulário
        E este formulário não teve nenhuma resposta
        Então devo ver a mensagem 'Este formulário não teve nenhuma resposta'