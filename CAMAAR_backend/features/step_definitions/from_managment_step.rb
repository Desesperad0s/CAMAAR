Dado('existe um template cadastrado com nome {string}') do |nome|
  @template = FactoryBot.create(:template, nome: nome)
end

Dado('existe uma turma cadastrada com código {string}') do |codigo|
  @turma = FactoryBot.create(:turma, codigo: codigo)
end

Dado('que existe um formulário cadastrado') do
  @formulario = FactoryBot.create(:formulario,
    template: @template,
    turma: @turma,
    nome: "Formulário Teste"
  )
end

Quando('eu acesso a página de criação de formulário') do
  visit new_formulario_path
end

Quando('eu acesso a página de edição do formulário') do
  visit edit_formulario_path(@formulario)
end

Quando('confirmo a exclusão') do
  accept_confirm
end