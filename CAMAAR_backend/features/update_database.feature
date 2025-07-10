Funcionalidade: Admin atualizar base de dados já existente com os dados atuais do SIGAA

    Eu como Administrador
    Quero atualizar a base de dados já existente com os dados atuais do SIGAA
    A fim de corrigir a base de dados do sistema.

    Cenário: Administrador atualiza a base de dados com sucesso
        Dado que sou um administrador
        E que existe uma base de dados já existente no sistema
        Quando eu solicitar a atualização com os dados atuais do SIGAA
        Então o sistema deve importar e corrigir os registros automaticamente
        E uma mensagem com o texto 'Atualização realizada com sucesso' deve aparecer
    
    Cenário: Administrador não consegue atualizar os dados devido a conexão com o SIGAA não estar disponível
        Dado que eu sou um administrador
        E que a conexão com o SIGAA não está disponível no momento da atualização
        Quando eu tentar atualizar a base de dados
        Então o sistema deve exibir uma mensagem dizendo 'A atualização não pode ser realizada'
        E não alterar a base de dados
    