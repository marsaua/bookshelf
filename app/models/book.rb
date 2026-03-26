# frozen_string_literal: true

class Book < ApplicationRecord
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
end
