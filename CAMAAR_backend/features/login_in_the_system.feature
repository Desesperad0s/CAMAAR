Funcionalidade: Usuário fazer login no sistema

    Eu como Usuário do sistema
    Quero acessar o sistema utilizando um e-mail ou matrícula e uma senha já cadastrada
    A fim de responder formulários ou gerenciar o sistema
    Obs: Quando o Usuário logado for um admin, deve-se mostrar a opção de gerenciamente no menu lateral

    Cenário: Usuário que não é Admin faz login no sistema com sucesso
        Dado que estou na página de login
        E não sou um Admin
        Quando preencho o campo 'Email' com meu e-mail cadastrado
        E preencho o campo 'Senha' com a minha senha cadastrada
        E clico no botão 'Entrar' 
        Então eu devo ver a página de Avaliações com os formulários para eu responder
    
    Cenário: Usuário que é Admin faz login no sistema com sucesso
        Dado que estou na página de login
        E sou um Admin
        Quando preencho o campo 'Email' com meu e-mail cadastrado
        E preencho o campo 'Senha' com a minha senha cadastrada
        E clico no botão 'Entrar'
        Então eu devo ver a página de Avaliações com a barra no menu lateral com as opções 'Avaliação' e 'Gerenciamento'
    
    Cenário: Usuário tenta fazer login no sistema com e-mail inválido
        Dado que estou na página de login
        E não sou um usuário cadastrado no sistema
        Quando preencho o campo 'Email' com um email não cadastrado
        E preencho o campo 'Senha' com uma senha não cadastrada
        E clico no botão 'Entrar'
        Então deve aparecer a mensagem 'Usuário não cadastrado' na tela
