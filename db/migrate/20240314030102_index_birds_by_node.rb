class IndexBirdsByNode < ActiveRecord::Migration[7.1]
  def change
    change_column_null :birds, :node_id, false
  end
end
