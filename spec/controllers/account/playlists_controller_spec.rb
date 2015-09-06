require 'rails_helper'

RSpec.describe Account::PlaylistsController, type: :controller do
  describe '#index' do
    before :all do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create :playlist, for_user: @user, name: 'name1', url: 'http://url1.com', created_at: 4.days.ago, listened_at: nil, priority: 1
      FactoryGirl.create :playlist, for_user: @user, name: 'name2', url: 'http://url2.com', created_at: 3.days.ago, listened_at: nil, priority: 1
      tag1 = FactoryGirl.create(:playlist, for_user: @user, name: 'name3', url: 'http://url3.com', created_at: 2.days.ago, listened_at: nil, priority: 1)
      tag2 = FactoryGirl.create(:playlist, for_user: @user, name: 'name4', url: 'http://url4.com', created_at: 1.days.ago, listened_at: nil, priority: 1)
      FactoryGirl.create :tag, name: 'tag', playlist: tag1
      FactoryGirl.create :tag, name: 'tag', playlist: tag2

      FactoryGirl.create :playlist, for_user: @user, priority: 2
      FactoryGirl.create :playlist, for_user: @user, listened_at: Time.now
    end

    it "should require a logged-in user" do
      get :index, format: 'json'
      expect(response.status).to eql(403)
    end

    context '[logged in]' do
      before(:each) { login_as @user }
      render_views

      it "should load the current user's playlists" do
        get :index, format: 'json', priority: '1'
        expect(response.status).to eql(200)
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(%w(name4 name3 name2 name1))
      end

      it "should filter by tag" do
        get :index, tag: 'tag', format: 'json', priority: '1'
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(%w(name4 name3))
      end
    end
  end

  describe '#ack' do
    before :each do
      @user = FactoryGirl.create(:user)
      @playlist = FactoryGirl.create(:playlist, for_user: @user, listened_at: nil)
    end

    it "should require a logged-in user" do
      patch :ack, id: @playlist.to_param, format: 'json'
      expect(response.status).to eql(403)
    end

    context '[logged in]' do
      before(:each) { login_as @user }

      it "should mark a song as listened" do
        patch :ack, id: @playlist.to_param, format: 'json'
        expect(@playlist.reload.listened_at).to eql(Time.now)
        expect(response.status).to eql(200)
        expect(response.body).to eql('{"listened_at":"1982-10-19T12:13:00.000-07:00"}')
      end

      it "should not allow you to ack someone else's song" do
        playlist = FactoryGirl.create(:playlist, listened_at: nil)
        patch :ack, id: playlist.to_param, format: 'json'
        expect(response.status).to eql(404)
        expect(playlist.reload.listened_at).to be_nil
      end
    end
  end
end
