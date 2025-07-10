Funcionalidade: Administrador cadastrar participantes de turmas do SIGAA

    Como Administrador
    Quero cadastrar participantes de turmas do SIGAA ao importar dados de usuarios novos para o sistema
    A fim de que eles acessem o sistema CAMAAR 

    Cenário: O sistema encaminha o email para os usuarios
        Dado que eu ainda ainda não importei/atualizei os dados de alguns participantes.    
        Quando eu apertar o botão "Importar Dados" (ou fazer a ação de atualização)
        Então será encaminhado para os emails cadastrados um texto com link para a conclusão do cadastro (definição de senha)

    Cenário: O sistema não encaminha o email para os usuarios
        Dado que eu ainda  importei/atualizei os dados de alguns participantes.
        Quando eu apertar o botão "Importar Dados" (ou fazer a ação de atualização)
        Então não será encaminhado para os emails cadastrados um texto com link para a conclusão do cadastro (definição de senha)