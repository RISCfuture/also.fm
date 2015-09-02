class PlaylistMailer < ApplicationMailer

  def new_playlist(playlist)
    return nil unless playlist.for_user.email?

    @playlist = playlist

    mail to:      playlist.for_user.email,
         subject: t('mailers.playlist.new_playlist.subject')
  end
end
