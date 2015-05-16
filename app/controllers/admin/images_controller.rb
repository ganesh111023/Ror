class Admin::ImagesController < Admin::BaseController

  before_action :set_product

  def edit
    Image.where(:product_id => @product.id, :is_primary => true).update_all(:is_primary => false)
    i = Image.find(params[:id])
    i.is_primary = true
    i.save
    redirect_to admin_product_images_path(@product)
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    respond_to do |format|
      format.html { redirect_to admin_product_images_path(@product), notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  def create
    def_img = Image.where(:product_id => @product.id, :is_primary => true)
    h = {:image_filename => params[:image], :product_id => @product.id}
    h[:is_primary] = true unless def_img.any?

    Image.create(h) if params[:image]
    redirect_to admin_product_images_path(@product)
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

end