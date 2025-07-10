class CreateFormularios < ActiveRecord::Migration[8.0]
  def change
    create_table :formularios do |t|
      t.string :name
      t.date :date

      t.timestamps
    end
  end
end
