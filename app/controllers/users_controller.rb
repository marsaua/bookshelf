class UsersController < ApplicationController
  def index
    @users = User.where.not(id: current_user.id)
                 .select(:id, :email, :avatar, :first_name, :last_name)
  end

  def show
    @user = User.find(params[:id])
  end
end
