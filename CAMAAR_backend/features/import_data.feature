# language: pt

Funcionalidade: Admin importar dados do SIGAA

    Como Administrador
    Quero importar dados de turmas, matérias e participantes do SIGAA (caso não existam na base de dados atual)
    A fim de alimentar a base de dados do sistema.

    Cenário: Administrador importa os dados
        Dado que estou na pagina de gerenciamento
        Quando eu aperto o botão "Importar dados"
        Então os novos dados com matérias, discentes e docentes devem ser salvos
        E os demais botões presentes nessa tela devem ser liberados