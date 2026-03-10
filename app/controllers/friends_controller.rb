class FriendsController < ApplicationController
    before_action :authenticate_user!
  
    def index
      @received_requests = current_user.received_friendships.where(status: 0).includes(:user)
      @sent_requests = current_user.friendships.where(status: 0).includes(:friend)
      
      @all_friends = current_user.friendships.where(status: 1).includes(:friend) +
               current_user.received_friendships.where(status: 1).includes(:user)

    end

  
    def create
      @friendship = current_user.friendships.build(friend_id: params[:id])
      @friendship.save
    end
  
    def accept
      @friendship = Friendship.find_by!(friend_id: current_user.id, user_id: params[:id])
      @friendship.accepted!
    end
  
    def destroy
      @friendship = current_user.friendships.find_by(friend_id: params[:id]) ||
                    current_user.received_friendships.find_by(user_id: params[:id])
      @friendship&.destroy
    end
  end
