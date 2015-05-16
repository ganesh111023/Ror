class Admin::FeedbacksController < Admin::BaseController
  before_action :set_record, only: [:show, :destroy]

  def index

    if params[:page].blank?
      params[:page] = 1
    end

    if params[:f_ids]
      if params[:delete_button]
        params[:f_ids].each do |id|
          r = Feedback.find(id)
          r.delete
        end
        msg = t('messages.deleted')
      end
      redirect_to admin_feedbacks_path(:page => params[:page]), notice: msg
    end
    @recs = Feedback.paginate(:page => params[:page])
                    .order('id DESC')
  end

  def show
  end


  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @r.destroy
    respond_to do |format|
      format.html { redirect_to admin_feedbacks_path }
      format.json { head :no_content }
    end
  end

  private

  def set_record
    @r = Feedback.find(params[:id])
  end

  def post_params
    params.require(:faq).permit(:question, :answer)
  end
end