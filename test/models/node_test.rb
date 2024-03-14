require "test_helper"

describe Node do
  describe "common ancestors" do
    describe "of trees with different roots" do
      before do
        @a = Node.create!(parent: Node.create!)
        @b = Node.create!
      end

      it "returns a null response" do
        result = Node.common_ancestor(@a, @b)
        _(result).must_equal({root_id: nil, lowest_common_ancestor: nil, depth: nil})
      end
    end

    describe "of a tree with its subtree" do
      before do
        @root = Node.create!
        @lca = Node.create!(parent: @root)
        @subtree = Node.create!(parent: @lca)
      end

      it "returns the tree" do
        _(Node.common_ancestor(@lca, @subtree))
          .must_equal({root_id: @root.id, lowest_common_ancestor: @lca.id, depth: 2})
      end

      it "is not sensitive to argument order" do
        _(Node.common_ancestor(@lca, @subtree))
          .must_equal(Node.common_ancestor(@subtree, @lca))
      end
    end

    describe "of a node with itself" do
      before do
        @root = Node.create!
      end

      it "identifies the node as its own lowest common ancestor" do
        _(Node.common_ancestor(@root, @root))
          .must_equal({root_id: @root.id, lowest_common_ancestor: @root.id, depth: 1})
      end
    end
  end
end
