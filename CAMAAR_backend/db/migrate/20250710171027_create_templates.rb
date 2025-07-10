class CreateTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :templates do |t|
      t.string :content
      t.references :admin, null: false, foreign_key: true
      t.timestamps
    end
  end
end
