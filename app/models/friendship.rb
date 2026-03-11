class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: 0, accepted: 1, rejected: 2 }

  validates :friend_id, uniqueness: { scope: :user_id }

  def self.between(user, other_user)
    find_by(user: user, friend: other_user) ||
    find_by(user: other_user, friend: user)
  end
end
