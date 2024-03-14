# frozen_string_literal: true

class Node < ApplicationRecord
  belongs_to :parent, class_name: "Node", required: false
  has_many :birds

  def self.common_ancestor(a, b)
    # params: a_id, b_id
    # Returns either zero or two rows. If no rows are returned, the two nodes do not share an ancestor. If two rows are
    # returned, the first is the lowest common ancestor, and the second is the common root.
    common_ancestors_query = <<~SQL
WITH RECURSIVE a_ancestors(id, parent_id, height) AS (
  SELECT id, parent_id, 0 FROM nodes WHERE id = :a_id
  UNION ALL
  SELECT nodes.id, nodes.parent_id, height + 1
  FROM nodes JOIN a_ancestors ON nodes.id = a_ancestors.parent_id
),
b_ancestors(id, parent_id) AS (
  SELECT id, parent_id FROM nodes WHERE id = :b_id
  UNION ALL
  SELECT nodes.id, nodes.parent_id
  FROM nodes JOIN b_ancestors ON nodes.id = b_ancestors.parent_id
),
common_ancestors(id, height) AS (
  SELECT a_ancestors.id, height
  FROM a_ancestors JOIN b_ancestors USING (id)
)
(SELECT id, height FROM common_ancestors ORDER BY height      LIMIT 1)
UNION ALL -- NB: scans common_ancestors twice!
(SELECT id, height FROM common_ancestors ORDER BY height DESC LIMIT 1)
SQL

    lca, root = connection.select_all sanitize_sql([common_ancestors_query, {a_id: a.id, b_id: b.id}])
    if lca
      lca_depth = 1 + (root['height'] - lca['height'])
      {root_id: root['id'], lowest_common_ancestor: lca['id'], depth: lca_depth}
    else
      {root_id: nil, lowest_common_ancestor: nil, depth: nil}
    end
  end
end
