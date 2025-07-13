class EnsurePasswordDigestForUsers < ActiveRecord::Migration[8.0]
  def change
    # Esta migração deve garantir que o campo password seja mantido em vez de password_digest
    # Ou seja, não vamos alterar para usar o has_secure_password, manteremos o campo password
    
    # Verificar se a coluna password existe
    unless column_exists?(:users, :password)
      add_column :users, :password, :string
    end

    # Adicionar um índice para melhorar a performance das consultas de autenticação
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
  end
end
