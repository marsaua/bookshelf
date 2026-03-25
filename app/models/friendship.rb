# frozen_string_literal: true

class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  enum :status, { pending: 0, accepted: 1, rejected: 2 }

  validates :friend_id, uniqueness: { scope: :user_id }

  def self.between(user_a, user_b)
    where(user_id: user_a, friend_id: user_b)
      .or(where(user_id: user_b, friend_id: user_a))
  end
end
