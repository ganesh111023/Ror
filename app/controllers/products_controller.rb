class ProductsController < ApplicationController
  before_action :build_tree
  protect_from_forgery except: :search

  # GET /autocomplete.json
  def autocomplete
    c = Country.by_locale(params['locale'])
    @products = c.products.search(params[:term], 1, 7)
    respond_to :json
  end

  # GET /search
  def search
    c = Country.by_locale(params[:locale])
    @products = c.products.search(params[:term], params[:page]) if params[:term].length >= 3
    respond_to :html
  end

  def show
    @product = Product.friendly.find(params[:id])

    if request.path != product_path(@product.friendly_id)
      redirect_to @product.friendly_id, status: :moved_permanently
    end

    @category = @product.category
    @images   = @product.images.where(is_primary: false)
    @comments = @product.comments.order('id DESC').limit(5)
  end

  private

  def build_tree
    @categories = Category.for_tree(params[:locale])
  end
end
