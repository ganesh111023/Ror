class ShoppingCartsController < ApplicationController
  before_filter :extract_shopping_cart
  before_filter :set_product, only: [:create, :item_destroy, :item_quantity_update]
  protect_from_forgery except: :item_quantity_update

  def create
    @shopping_cart.add(@product, @product.price*100) # TODO: (asshole) price should be in cents.
    redirect_to :back, notice: t('.notice')
  end

  def show
  end

  def item_quantity_update

    @shopping_cart.update_quantity_for(@product, params[:quantity])

    @price = @shopping_cart.subtotal_for @product
    @price = (@price/100).to_money
    @total = (@shopping_cart.total/100).to_money

    respond_to :json
  end

  # Destroy cart item
  def item_destroy
    q = @shopping_cart.quantity_for @product
    @shopping_cart.remove(@product, q)

    if @shopping_cart.shopping_cart_items.any?
      respond_to do |format|
        format.html { redirect_to shopping_cart_path, notice: t('.notice') }
      end
    else
      self.destroy
    end
  end

  # Destroy cart
  def destroy
    session.delete(:shopping_cart_id)
    @shopping_cart.clear
    @shopping_cart.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  private

  def set_product
    @product = Product.friendly.find(params[:product_id])
  end

  def extract_shopping_cart
    shopping_cart_id = session[:shopping_cart_id]
    @shopping_cart = session[:shopping_cart_id] ? ShoppingCart.find(shopping_cart_id) : ShoppingCart.create
    session[:shopping_cart_id] = @shopping_cart.id
  end
end
