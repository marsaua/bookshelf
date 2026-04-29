# frozen_string_literal: true

class FriendshipsController < ApplicationController
  def create
    friendship = Friendship.new(
      user: current_user,
      friend_id: params[:friend_id],
      status: :pending
    )
    if friendship.save
      UserMailer.friendship_request(friendship.friend, current_user).deliver_later
      redirect_to users_path, alert: 'Your request has been sent'
    else
      redirect_to users_path, alert: friendship.errors.full_messages.first
    end
  end

  def update
    friendship = Friendship.find(params[:id])
    friendship.accepted!
    redirect_to users_path
  end

  def destroy
    Friendship.find(params[:id]).destroy
    redirect_to users_path
  end
end
