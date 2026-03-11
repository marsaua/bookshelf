class User < ApplicationRecord
       devise :database_authenticatable, :registerable,
              :recoverable, :rememberable, :validatable

       has_many :books, dependent: :destroy
       has_many :friendships, dependent: :destroy

       has_many :friends,
              through: :friendships,
              source: :friend

       has_many :received_friendships, class_name: "Friendship",
              foreign_key: :friend_id, dependent: :destroy

       has_many :received_friends,
              through: :received_friendships,
              source: :user

       def friendship_with(other_user)
              friendships.find_by(friend: other_user) ||
              friendships.find_by(user: other_user)
       end
       def all_friends
              accepted_friends = friendships.accepted.map(&:friend)
              accepted_received = received_friendships.accepted.map(&:user)
              accepted_friends + accepted_received
            end
end
