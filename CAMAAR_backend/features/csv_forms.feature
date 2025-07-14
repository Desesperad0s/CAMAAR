# language: pt
Funcionalidade: Admin exporta resultados de formulário

  Como Administrador
  Quero baixar um arquivo CSV contendo os resultados de um formulário
  Para avaliar o desempenho das turmas

  Cenário: Administrador exporta os resultados do formulário em CSV
    Dado que estou logado como administrador
    E estou na página de resultados do formulário
    E existem respostas preenchidas no formulário
    Quando clico no botão "Exportar CSV"
    Então um arquivo CSV deve ser gerado para download
    E o arquivo deve conter os dados dos resultados do formulário

  Cenário: Tentativa de exportação sem resultados no formulário
    Dado que estou logado como administrador
    E estou na página de resultados do formulário
    E não existem respostas preenchidas no formulário
    Quando clico no botão "Exportar CSV"
    Então uma mensagem de erro deve ser exibida dizendo "Não há dados para exportar"
    E nenhum arquivo CSV deve ser gerado