class AddTurmaToFormularios < ActiveRecord::Migration[8.0]
  def change
    add_reference :formularios, :turma, foreign_key: true
  end
end
