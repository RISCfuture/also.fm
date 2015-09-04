require 'addressable/uri'

class PlaylistsController < ApplicationController
  respond_to :html

  def index
    render current_user ? 'index' : 'splash'
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
