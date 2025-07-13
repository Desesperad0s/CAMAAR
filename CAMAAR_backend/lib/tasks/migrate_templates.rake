namespace :db do
  desc 'Execute migrações e atualize o schema para a nova estrutura de templates'
  task migrate_templates: :environment do
    puts "Iniciando migração de templates..."
    
    unless Template.column_names.include?('user_id')
      puts "Adicionando coluna user_id..."
      ActiveRecord::Migration.class_eval do
        add_column :templates, :user_id, :integer
        add_index :templates, :user_id
      end
    end
    
    if Template.column_names.include?('admin_id') && Template.column_names.include?('user_id')
      puts "Migrando dados de admin_id para user_id..."
      Template.find_each do |template|
        if template.admin_id.present?
          admin_user = User.where(role: 'admin').first
          if admin_user
            template.update_column(:user_id, admin_user.id)
            puts "Template #{template.id} atualizado para user_id=#{admin_user.id}"
          end
        end
      end
    end
    
    # Remover coluna admin_id se ainda existir
    if Template.column_names.include?('admin_id')
      puts "Removendo coluna admin_id..."
      begin
        if ActiveRecord::Base.connection.foreign_keys(:templates).any? { |fk| fk.to_table == 'admins' }
          ActiveRecord::Migration.class_eval do
            remove_foreign_key :templates, :admins
          end
        end
      rescue => e
        puts "Aviso: Falha ao remover foreign key: #{e.message}"
      end
      
      ActiveRecord::Migration.class_eval do
        remove_column :templates, :admin_id
      end
    end
    
    puts "Migração de templates concluída!"
  end
end
