# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.where.not(id: current_user.id).includes(avatar_attachment: :blob)
    @received_requests = current_user.received_friendships.where(status: 0).includes(:user)
    @sent_requests = current_user.friendships.where(status: 0).includes(:friend)

    @all_friends = current_user.friendships.where(status: 1).includes(:friend) +
                   current_user.received_friendships.where(status: 1).includes(:user)
  end

  def show
    @user = User.includes(avatar_attachment: :blob).find(params[:id])
    @friendship = Friendship.between(current_user, @user).first
    @is_friend = @friendship&.accepted? || @user == current_user
    @books = @user.books.includes(image_attachment: :blob) if @is_friend
  end
end
