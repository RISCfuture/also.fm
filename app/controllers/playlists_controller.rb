require 'addressable/uri'

class PlaylistsController < ApplicationController
  def index
    render current_user ? 'index' : 'splash'
  end

  def name
    return render(json: {title: nil}) unless params[:url].present?

    uri  = Addressable::URI.parse(params[:url].strip)
    html = load_url(uri)
    return render(json: {title: nil}) unless html

    title = load_url_title(html)
    return render(json: {title: nil}) unless title
    title = title.strip.gsub(/\s*\n\s*/, ' ')

    title = load_meta_title(html) if title == 'Connecting to the iTunes Store.'

    name = if title =~ /^iTunes - Music - (.+)$/
             $1
           elsif title =~ /^(.+) on iTunes$/
             $1
           elsif title =~ /^(.+) on Apple Music$/
             $1
           elsif title =~ /^(.+) \| Free Listening on SoundCloud$/
             $1
           elsif title =~ /^(.+) [|\-] YouTube$/
             $1
           else
             nil
           end

    if (title.include?('iTunes') || title.include?('Apple Music')) && (song_title = load_song_title(html, uri))
      name = "#{song_title} - #{name}"
    end


    render json: {title: name ? name[0, 100] : nil}
  end

  private

  def load_url(uri)
    return nil unless %(http https).include?(uri.scheme)

    conn = Faraday.new(url: uri.origin, ssl: {verify: false}) do |f|
      f.use FaradayMiddleware::FollowRedirects
      f.adapter Faraday.default_adapter
    end
    res  = conn.get(uri.request_uri)
    return nil if !res.status || res.status/100 != 2

    Nokogiri::HTML(res.body)
  end

  def load_url_title(html)
    title = html.css('head title').text
    return nil unless title

    return title.gsub(/\\u\d{4}/) do |escape|
      [escape[2..-1].hex].pack('U')
    end
  end

  def load_song_title(html, uri)
    return unless uri.query_values

    song_id = uri.query_values['i']
    return nil unless song_id

    span = html.css("tr[adam-id=\"#{song_id}\"] span[itemprop=\"name\"]")
    return nil unless span

    return span[0].text
  end

  def load_meta_title(html)
    meta = html.css('meta[property="og:title"]')
    return nil unless meta
    return meta[0].attributes['content'].text
  end
end
