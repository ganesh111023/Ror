class Admin::OrdersController < Admin::BaseController

  def index
    @orders_grid = initialize_grid(Order, :name => 'g', :per_page => 20, :order => 'id', :order_direction => 'desc')
  end

  def show
    @order = Order.find(params[:id]);
  end

end