class AddDisciplinaToTurmas < ActiveRecord::Migration[8.0]
  def change
    add_column :turmas, :disciplina_id, :integer
  end
end
