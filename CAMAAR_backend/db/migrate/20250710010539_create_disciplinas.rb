class CreateDisciplinas < ActiveRecord::Migration[8.0]
  def change
    create_table :disciplinas do |t|
      t.string :code
      t.string :name
      t.references :departmentos, null: false, foreign_key: true
      t.timestamps
    end
  end
end
