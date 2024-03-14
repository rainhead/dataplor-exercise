class AddForeignKeyToBirdNodeId < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :birds, :nodes
  end
end
