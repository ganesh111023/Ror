class Admin::VendorsController < Admin::BaseController

  def new
    @vendor = Vendor.new
  end

  def edit
    @vendor = Vendor.find(params[:id])
  end

  def update
    @vendor = Vendor.find(params[:id])
    if @vendor.update(post_params)
      redirect_to [:admin, @vendor]
    else
      render 'edit'
    end
  end

  def index
    if params[:page].blank?
      params[:page] = 1
    end

    if params[:Vendor_ids]
      columnName = params[:active_button] ? 'is_active' : 'admin'
      params[:Vendor_ids].each do |id|
        r = Vendor.find(id)
        r.toggle "#{columnName}";
        r.save
      end

      redirect_to admin_Vendors_path(:page => params[:page]), notice: t('messages.updated')
    end

    @vendors = Vendor.paginate(:page => params[:page]).
                  order('id DESC')
  end

  def show
    @vendor = Vendor.find(params[:id]);
  end

  def destroy
    @user = Vendor.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_vendors_path, notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  def create
    @vendor = Vendor.new(post_params)
    if @vendor.save
      redirect_to [:admin, @vendor]
    else
      render 'new'
    end
  end

  private
  def post_params
    params.require(:vendor).permit(:name, :markup_percent, :vendor_ids)
  end

end