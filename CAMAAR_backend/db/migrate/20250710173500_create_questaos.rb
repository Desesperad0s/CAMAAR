class CreateQuestaos < ActiveRecord::Migration[8.0]
  def change
    create_table :questoes do |t|
      t.string :enunciado
      t.references :templates, null: false, foreign_key: true
      t.references :formularios, null: false, foreign_key: true
      t.timestamps
    end
  end
end
