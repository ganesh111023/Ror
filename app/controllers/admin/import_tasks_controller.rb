class Admin::ImportTasksController < Admin::BaseController
  def destroy
    @task = ImportTask.find(params[:id])
    @task.destroy
    respond_to do |format|
      format.html { redirect_to '/admin/', notice: t('.notice', i:params[:id] ) }
    end
  end
end