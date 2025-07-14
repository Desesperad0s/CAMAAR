# language: pt

Funcionalidade: Admin cria template para formulários 

    Eu como Administrador
    Quero criar um template de formulário contendo as questões do formulário
    A fim de gerar formulários de avaliações para avaliar o desempenho das turmas

    Cenário: Admin cria template com uma questão de texto com sucesso
        Dado que estou na página de criar template
        Quando eu preencho o campo 'Nome do template:'
        E clico no botão '+'
        E seleciono a opção 'Texto' do campo 'Tipo:'
        E preencho o campo 'Texto:'
        E clico no botão 'Criar'
        Então o novo template deve aparecer na tela de 'Editar templates'
    
    Cenário: Admin tenta criar template sem preencher o campo 'Texto:'
        Dado que estou na página de criar template
        Quando eu preencho o campo 'Nome do template:'
        E clico no botão '+'
        E seleciono a opção 'Texto' do campo 'Tipo:'
        E não preencho o campo 'Texto:'
        E clico no botão 'Criar'
        Então deve aparecer uma mensagem 'Questão não possui texto'