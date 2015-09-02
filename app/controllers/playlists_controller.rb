class PlaylistsController < ApplicationController
  before_action :login_required, only: :ack
  before_action :find_user, except: [:index, :ack]
  respond_to :html

  def index
    if current_user
      @playlists = current_user.received_playlists.where(listened_at: nil).order(priority: :desc, created_at: :desc).limit(100)
      respond_with @playlists
    else
      respond_to do |format|
        format.html { render 'splash' }
        format.any { head :forbidden }
      end
    end
  end

  def new
    @playlist = @user.sent_playlists.build(from_user: current_user)
    respond_with @playlist
  end

  def create
    @playlist = @user.received_playlists.create(playlist_params.merge(from_user: current_user))
    respond_with @playlist do |format|
      format.html do
        if @playlist.valid?
          render 'create'
        else
          render 'new'
        end
      end
    end
  end

  def ack
    @playlist = current_user.received_playlists.find(params[:id])

    @playlist.listened_at = @playlist.listened_at ? nil : Time.now
    @playlist.save

    respond_to do |format|
      format.json { render json: {listened_at: @playlist.listened_at} }
    end
  end

  private

  def find_user
    @user = User.find_by_username!(params[:user_id])
  end

  def playlist_params
    params.require(:playlist).permit(:url, :name, :description, :priority, :tag_names)
  end
end
