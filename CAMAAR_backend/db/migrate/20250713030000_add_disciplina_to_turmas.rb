  class AddDisciplinaToTurmas < ActiveRecord::Migration[8.0]
  def change
    add_reference :turmas, :disciplina, foreign_key: true
  end
end
