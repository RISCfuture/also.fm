class ApplicationController < ActionController::Base
  include Authentication

  before_bugsnag_notify :add_user_info_to_bugsnag

  # @return [String] The name of the template being rendered.
  attr_accessor :current_template
  helper_method :current_template

  rescue_from(ActiveRecord::RecordNotFound) do |error|
    respond_to do |format|
      format.html { render file: 'public/404.html', status: :not_found }
      format.json { render json: {error: error}, status: :not_found }
      format.any { head :not_found }
    end
  end

  rescue_from(ActiveRecord::RecordInvalid) do |error|
    respond_to do |format|
      format.html { render file: 'public/422.html', status: :unprocessable_entity }
      format.json { render json: {error: error}, status: :unprocessable_entity }
      format.any { head :unprocessable_entity }
    end
  end

  # @private
  def _render_template(options, *other_stuff)
    self.current_template = options[:template]
    super
  end

  private

  def add_user_info_to_bugsnag(report)
    report.user = {
        id:    current_user.id,
        name:  current_user.username,
        email: current_user.email
    } if logged_in?
  end
end
