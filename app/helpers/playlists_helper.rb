module PlaylistsHelper
  def random_title
    t('helpers.playlists.titles').sample
  end

  def priorities
    t('models.playlist.priorities').map.with_index { |p, i| [p, i] }
  end
end
