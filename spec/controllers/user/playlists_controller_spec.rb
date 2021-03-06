require 'rails_helper'
require 'user/playlists_controller'

RSpec.describe User::PlaylistsController, type: :controller do
  describe '#index' do
    context '[HTML]' do
      it "should render the index template" do
        user = FactoryBot.create(:user)
        get :index, params: {user_id: user.to_param}
        expect(response.status).to be(200)
        expect(response).to render_template('index')
        expect(assigns(:user)).to eql(user)
      end
    end

    context '[JSON]' do
      before :all do
        @user = FactoryBot.create(:user)
        Playlist.delete_all
        15.times.each do |i|
          playlist = FactoryBot.create(:playlist, for_user: @user, name: "name#{i}", url: "http://url#{i}.com", created_at: (15-i).days.ago, listened_at: nil, priority: 1, liked: i == 0)
          FactoryBot.create(:tag, name: 'tag', playlist: playlist) if i <= 4
        end

        FactoryBot.create :playlist, for_user: @user, priority: 0, listened_at: nil
      end

      render_views

      it "should load the current user's playlists" do
        get :index, params: {user_id: @user.to_param, format: 'json', priority: '1'}
        expect(response.status).to be(200)
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(14.downto(5).map { |i| "name#{i}" })
        expect(response.headers['X-Page']).to eql('1')
        expect(response.headers['X-Count']).to eql('15')
      end

      it "should filter by tag" do
        get :index, params: {user_id: @user.to_param, tag: 'tag', format: 'json', priority: '1'}
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(4.downto(0).map { |i| "name#{i}" })
        expect(response.headers['X-Page']).to eql('1')
        expect(response.headers['X-Count']).to eql('5')
      end

      it "should filter by liked" do
        get :index, params: {user_id: @user.to_param, liked: 'true', format: 'json', priority: '1'}
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(%w[name0])
        expect(response.headers['X-Page']).to eql('1')
        expect(response.headers['X-Count']).to eql('1')
      end

      it "should paginate" do
        get :index, params: {user_id: @user.to_param, format: 'json', priority: '1', page: '2'}
        expect(response.status).to be(200)
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(4.downto(0).map { |i| "name#{i}" })
        expect(response.headers['X-Page']).to eql('2')
        expect(response.headers['X-Count']).to eql('15')
      end
    end
  end

  describe '#new' do
    it "should render the new template" do
      user = FactoryBot.create(:user)
      get :new, params: {user_id: user.to_param}
      expect(response.status).to be(200)
      expect(response).to render_template('new')
      expect(assigns(:user)).to eql(user)
      expect(assigns(:playlist)).to be_kind_of(Playlist)
    end
  end

  describe '#create' do
    before :each do
      @for_user        = FactoryBot.create(:user)
      @playlist_params = FactoryBot.attributes_for(:playlist)
      Playlist.delete_all
    end

    it "should create a new playlist" do
      post :create, params: {user_id: @for_user.to_param, playlist: @playlist_params}
      expect(response.status).to be(200)
      expect(response).to render_template('create')
      expect(Playlist.count).to be(1)
      expect(Playlist.first.url).to eql(@playlist_params[:url])
      expect(Playlist.first.for_user).to eql(@for_user)
    end

    it "should handle errors" do
      post :create, params: {user_id: @for_user.to_param, playlist: @playlist_params.merge(url: nil)}
      expect(response.status).to be(200)
      expect(response).to render_template('new')
      expect(Playlist.count).to be_zero
    end

    it "should set the from_user if logged in" do
      from_user = FactoryBot.create(:user)
      login_as from_user

      post :create, params: {user_id: @for_user.to_param, playlist: @playlist_params}

      expect(response.status).to be(200)
      expect(Playlist.count).to be(1)
      expect(Playlist.first.from_user).to eql(from_user)
    end
  end
end
