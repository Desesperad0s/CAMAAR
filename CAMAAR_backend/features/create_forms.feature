Funcionalidade: Admin criar formulário a partir de um template para alunos ou professores

    Como Administrador
    Quero escolher criar um formulário para os docentes ou os dicentes de uma turma
    A fim de avaliar o desempenho de uma matéria

    Cenário: Envio de formulário
        Dado que o administrador está na tela de templates
        Quando ele escolhe a turma desejada
        E seleciona se o formulário será destinado aos alunos ou professores
        E seleciona o template
        E define a data de envio e prazo de resposta
        E envia o formulário
        Então o formulário é enviado com sucesso

    Cenário: Envio de formulário sem turma selecionada
        Dado que o administrador está na tela de templates
        Quando ele não escolhe a turma desejada
        Então uma mensagem de erro deverá ser mostrada "Nenhuma turma foi selecionada"