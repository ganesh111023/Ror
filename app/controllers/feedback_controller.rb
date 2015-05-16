class FeedbackController < ApplicationController
  protect_from_forgery

  def index
    @feedback = Feedback.new
    if user_signed_in?
      @feedback.contact = current_user.email
      @feedback.name = current_user.first_name + ' ' + current_user.last_name
    end
  end

  def create
    @feedback = Feedback.new(feedback_params)
    respond_to do |format|
      if @feedback.save
        # PartnerMailer.feedback(@feedback).deliver

        format.html { redirect_to feedback_path, notice: t('feedback_notworking.create.notice') }
        format.json { render action: 'show', status: :created, location: @feedback }
      else
        format.html { render action: 'index' }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:reason, :user_id, :comment, :name, :contact_type, :contact)
  end
end
