class FixUserFields < ActiveRecord::Migration[8.0]
  def change
    change_column :users, :registration, :string

    add_index :users, :email, unique: true

    change_column_default :users, :forms_answered, 0
  end
end
