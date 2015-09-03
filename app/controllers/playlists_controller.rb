require 'addressable/uri'

class PlaylistsController < ApplicationController
  before_action :login_required, only: :ack
  before_action :find_user, except: [:index, :ack, :name]
  respond_to :html

  def index
    if current_user
      if params[:tag].present?
        @playlists = Tag.where(name: params[:tag]).joins(:playlist).
            where(playlists: {for_user_id: current_user.id})
      else
        @playlists = current_user.received_playlists
      end

      @playlists = @playlists.where(playlists: {listened_at: nil}).
          order('playlists.priority DESC, playlists.created_at DESC').
          limit(100)

      @playlists = @playlists.map(&:playlist) if params[:tag].present?

      respond_with @playlists
    else
      respond_to do |format|
        format.html { render 'splash' }
        format.any { head :forbidden }
      end
    end
  end

  def list
    if params[:tag].present?
      @playlists = Tag.where(name: params[:tag]).joins(:playlist).
          where(playlists: {for_user_id: @user.id})
    else
      @playlists = @user.received_playlists
    end

    @playlists = @playlists.where(playlists: {listened_at: nil}).
        order('playlists.priority DESC, playlists.created_at DESC').
        limit(100)

    @playlists = @playlists.map(&:playlist) if params[:tag].present?

    respond_with @playlists do |format|
      format.html { render 'list' }
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
          Rails.logger.warn "Playlist errors: #{@playlist.errors.inspect}"
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

  def name
    return render(json: {title: nil}) unless params[:url].present?

    title = load_url_title(params[:url])
    return render(json: {title: nil}) unless title

    name = if title =~ /^iTunes - Music - (.+)$/
             $1
           elsif title =~ /^(.+) \| Free Listening on SoundCloud$/
             $1
           elsif title =~ /^(.+) \| YouTube$/
             $1
           else
             nil
           end

    render json: {title: name}
  end

  private

  def find_user
    @user = User.find_by_username!(params[:user_id])
  end

  def optionally_find_user
    find_user
  rescue ActiveRecord::RecordNotFound
  end

  def playlist_params
    params.require(:playlist).permit(:url, :name, :description, :priority, :tag_names)
  end

  def load_url_title(url)
    uri = Addressable::URI.parse(url)
    return nil unless %(http https).include?(uri.scheme)

    conn = Faraday.new(url: uri.origin) do |f|
      f.use FaradayMiddleware::FollowRedirects
      f.adapter Faraday.default_adapter
    end
    res  = conn.get(uri.request_uri)
    return nil if !res.status || res.status/100 != 2

    html = Nokogiri::HTML(res.body)
    return html.css('head title').text
  end
end
