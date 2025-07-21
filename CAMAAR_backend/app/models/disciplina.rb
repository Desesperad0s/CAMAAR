##
# Modelo representando disciplinas acadêmicas no sistema CAMAAR
#
# As disciplinas são matérias oferecidas por departamentos e podem
# ter múltiplas turmas associadas. Cada disciplina pertence a um
# departamento específico e serve como base para a criação de turmas.
#
# === Associações
# * belongs_to :departamento - Departamento ao qual esta disciplina pertence
# * has_many :turmas - Turmas oferecidas desta disciplina
#
# === Estrutura Hierárquica
# Departamento -> Disciplinas -> Turmas -> Alunos
#
# === Exemplos
# * "Algoritmos e Estruturas de Dados" (Departamento de Ciência da Computação)
# * "Cálculo I" (Departamento de Matemática)
#
class Disciplina < ApplicationRecord
  belongs_to :departamento
  has_many :turmas
  
end
