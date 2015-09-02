module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def log_in(user)
    session[:user_id] = user.id
    @current_user     = user
  end

  def log_out
    session[:user_id] = nil
    @current_user     = nil
  end

  protected

  def login_required
    if logged_in?
      return true
    else
      respond_to do |format|
        format.html { redirect_to login_url, next: request.original_url }
        format.any { head :forbidden }
      end
    end
  end

  def must_be_unauthenticated
    if logged_in?
      respond_to do |format|
        format.html { redirect_to root_url }
        format.any { head :forbidden }
      end
    else
      return true
    end
  end
end
