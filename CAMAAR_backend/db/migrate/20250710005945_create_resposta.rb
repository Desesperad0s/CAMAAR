class CreateResposta < ActiveRecord::Migration[8.0]
  def change
    create_table :resposta do |t|
      t.string :content

      t.timestamps
    end
  end
end
