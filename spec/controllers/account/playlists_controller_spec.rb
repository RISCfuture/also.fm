require 'rails_helper'

RSpec.describe Account::PlaylistsController, type: :controller do
  describe '#index' do
    before :all do
      @user = FactoryGirl.create(:user)
      15.times.each do |i|
        playlist = FactoryGirl.create(:playlist, for_user: @user, name: "name#{i}", url: "http://url#{i}.com", created_at: (15-i).days.ago, listened_at: nil, priority: 1)
        FactoryGirl.create(:tag, name: 'tag', playlist: playlist) if i <= 4
      end

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
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(14.downto(5).map { |i| "name#{i}" })
        expect(response.headers['X-Page']).to eql('1')
        expect(response.headers['X-Count']).to eql('15')
      end

      it "should filter by tag" do
        get :index, tag: 'tag', format: 'json', priority: '1'
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(4.downto(0).map { |i| "name#{i}" })
        expect(response.headers['X-Page']).to eql('1')
        expect(response.headers['X-Count']).to eql('5')
      end

      it "should paginate" do
        get :index, user_id: @user.to_param, format: 'json', priority: '1', page: '2'
        expect(response.status).to eql(200)
        expect(JSON.parse(response.body).map { |j| j['name'] }).to eql(4.downto(0).map { |i| "name#{i}" })
        expect(response.headers['X-Page']).to eql('2')
        expect(response.headers['X-Count']).to eql('15')
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
