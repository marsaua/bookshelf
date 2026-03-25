# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.where.not(id: current_user.id)
                 .select(:id, :email, :avatar, :first_name, :last_name)
    @received_requests = current_user.received_friendships.where(status: 0).includes(:user)
    @sent_requests = current_user.friendships.where(status: 0).includes(:friend)

    @all_friends = current_user.friendships.where(status: 1).includes(:friend) +
                   current_user.received_friendships.where(status: 1).includes(:user)
  end

  def show
    @user = User.find(params[:id])
  end
end
