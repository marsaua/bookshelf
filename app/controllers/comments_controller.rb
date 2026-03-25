# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[edit update destroy]

  def index
    @comments = Comment.find_by(book_id: @book.id)
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_back fallback_location: books_path
    else
      redirect_back fallback_location: books_path, alert: @comment.errors.full_messages.join(', ')
    end
  end

  def edit; end

  def update
    if @comment.update(comment_params)
      redirect_to books_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    redirect_to book_path(@comment.book)
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :book_id)
  end
end
