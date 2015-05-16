class Admin::UsersController < Admin::BaseController

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(post_params)
      redirect_to [:admin, @user]
    else
      render 'edit'
    end
  end

  def index
    if params[:page].blank?
      params[:page] = 1
    end

    if params[:user_ids]
      columnName = params[:active_button] ? 'is_active' : 'admin'
      params[:user_ids].each do |id|
        r = User.find(id)
        r.toggle "#{columnName}";
        r.save
      end

      redirect_to admin_users_path(:page => params[:page]), notice: t('messages.updated')
    end

    @users = User.paginate(:page => params[:page]).
                  order('id DESC')
  end

  def show
    @user = User.find(params[:id]);
  end

  def destroy
    @user = User.find(params[:id])
    @user.is_active = false
    @user.save
    respond_to do |format|
      format.html { redirect_to admin_users_path, notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  def create
    @user = User.new(post_params)
    if @user.save
      redirect_to [:admin, @user]
    else
      render 'new'
    end
  end

  private
  def post_params
    params.require(:user).permit(:first_name, :last_name, :password, :email, :user_ids)
  end

end