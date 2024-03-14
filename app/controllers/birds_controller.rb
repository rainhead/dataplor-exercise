class BirdsController < ApplicationController
  def index
    node_ids = params.require(:node_ids).split(',').map(&:to_i)
    nodes = Node.find(node_ids)
    bird_ids = Bird.for_nodes(nodes).pluck(:id)

    render json: {ids: bird_ids}
  end
end
