class UsersController < ApplicationController
  before_action :must_be_unauthenticated
  respond_to :html

  def new
    @user = User.new
    respond_with @user
  end

  def create
    @user = User.create(user_params)
    log_in @user
    respond_with @user, location: (params[:next] || root_url)
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation, :email)
  end
end
