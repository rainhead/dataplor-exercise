require "test_helper"

describe Bird do
  describe "for_nodes" do
    describe "with no birds" do
      before do
        @node = Node.create!
      end

      it "returns no birds" do
        assert_empty Bird.for_nodes([@node])
      end
    end

    describe "with a single bird and its node" do
      before do
        @node = Node.create!
        @bird = Bird.create!(node: @node)
      end

      it "returns the bird" do
        assert_equal [@bird], Bird.for_nodes([@node])
      end
    end

    describe "with multiple nodes" do
      before do
        @root = Node.create!
        @root_bird = Bird.create!(node: @root)

        @child1 = Node.create!(parent: @root)
        @child1_bird = Bird.create!(node: @child1)

        @child2 = Node.create!(parent: @root)
        @child2_bird1 = Bird.create!(node: @child2)
        @child2_bird2 = Bird.create!(node: @child2)

        @root2 = Node.create!
        @root2_bird = Bird.create!(node: @root2)
      end

      it "finds all birds belonging to a node" do
        assert_equal [@child2_bird1, @child2_bird2], Bird.for_nodes([@child2]).order(id: :asc)
      end

      it "finds the birds of descendant nodes" do
        birds = Bird.for_nodes([@root])
        assert_includes(birds, @child2_bird2)
        refute_includes(birds, @root2_bird)
      end
    end
  end
end
