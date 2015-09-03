class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Authentication

  # @return [String] The name of the template being rendered.
  attr_accessor :current_template
  helper_method :current_template

  # @private
  def _render_template(options, *other_stuff)
    self.current_template = options[:template]
    super
  end
end
