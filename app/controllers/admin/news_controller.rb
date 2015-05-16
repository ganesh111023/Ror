class Admin::NewsController < Admin::BaseController

  def new
    @news = News.new
  end

  def edit
    @news = News.find(params[:id])
  end

  def update
    @news = News.find(params[:id])
    if @news.update(post_params)
      redirect_to [:admin, @news]
    else
      render 'edit'
    end
  end

  def index
    if params[:page].blank?
      params[:page] = 1
    end

    if params[:News_ids]
      columnName = params[:active_button] ? 'is_active' : 'admin'
      params[:News_ids].each do |id|
        r = News.find(id)
        r.toggle "#{columnName}";
        r.save
      end

      redirect_to admin_Newss_path(:page => params[:page]), notice: t('messages.updated')
    end

    @news = News.paginate(:page => params[:page]).
                  order('id DESC')
  end

  def destroy
    @news = News.find(params[:id]);
    @news.destroy
    respond_to do |format|
      format.html { redirect_to admin_news_index_path, notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  def show
    @news = News.find(params[:id]);
  end

  def create
    @news = News.new(post_params)
    if @news.save
      redirect_to [:admin, @news]
    else
      render 'new'
    end
  end

  private
  def post_params
    params.require(:news).permit(:title, :body)
  end

end