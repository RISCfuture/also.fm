require 'rails_helper'

RSpec.describe PlaylistsController, type: :controller do
  describe '#index' do
    it "should render the index page if logged in" do
      login_as FactoryGirl.create(:user)
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
    before(:each) { @user = FactoryGirl.create(:user) }
    it "should guess a name for a YouTube URL" do
      FakeWeb.register_uri :get,
                           'https://www.youtube.com/user/TheOfficialSkrillex',
                           body: Rails.root.join('spec', 'fixtures', 'youtube.html').read
      get :name, url: 'https://www.youtube.com/user/TheOfficialSkrillex', user_id: @user.to_param
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"Skrillex"}')
    end

    it "should guess a name for an iTunes URL" do
      FakeWeb.register_uri :get,
                           'https://itunes.apple.com/us/artist/vast/id149550',
                           body: Rails.root.join('spec', 'fixtures', 'itunes.html').read
      get :name, url: 'https://itunes.apple.com/us/artist/vast/id149550', user_id: @user.to_param
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"VAST"}')
    end

    it "should guess a name for a SoundCloud URL" do
      FakeWeb.register_uri :get,
                           'https://soundcloud.com/chidde/josef-salvat-open-season-bootleg-mix',
                           body: Rails.root.join('spec', 'fixtures', 'soundcloud.html').read
      get :name, url: 'https://soundcloud.com/chidde/josef-salvat-open-season-bootleg-mix', user_id: @user.to_param
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"Josef Salvat - Open Season [Bootleg Mix] by Chiddeh"}')
    end

    it "should suggest nil for another URL" do
      FakeWeb.register_uri :get,
                           'http://example.com',
                           body: Rails.root.join('spec', 'fixtures', 'example.html').read
      get :name, url: 'http://example.com', user_id: @user.to_param
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":null}')
    end

    it "should suggest nil for non-HTTP URLs" do
      get :name, url: 'ftp://example.com', user_id: @user.to_param
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":null}')
    end

    it "should suggest nil for unsuccessful responses" do
      FakeWeb.register_uri :get,
                           'https://soundcloud.com/chidde/josef-salvat-open-season-bootleg-mix',
                           body:   Rails.root.join('spec', 'fixtures', 'youtube.html').read,
                           status: 404
      get :name, url: 'https://soundcloud.com/chidde/josef-salvat-open-season-bootleg-mix', user_id: @user.to_param
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":null}')
    end

    it "should decode unicode escapes" do
      FakeWeb.register_uri :get,
                           'https://www.youtube.com/user/TheOfficialSkrillex',
                           body: Rails.root.join('spec', 'fixtures', 'unicode.html').read
      get :name, url: 'https://www.youtube.com/user/TheOfficialSkrillex', user_id: @user.to_param
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"Vijay \\u0026 Sofia Zlatko"}')
    end

    it "should truncate to 100 characters" do
      FakeWeb.register_uri :get,
                           'https://www.youtube.com/user/TheOfficialSkrillex',
                           body: Rails.root.join('spec', 'fixtures', 'long.html').read
      get :name, url: 'https://www.youtube.com/user/TheOfficialSkrillex', user_id: @user.to_param
      expect(response.status).to eql(200)
      expect(response.body).to eql('{"title":"Vijay Sofia Zlatko, Kasúal feat. Xavier Dunn - Fuckin\' Problems (Instrumental) by Vijay and Sofia Mo"}')
    end
  end
end
