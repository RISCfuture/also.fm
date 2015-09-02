module ApplicationHelper
  def random_background_video
    video = Dir.glob(Rails.root.join('app', 'assets', 'videos', 'backgrounds', '*.mov')).sample
    video_url File.join('backgrounds', File.basename(video))
  end

  def try_again
    t('helpers.application.try_again').sample
  end
end
