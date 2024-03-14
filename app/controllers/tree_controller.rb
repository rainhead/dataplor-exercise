# frozen_string_literal: true

class TreeController < ApplicationController

  # Returns information
  def common_ancestor
    a, b = params.require(%i[a b])
                 .map(&:to_i)
                 .map { |id| Node.find(id) }

    common_ancestor = Node.common_ancestor(a, b)

    render json: common_ancestor
  end
end
