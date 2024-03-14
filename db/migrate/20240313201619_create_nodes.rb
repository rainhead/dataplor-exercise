class CreateNodes < ActiveRecord::Migration[7.1]
  def change
    create_table :nodes do |t|
      t.belongs_to :parent, foreign_key: { to_table: :nodes }, null: true
    end
  end
end
