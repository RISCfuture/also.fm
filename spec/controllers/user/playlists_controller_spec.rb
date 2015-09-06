require 'rails_helper'
require 'user/playlists_controller'

RSpec.describe User::PlaylistsController, type: :controller do
  describe '#index' do
    context '[HTML]' do
      it "should render the index template" do
        user = FactoryGirl.create(:user)
        get :index, user_id: user.to_param
        expect(response.status).to eql(200)
        expect(response).to render_template('index')
        expect(assigns(:user)).to eql(user)
      end
    end

    context '[JSON]' do
      before :all do
        @user = FactoryGirl.create(:user)
        Playlist.delete_all
        FactoryGirl.create :playlist, for_user: @user, name: 'name1', url: 'http://url1.com', created_at: 4.days.ago, listened_at: nil, priority: 1
        FactoryGirl.create :playlist, for_user: @user, name: 'name2', url: 'http://url2.com', created_at: 3.days.ago, listened_at: Time.now, priority: 1
        tag1 = FactoryGirl.create(:playlist, for_user: @user, name: 'name3', url: 'http://url3.com', created_at: 2.days.ago, listened_at: nil, priority: 1)
        tag2 = FactoryGirl.create(:playlist, for_user: @user, name: 'name4', url: 'http://url4.com', created_at: 1.days.ago, listened_at: Time.now, priority: 1)
        FactoryGirl.create :tag, name: 'tag', playlist: tag1
        FactoryGirl.create :tag, name: 'tag', playlist: tag2

        FactoryGirl.create :playlist, for_user: @user, priority: 0, listened_at: nil
      end

      render_views

      it "should load the current user's playlists" do
        get :index, user_id: @user.to_param, format: 'json', priority: '1'
        expect(response.status).to eql(200)
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(%w(name4 name3 name2 name1))
      end

      it "should filter by tag" do
        get :index, user_id: @user.to_param, tag: 'tag', format: 'json', priority: '1'
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(%w(name4 name3))
      end
    end
  end

  describe '#new' do
    it "should render the new template" do
      user = FactoryGirl.create(:user)
      get :new, user_id: user.to_param
      expect(response.status).to eql(200)
      expect(response).to render_template('new')
      expect(assigns(:user)).to eql(user)
      expect(assigns(:playlist)).to be_kind_of(Playlist)
    end
  end

  describe '#create' do
    before :each do
      @for_user = FactoryGirl.create(:user)
      @playlist_params = FactoryGirl.attributes_for(:playlist)
      Playlist.delete_all
    end

    it "should create a new playlist" do
      post :create, user_id: @for_user.to_param, playlist: @playlist_params
      expect(response.status).to eql(200)
      expect(response).to render_template('create')
      expect(Playlist.count).to eql(1)
      expect(Playlist.first.url).to eql(@playlist_params[:url])
      expect(Playlist.first.for_user).to eql(@for_user)
    end

    it "should handle errors" do
      post :create, user_id: @for_user.to_param, playlist: @playlist_params.merge(url: nil)
      expect(response.status).to eql(200)
      expect(response).to render_template('new')
      expect(Playlist.count).to be_zero
    end

    it "should set the from_user if logged in" do
      from_user = FactoryGirl.create(:user)
      login_as from_user

      post :create, user_id: @for_user.to_param, playlist: @playlist_params

      expect(response.status).to eql(200)
      expect(Playlist.count).to eql(1)
      expect(Playlist.first.from_user).to eql(from_user)
    end
  end
end
