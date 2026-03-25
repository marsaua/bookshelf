# frozen_string_literal: true

class LentBooksController < ApplicationController
  def index
    @my_lent_books = LentBook.where(lender_id: current_user.id)
    @borrowed_books = LentBook.where(borrower_id: current_user.id)
  end
end
