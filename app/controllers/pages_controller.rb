# frozen_string_literal: true

class PagesController < ApplicationController
  def whats_new
    return unless user_signed_in?

    friend_ids = current_user.all_friends.map(&:id)
    @books = Book.where(user_id: friend_ids).order(created_at: :desc).limit(10)

    @best_books = Book.joins(:ratings)
                      .select('books.*, AVG(ratings.value) as avg_rating')
                      .group('books.id')
                      .order('avg_rating DESC')
                      .limit(5)
  end
end
