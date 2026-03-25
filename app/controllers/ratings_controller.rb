# frozen_string_literal: true

class RatingsController < ApplicationController
  before_action :set_rating, only: [:update]

  def create
    @rating = Rating.find_or_initialize_by(user: current_user, book_id: params[:rating][:book_id])
    @rating.value = params[:rating][:value]
    @rating.save
    redirect_back fallback_location: books_path
  end

  def update
    @rating.update(value: params[:rating][:value])
    redirect_back fallback_location: books_path
  end

  private

  def set_rating
    @rating = current_user.ratings.find(params[:id])
  end
end
