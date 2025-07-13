class RemoveFormulariosIdFromQuestoes < ActiveRecord::Migration[8.0]
  def up
    # Remove the foreign key first
    remove_foreign_key :questoes, column: :formularios_id
    
    # Remove the index
    remove_index :questoes, :formularios_id
    
    # Remove the column
    remove_column :questoes, :formularios_id
  end
  
  def down
    # Add the column back
    add_column :questoes, :formularios_id, :integer
    
    # Add the index back
    add_index :questoes, :formularios_id
    
    # Add the foreign key back
    add_foreign_key :questoes, :formularios, column: :formularios_id
  end
end
