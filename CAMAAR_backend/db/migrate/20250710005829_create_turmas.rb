class CreateTurmas < ActiveRecord::Migration[8.0]
  def change
    create_table :turmas do |t|
      t.string :code
      t.integer :number
      t.string :semester
      t.string :time
      t.string :name
      t.references :disciplinas, null: false, foreign_key: true
      t.timestamps
    end
  end
end
