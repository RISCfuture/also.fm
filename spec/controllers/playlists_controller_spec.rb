require 'rails_helper'

RSpec.describe PlaylistsController, type: :controller do
  describe '#index' do
    it "should render the index page if logged in" do
      login_as FactoryBot.create(:user)
      get :index
      expect(response.status).to eql(200)
      expect(response).to render_template('index')
    end

    it "should render the splash page if logged out" do
      get :index
      expect(response.status).to eql(200)
      expect(response).to render_template('splash')
    end
  end

  describe '#name' do
    before(:each) { @user = FactoryBot.create(:user) }
    it "should guess a name for a YouTube URL" do
      FakeWeb.register_uri :get,
                           'https://www.youtube.com/user/TheOfficialSkrillex',
                           body: Rails.root.join('spec', 'fixtures', 'youtube.html').read
      get :name, params: {url: 'https://www.youtube.com/user/TheOfficialSkrillex', user_id: @user.to_param}
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"Skrillex"}')
    end

    it "should guess a name for an iTunes URL" do
      FakeWeb.register_uri :get,
                           'https://itunes.apple.com/us/artist/vast/id149550',
                           body: Rails.root.join('spec', 'fixtures', 'itunes.html').read
      get :name, params: {url: 'https://itunes.apple.com/us/artist/vast/id149550', user_id: @user.to_param}
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"VAST"}')
    end

    it "should guess a name for an Apple Music playlist" do
      FakeWeb.register_uri :get,
                           'https://itunes.apple.com/us/playlist/chill-house/idpl.bd55c25265aa4de8b3fc3e0960751846',
                           body: Rails.root.join('spec', 'fixtures', 'itunes_playlist.html').read
      get :name, params: {url: 'https://itunes.apple.com/us/playlist/chill-house/idpl.bd55c25265aa4de8b3fc3e0960751846', user_id: @user.to_param}
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"Chill House by Apple Music Dance"}')
    end

    it "should guess a name for a SoundCloud URL" do
      FakeWeb.register_uri :get,
                           'https://soundcloud.com/nba-youngboy/graffiti',
                           body: Rails.root.join('spec', 'fixtures', 'soundcloud.html').read
      get :name, params: {url: 'https://soundcloud.com/nba-youngboy/graffiti', user_id: @user.to_param}
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"Graffiti by YoungBoy Never Broke Again"}')
    end

    it "should suggest nil for another URL" do
      FakeWeb.register_uri :get,
                           'http://example.com',
                           body: Rails.root.join('spec', 'fixtures', 'example.html').read
      get :name, params: {url: 'http://example.com', user_id: @user.to_param}
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":null}')
    end

    it "should suggest nil for non-HTTP URLs" do
      get :name, params: {url: 'ftp://example.com', user_id: @user.to_param}
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":null}')
    end

    it "should suggest nil for unsuccessful responses" do
      FakeWeb.register_uri :get,
                           'https://soundcloud.com/chidde/josef-salvat-open-season-bootleg-mix',
                           body:   Rails.root.join('spec', 'fixtures', 'youtube.html').read,
                           status: 404
      get :name, params: {url: 'https://soundcloud.com/chidde/josef-salvat-open-season-bootleg-mix', user_id: @user.to_param}
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":null}')
    end

    it "should decode unicode escapes" do
      FakeWeb.register_uri :get,
                           'https://soundcloud.com/vijayandsofia/vijay-sofia-notte-world-of-colors',
                           body: Rails.root.join('spec', 'fixtures', 'unicode.html').read
      get :name, params: {url: 'https://soundcloud.com/vijayandsofia/vijay-sofia-notte-world-of-colors', user_id: @user.to_param}
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"Vijay \\u0026 Sofia, Notte - World Of Colors by Vijay and Sofia"}')
    end

    it "should truncate to 100 characters" do
      FakeWeb.register_uri :get,
                           'https://itunes.apple.com/us/album/cold-water-feat.-justin-bieber/id1151620671?i=1151620691',
                           body: Rails.root.join('spec', 'fixtures', 'long.html').read
      get :name, params: {url: 'https://itunes.apple.com/us/album/cold-water-feat.-justin-bieber/id1151620671?i=1151620691', user_id: @user.to_param}
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"Cold Water (feat. Justin Bieber \\u0026 MØ) [Lost Frequencies Remix] - Cold Water (feat. Justin Bieber \\u0026 M"}')
    end

    it "should guess the name of individual songs in iTunes albums" do
      FakeWeb.register_uri :get,
                           'https://itunes.apple.com/us/album/xx-two-decades-of-love-metal/id776720311?i=776720349',
                           body: Rails.root.join('spec', 'fixtures', 'itunes_song.html').read
      get :name, params: {url: 'https://itunes.apple.com/us/album/xx-two-decades-of-love-metal/id776720311?i=776720349', user_id: @user.to_param}
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"Wicked Game - XX - Two Decades of Love Metal by HIM"}')
    end
  end
end
