class UpdateTemplatesAdminForeignKey < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :templates, :admins
    
    rename_column :templates, :admin_id, :user_id
    
    add_foreign_key :templates, :users, column: :user_id
    
    if index_exists?(:templates, :admin_id)
      remove_index :templates, :admin_id
      add_index :templates, :user_id unless index_exists?(:templates, :user_id)
    end
  end
end
