class AddUserIdToTemplates < ActiveRecord::Migration[8.0]
  def change
    # Adiciona a coluna user_id se ela ainda não existir
    unless column_exists?(:templates, :user_id)
      add_column :templates, :user_id, :integer
      add_index :templates, :user_id unless index_exists?(:templates, :user_id)
      add_foreign_key :templates, :users, column: :user_id
    end
    
    # Remove a coluna admin_id se ela ainda existir
    if column_exists?(:templates, :admin_id)
      remove_index :templates, :admin_id if index_exists?(:templates, :admin_id)
      remove_foreign_key :templates, :admins if foreign_key_exists?(:templates, :admins)
      remove_column :templates, :admin_id
    end
  end
  
  private
  
  def foreign_key_exists?(from_table, to_table)
    foreign_keys = ActiveRecord::Base.connection.foreign_keys(from_table.to_s)
    foreign_keys.any? { |k| k.to_table.to_s == to_table.to_s }
  end
end
