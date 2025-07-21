##
# Modelo de junção representando a associação entre turmas e alunos no sistema CAMAAR
#
# Esta é uma tabela de junção que implementa o relacionamento many-to-many
# entre turmas e usuários (especificamente alunos). Permite que um aluno
# esteja matriculado em múltiplas turmas e que uma turma tenha múltiplos alunos.
#
# === Associações
# * belongs_to :turma - Turma na qual o aluno está matriculado
# * belongs_to :user - Usuário (aluno) que está matriculado na turma
#
# === Chaves Estrangeiras
# * turma_id - ID da turma
# * aluno_id - ID do usuário (referencia users.id)
#
# === Padrão de Relacionamento
# User (aluno) ←→ TurmaAluno ←→ Turma
#
# === Funcionalidade
# Este modelo permite rastrear em quais turmas cada aluno está matriculado,
# facilitando a aplicação de formulários específicos por turma e a
# organização dos dados acadêmicos.
#
class TurmaAluno < ApplicationRecord
  belongs_to :turma, foreign_key: :turma_id
  belongs_to :user, foreign_key: :aluno_id
end
