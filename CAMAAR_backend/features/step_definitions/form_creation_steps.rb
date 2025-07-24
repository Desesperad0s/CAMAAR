# encoding: utf-8
# Step definitions para criação de formulários a partir de templates

Dado('estou criando um formulário') do
  visit '/formularios/novo'
end

Quando('eu tentar criar um formulário sem selecionar nenhuma turma') do
  # Tenta enviar o formulário sem selecionar turmas
  click_button 'Criar Formulário'
end
