class Bird < ApplicationRecord
  belongs_to :node

  def self.for_nodes(nodes)
    nodes_and_descendants = <<~SQL
JOIN (
  WITH RECURSIVE descendants (id) AS (
  SELECT id FROM nodes WHERE id IN (:ids)
  UNION ALL
  SELECT nodes.id FROM nodes JOIN descendants d ON d.id = nodes.parent_id
  )
  SELECT id AS node_id FROM descendants
) AS node_ids USING (node_id)
    SQL
    joins(sanitize_sql([nodes_and_descendants, {ids: nodes.map(&:id)}]))
  end
end
