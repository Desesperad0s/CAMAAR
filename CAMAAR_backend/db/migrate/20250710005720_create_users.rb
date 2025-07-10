class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.integer :registration
      t.string :name
      t.string :email
      t.string :password
      t.integer :forms_answered
      t.string :major
      t.string :role

      t.timestamps
    end
  end
end
