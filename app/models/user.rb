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

       has_many :book_requests, foreign_key: :requester_id

       has_many :lent_books, foreign_key: :lender_id
       has_many :borrowed_books, class_name: "LentBook", foreign_key: :borrower_id

       has_many :ratings
       has_many :comments

       has_one_attached :avatar

       def friendship_with(other_user)
              friendships.find_by(friend: other_user) ||
              friendships.find_by(user: other_user)
       end

       def all_friends
              accepted_friends = friendships.accepted.map(&:friend)
              accepted_received = received_friendships.accepted.map(&:user)
              accepted_friends + accepted_received
       end
       def friends
              Friend.where("(user_id = ? OR friend_id = ?) AND status = 1", id, id)
                    .map { |f| f.user_id == id ? f.friend_id : f.user_id }
                    .then { |ids| User.where(id: ids) }
       end
end
