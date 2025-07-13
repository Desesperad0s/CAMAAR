#!/bin/bash
# Script para aplicar as migrações necessárias para as relações entre departamento, disciplina e turma

echo "Aplicando migrações para adicionar as relações..."
rails db:migrate

echo "Migrações aplicadas com sucesso!"
echo "As tabelas agora possuem as seguintes colunas adicionais:"
echo " - disciplinas: departamento_id (FK para departamentos)"
echo " - turmas: disciplina_id (FK para disciplinas)"

echo "Verificando o schema atualizado..."
rails db:schema:dump

echo "Pronto! Você pode verificar o schema.rb para confirmar as alterações."
