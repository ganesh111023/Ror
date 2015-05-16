class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :featured_destroy]
  before_action :set_categories, only: [:new, :edit, :create]

  def import

    begin
      opts = {:input_currency => params[:currency], :vendor_id => params[:vendor_id]}
      opts[:url] = params[:url] unless params[:url].blank?
      opts[:extension] = params[:extension] unless params[:extension].blank?
      opts[:import_type] = ImportTask.import_type.find_value(params[:import_type]).value
      opts[:locale] = params[:locale]
      if params.include?(:recurring_import)

        if params[:url].blank?
          return redirect_to import_admin_products_path, :flash => { :error => 'Для этой опции необходим URL' }
        end

        t = ImportTask.find_or_create_by(file_url: params[:url], vendor_id: params[:vendor_id])
        t.file_extension  = params[:extension]
        t.currency        = params[:currency]
        t.import_type     = params[:import_type]
        t.country_code    = params[:locale]
        t.save
      end

      r = Product.import(params[:file], opts)

      redirect_to admin_products_url, notice: t('.notice', np: r[:new_products], up: r[:updated_products], nc: r[:new_categories])
    rescue RuntimeError => e
      redirect_to import_admin_products_path, :flash => { :error => e.message }
    end

  end

  def import_index
  end

  # GET /products
  # GET /products.json
  def index
    @products_grid = initialize_grid(Product, :name => 'g', :per_page => 20, :order => 'id', :order_direction => 'desc')

    if params[:g] && params[:g][:selected]
      selected = params[:g][:selected]
      action   = params[:action_box]
      h = {}

        if action == 'status_edit'
          h = {:status => Product::STATUS_EDIT}
        elsif action == 'status_delete'
          h = {:status => Product::STATUS_DELETED}
        elsif action == 'status_active'
          h = {:status => Product::STATUS_ACTIVE}
        elsif action == 'to_featured'
          h = {:is_featured => true}
        end

      Product.where(:id => selected).update_all(h) if h.any?
      redirect_to admin_products_path
    end
  end

  def featured_index
    @featured = Product.featured
  end

  def featured_destroy
    @product.is_featured = false
    @product.save

    redirect_to featured_admin_products_path, notice: t('.notice')
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    3.times { @product.images.build }
  end

  # GET /products/1/edit
  def edit
    Rails.logger.info(@product.inspect)
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save

        unless @product.images.blank?
          img = @product.images.first
          img.is_primary = 1
          img.save
        end
        format.html { redirect_to [:admin, @product], notice: t('.notice') }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to [:admin, @product], notice: t('.notice') }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.status = Product::STATUS_DELETED
    @product.save
    respond_to do |format|
      format.html { redirect_to admin_products_url, notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  private

    def set_categories
      @categories = Category.nested_set.select('id, name, parent_id').all
    end

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :vendor_price, :status, :category_id, :vendor_id, :model, :description, images_attributes: [:id, :product_id, :image_filename], :country_ids => [])
    end
end
