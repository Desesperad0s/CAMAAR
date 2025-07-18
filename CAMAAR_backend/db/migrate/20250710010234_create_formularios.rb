class CreateFormularios < ActiveRecord::Migration[8.0]
  def change
    create_table :formularios do |t|
      t.string :name
      t.date :date
      t.references :templates, null: false, foreign_key: true
      t.references :turmas, null: false, foreign_key: true
      t.timestamps
    end
  end
end
