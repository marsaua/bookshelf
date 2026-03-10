require "test_helper"

class UserTest < ActiveSupport::TestCase
  has_many :friendships
  has_many :friends, through: :friendships, 
           source: :friend, 
           -> { where(friendships: { status: :accepted }) }
  
  has_many :received_friendships, class_name: "Friendship", foreign_key: :friend_id
  has_many :pending_requests, through: :received_friendships,
           source: :user,
           -> { where(friendships: { status: :pending }) }
end
