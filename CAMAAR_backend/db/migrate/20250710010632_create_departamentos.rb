class CreateDepartamentos < ActiveRecord::Migration[8.0]
  def change
    create_table :departamentos do |t|
      t.string :code
      t.string :name
      t.string :abreviation

      t.timestamps
    end
  end
end
