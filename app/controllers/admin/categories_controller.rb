class Admin::CategoriesController < Admin::BaseController
  include TheSortableTreeController::Rebuild
  include TheSortableTreeController::ExpandNode

  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.nested_set.roots.select('id, name, slug, parent_id, is_gift').where(:country_code => params[:locale])
  end

  def new
    @category = Category.new
  end

  def expand
    @pages = Category.nested_set.roots.select('id, name, slug, parent_id, is_gift').where(:country_code => params[:locale])
  end

  def edit
  end

  def show
  end

  def create
    @category = Category.new(category_params)
    @category.country_code = params[:locale]
    respond_to do |format|
      if @category.save
        format.html { redirect_to admin_categories_path, notice: t('.notice')}
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to admin_categories_path, notice: t('.notice') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to admin_categories_path, notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :is_gift)
  end

end