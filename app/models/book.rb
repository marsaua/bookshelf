# frozen_string_literal: true

class Book < ApplicationRecord

  searchkick word_start: [:title, :author, :description]
  
  belongs_to :user

  validates :title, presence: true

  has_one_attached :image

  has_many :book_requests, dependent: :destroy

  has_one :active_lent, -> { active }, class_name: 'LentBook'

  has_many :ratings
  has_many :comments

  def average_rating
    ratings.average(:value)&.round(1)
  end

  def lent?
    active_lent.present?
  end

  def search_data
    {
      title:  title,
      author: author,
      description: description,
      category: category,
      publisher: publisher,
      language: language,
      page_count: page_count
    }
  end
end
