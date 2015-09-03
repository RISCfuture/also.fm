module ApplicationHelper
  def random_background_video
    video = Dir.glob(Rails.root.join('app', 'assets', 'videos', 'backgrounds', '*.mov')).sample
    video_url File.join('backgrounds', File.basename(video))
  end

  def try_again
    t('helpers.application.try_again').sample
  end

  # @return [String] Same as `controller_name`, but prepends module names as a
  #   dash-delimited prefix.
  # @example
  #   # (in Foo::BarBazController)
  #   full_controller_name #=> "foo-bar_baz"

  def full_controller_name
    full_controller_path.gsub('/', '-')
  end

  # @return [String] The controller's path under `app/controllers`, and without
  #   the `_controller` suffix.
  # @example
  #   # (in Foo::BarBazController)
  #   full_controller_path #=> "foo/bar_baz"

  def full_controller_path
    controller.class.to_s.underscore.gsub(/_controller$/, '')
  end
end
