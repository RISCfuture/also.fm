class AccountsController < ApplicationController
  before_action :login_required
  respond_to :html
  responders :flash

  def destroy
    current_user.destroy
    log_out
    respond_with current_user, location: login_url
  end
end
