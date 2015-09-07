class Account::PlaylistsController < ApplicationController
  before_action :login_required
  before_action :find_playlist, only: :ack
  respond_to :json

  def index
    if params[:tag].present?
      @playlists = Tag.where(name: params[:tag]).joins(playlist: [:tags]).
          where(playlists: {for_user_id: current_user.id}) # adding :from_user to this association breaks the SQL query
    else
      @playlists = current_user.received_playlists.includes(:from_user, :tags)
    end

    @playlists = @playlists.where(playlists: {listened_at: nil, priority: params[:priority]}).
        order('playlists.created_at DESC')

    page = params[:page].to_i
    page = 1 if page < 1

    response.headers['X-Page']  = page.to_s
    response.headers['X-Count'] = @playlists.count.to_s

    @playlists = @playlists.limit(10).offset((page-1)*10)
    @playlists = @playlists.map(&:playlist) if params[:tag].present?

    respond_with @playlists
  end

  def ack
    @playlist.listened_at = @playlist.listened_at ? nil : Time.now
    @playlist.save

    respond_with(@playlist) do |format|
      format.json { render json: {listened_at: @playlist.listened_at} }
    end
  end

  private

  def find_playlist
    @playlist = current_user.received_playlists.find(params[:id])
  end
end
