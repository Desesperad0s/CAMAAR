class AddDepartamentoToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference  :users, :departamento, foreign_key: true
  end
end
