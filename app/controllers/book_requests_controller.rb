# frozen_string_literal: true

class BookRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book_request, only: %i[accept decline]

  def index
    @incoming = BookRequest.where(book: current_user.books).pending
    @outgoing = current_user.book_requests.where.not(status: :lent)
  end

  def show
    @incoming = BookRequest.where(book: current_user.books)
  end

  def create
    @book_request = BookRequest.new(book_request_params)
    @book_request.requester = current_user
    @book_request.status = 0
    if @book_request.save
      @book = @book_request.book
      BookMailer.ask_to_read(@book.user, @book_request).deliver_later
      redirect_to user_book_path(@book.user, @book), notice: 'Request sent!'
    else
      redirect_back fallback_location: books_path,
                    alert: @book_request.errors.full_messages.join(', ')
    end
  end

  def accept
    @book_request.accepted!
    LentBook.create(
      book: @book_request.book,
      lender: current_user,
      borrower: @book_request.requester,
      lent_at: Time.current
    )
    redirect_to books_path
  end

  def decline
    @book_request.declined!
    redirect_to books_path
  end

  private

  def set_book_request
    @book_request = if action_name.in?(%w[accept decline])
                      BookRequest.joins(:book).where(books: { user_id: current_user.id }).find(params[:id])
                    else
                      current_user.book_requests.find(params[:id])
                    end
  end

  def book_request_params
    params.require(:book_request).permit(:book_id, :message)
  end
end
