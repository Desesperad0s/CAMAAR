class CreateAlternativas < ActiveRecord::Migration[8.0]
  def change
    create_table :alternativas do |t|
      t.string :content

      t.timestamps
    end
  end
end
