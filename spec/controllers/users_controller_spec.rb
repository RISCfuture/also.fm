require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe '#new' do
    it "should render the new template" do
      get :new
      expect(response.status).to be(200)
      expect(response).to render_template('new')
      expect(assigns(:user)).to be_kind_of(User)
    end
  end

  describe '#create' do
    before(:each) do
      User.delete_all
      @user_params = FactoryBot.attributes_for(:user)
    end

    it "should create and log in a new user" do
      post :create, params: {user: @user_params}
      expect(response).to redirect_to(root_url)
      user = User.first
      expect(user.username).to eql(@user_params[:username])
      expect(session[:user_id]).to eql(user.id)
    end

    it "should redirect to the :next parameter" do
      post :create, params: {user: @user_params, next: '/foo/bar'}
      expect(response).to redirect_to('/foo/bar')
    end

    it "should handle errors" do
      User.delete_all
      post :create, params: {user: @user_params.merge(password: nil)}
      expect(response).to render_template('new')
      expect(User.count).to be_zero
    end
  end
end
