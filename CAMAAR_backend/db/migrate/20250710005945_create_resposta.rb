class CreateResposta < ActiveRecord::Migration[8.0]
  def change
    create_table :respostas do |t|
      t.string :content
      t.references :questoes, null: false, foreign_key: true
      t.references :formularios, null: false, foreign_key: true
      t.timestamps
    end
  end
end
