class EnsurePasswordDigestForUsers < ActiveRecord::Migration[8.0]
  def change

    unless column_exists?(:users, :password)
      add_column :users, :password, :string
    end

    add_index :users, :email, unique: true unless index_exists?(:users, :email)
  end
end
