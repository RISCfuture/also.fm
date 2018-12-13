class SessionsController < ApplicationController
  before_action :login_required, only: :destroy
  before_action :must_be_unauthenticated, except: :destroy
  responders :flash

  def new
  end

  def create
    @user = User.find_by_username(params[:username])
    if @user&.valid_password?(params[:password])
      log_in @user
      respond_to do |format|
        format.html { redirect_to params[:next] || root_url }
        format.any { head :ok }
      end
    else
      @username = params[:username]
      render 'new'
    end
  end

  def destroy
    log_out
    respond_to do |format|
      format.html { redirect_to root_url }
      format.any { head :ok }
    end
  end
end
