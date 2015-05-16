class CategoriesController < ApplicationController
  layout 'catalog'

  def index
    is_gift = params.include?(:gifts) ? 1 : 0
    @categories = Category.for_tree(params[:locale], is_gift)
    @products   = Product.having_status(:active).featured
  end

  def show
    country     = Country.find(params[:locale])
    @category   = Category.friendly.find(params[:id])
    @categories = Category.for_tree(params[:locale], @category.is_gift)

    if request.path != category_path(@category)
      redirect_to @category, status: :moved_permanently
    end

    @products = country.products
                    .includes(:rating)
                    .references(:rating)
                    .having_status(:active)
                    .where(:category_id => @category)
                    .paginate(:page => params[:page])
                    .order('avg DESC, qty DESC')
  end
end
