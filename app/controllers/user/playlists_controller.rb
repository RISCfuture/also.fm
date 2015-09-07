class User::PlaylistsController < ApplicationController
  before_action :find_user
  respond_to :html, :json

  def index
    if params[:tag].present?
      @playlists = Tag.where(name: params[:tag]).joins(playlist: [:tags]).
          where(playlists: {for_user_id: @user.id}) # adding :from_user to this association breaks the SQL query
    else
      @playlists = @user.received_playlists.includes(:from_user, :tags)
    end

    @playlists = @playlists.where(playlists: {priority: params[:priority]}).
        order('playlists.created_at DESC')

    page = params[:page].to_i
    page = 1 if page < 1

    response.headers['X-Page']  = page.to_s
    response.headers['X-Count'] = @playlists.count.to_s

    @playlists = @playlists.limit(10).offset((page-1)*10)
    @playlists = @playlists.map(&:playlist) if params[:tag].present?

    respond_with @playlists
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
          Rails.logger.warn "Playlist errors: #{@playlist.errors.inspect}"
          render 'new'
        end
      end
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
