class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [:paypal_notifications, :paypal_return]
  before_filter :checkout_allowed, except: [:paypal_notifications, :paypal_return]
  before_filter :extract_shopping_cart, except: [:paypal_notifications, :paypal_return]

  protect_from_forgery :except => [:paypal_notifications]

  def new
    @order = Order.new
    @order.first_name = current_user.first_name
    @order.last_name  = current_user.last_name
  end

  def paypal_notifications
    Rails.logger.info 'PAYPAL NOTIFICATION'
    Rails.logger.debug YAML::dump(params)

    status = params[:payment_status] == 'Completed' ? Order::STATUS_COMPLETED : Order::STATUS_CANCELED
    @order  = Order.find_by_id(params[:invoice])

    if @order
      @order.update_attributes(:updated_at => Time.now, :status => status)

      t = OrderTransaction.new
      t.order         = @order
      t.amount        = params[:mc_gross]
      t.authorization = params[:txn_id]
      t.message       = params[:payment_status]
      t.params        = params
      t.save

      @cart = ShoppingCart.find_by_id(params[:custom])
      destroy_cart if status == Order::STATUS_COMPLETED
    end

    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

  def paypal_return
    Rails.logger.info 'PAYPAL RETURN'
    Rails.logger.debug YAML::dump(params)

    @order  = Order.find_by_id(params[:order_id])
    session.delete(:shopping_cart_id)
    render :action => "success"
  end

  def choose_payment_index
  end

  def choose_payment
    session[:pmtmthd] = params[:pmtmthd]

    if params[:pmtmthd] == 'paypal'
      make_order_for_paypal

      #return_url = 'http://650ff187.ngrok.com/orders/paypal'
      #notify_url = 'http://650ff187.ngrok.com/orders/paypal_notifications'
      #return redirect_to @cart.paypal_url(return_url, notify_url, @order)
      return redirect_to @cart.paypal_url(paypal_orders_url, paypal_notifications_orders_url, @order)
    end

    if params[:pmtmthd] == 'credit_card'
      return redirect_to new_order_path
    end

    render :nothing => true
  end

  def create
    @order = Order.new(post_params)
    @order.user       = current_user
    @order.amount     = @cart.total/100
    @order.ip_address = request.remote_ip

    if @order.save
      @cart.shopping_cart_items.each do |i|
        item = OrderItem.new
        item.order = @order
        item.product_id = i.item.id
        item.price = @cart.subtotal_for(i.item)/100
        item.quantity = i.quantity
        item.title = i.item.title
        item.save
      end

      if @order.purchase @cart
        destroy_cart
        render :action => "success"
      else
        render :action => "failure"
      end
    else
      render :action => 'new'
    end
  end

  private

  def destroy_cart
    session.delete(:shopping_cart_id)
    @cart.clear
    @cart.destroy
  end

  def make_order_for_paypal
    @order = Order.new
    @order.first_name = current_user.first_name
    @order.last_name  = current_user.last_name
    @order.card_type  = 'paypal'
    @order.user       = current_user
    @order.amount     = @cart.total/100
    @order.ip_address = request.remote_ip

    if @order.save
      @cart.shopping_cart_items.each do |i|
        item = OrderItem.new
        item.order = @order
        item.product_id = i.item.id
        item.price = @cart.subtotal_for(i.item)/100
        item.quantity = i.quantity
        item.title = i.item.title
        item.save
      end
    end
  end

  def checkout_allowed
    redirect_to root_path if !session[:shopping_cart_id]
  end

  def extract_shopping_cart
   @cart = ShoppingCart.find(session[:shopping_cart_id])
  end

  def post_params
    params.require(:order).permit(:first_name, :last_name,
                                  :card_type, :card_number, :card_verification, :card_expires_on,
                                  :country_code, :address1, :address2, :city, :state, :zip, :phone)
  end

end