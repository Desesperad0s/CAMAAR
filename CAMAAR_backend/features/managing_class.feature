# language: pt
Funcionalidade: Admin gerenciar turmas do departamento que pertence

    Como Administrador
    Quero gerenciar somente as turmas do departamento o qual eu pertenço
    A fim de avaliar o desempenho das turmas no semestre atual

    Cenário: Apenas turmas do seu departamento aparecem
        Dado que o administrador acessa a interface de gestão de turmas
        Quando o sistema carrega a lista de turmas
        Então devem ser exibidas apenas as turmas vinculadas ao seu departamento
    
    Cenário: Tenta acessar turmas de outro departamento
        Dado que o administrador acessa a interface de gestão de turmas
        Quando ele tenta procurar pela turma "Introdução a sociologia"
        E ele é do "Departamento de Ciência da Computação"
        Então uma mensagem de erro de permissão deve aparecer "Você não tem acesso à essa turma"