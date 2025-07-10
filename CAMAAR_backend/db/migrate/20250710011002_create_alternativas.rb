class CreateAlternativas < ActiveRecord::Migration[8.0]
  def change
    create_table :alternativas do |t|
      t.string :content
      t.references :questoes, null: false, foreign_key: true
      t.timestamps
    end
  end
end
