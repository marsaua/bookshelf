# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: %i[show edit update destroy lend]
  before_action :set_book_owner, only: %i[show edit update destroy lend]

  def index
    @categories = current_user.books.where.not(category: [nil, '']).distinct.pluck(:category)
    @my_books = current_user.books.where.not(id: LentBook.active.select(:book_id))
    @lent_books = current_user.books.where(id: LentBook.active.select(:book_id))
    @my_lent_books = LentBook.active.where(lender_id: current_user.id)
    @borrowed_books = LentBook.active.where(borrower_id: current_user.id)

    return unless params[:category].present?

    @my_books = @my_books.where(category: params[:category])
    @lent_books = @lent_books.where(category: params[:category])
  end

  def show
    @borrowed_book = LentBook.find_by(borrower_id: current_user.id, book_id: @book.id)
    @book_request = BookRequest.where(book: @book, requester: current_user).order(created_at: :desc).first
    @comments = Comment.where(book_id: @book.id)
  end

  def new
    @book = Book.new
  end

  def create
    @book = current_user.books.build(book_params)
    if @book.save
      redirect_to book_path(@book), notice: 'Book added!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @book.update(book_params)
      redirect_to book_path(@book)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def lend
    if params[:lent_to_user_id].present? || params[:lent_to_name].present?
      LentBook.create(
        book: @book,
        lender: current_user,
        borrower: User.find_by(id: params[:lent_to_user_id]),
        borrower_name: params[:lent_to_name],
        lent_at: Time.current
      )
    else
      @book.active_lent&.update(returned_at: Time.current)
    end
    redirect_to books_path
  end

  def search
    return render json: [] if params[:query].blank?

    @results = GoogleBooksService.search(params[:query])
    render json: @results
  end

  def destroy
    @book.destroy
    redirect_to books_path
  end

  private

  def set_book
    @book = if action_name == 'show'
              Book.find(params[:id])
            else
              current_user.books.find(params[:id])
            end
  end

  def book_params
    params.require(:book).permit(:title, :author, :description, :cover_url, :image, :category, :publisher, :language,
                                 :page_count)
  end

  def set_book_owner
    @book_owner = @book.user_id == current_user.id
  end
end
