class CreateAdmins < ActiveRecord::Migration[8.0]
  def change
    create_table :admins do |t|
      t.integer :registration
      t.string :name
      t.string :email
      t.string :password
      t.references :departmentos, null: false, foreign_key: true
      t.timestamps
    end
  end
end
