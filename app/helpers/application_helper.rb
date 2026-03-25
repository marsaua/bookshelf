# frozen_string_literal: true

module ApplicationHelper
  def rating_path_for(book, user, _star)
    rating = user.ratings.find_by(book: book)
    rating ? rating_path(rating) : ratings_path
  end

  def current_user_rating(book, user)
    user.ratings.find_by(book: book)
  end
end
