class CreateTurmas < ActiveRecord::Migration[8.0]
  def change
    create_table :turmas do |t|
      t.string :code
      t.integer :number
      t.string :semester
      t.string :time
      t.string :name

      t.timestamps
    end
  end
end
