class NavNodesController < ApplicationController

  def update
    @nav_node = NavNode.find params[:id]
    authorize! :update, @nav_node

    @nav_node.update! nav_node_params
    render json: @nav_node, status: :ok
  end

  private

  def nav_node_params
    params.require(:nav_node).permit :breadcrumb_item, :slim_breadcrumb,
      :hidden_menu, :menu_item, :slim_menu,
      :slim_url, :url_component,
      :hidden_teaser_box
  end
end