class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :set_product

  # GET /comments
  def index
    @comments = @product.comments.paginate(:page => params[:page]).order('id DESC')
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # POST /comments
  def create
    @comment = Comment.new(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to product_path(@product.friendly_id), notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_product
      @product = Product.friendly.find(params[:product_id])
    end

    def comment_params
      params.require(:comment).permit(:body, :product_id, :user_id)
    end
end
