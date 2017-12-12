require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe '#new' do
    it "should render the login page" do
      get :new
      expect(response.status).to eql(200)
      expect(response).to render_template('new')
    end
  end

  describe '#create' do
    before(:all) { @user = FactoryBot.create(:user, username: 'user', password: 'password123') }

    it "should reject an unknown username" do
      post :create, params: {username: 'user123', password: 'password123'}
      expect(response).to render_template('new')
      expect(assigns(:username)).to eql('user123')
    end

    it "should reject an invalid password" do
      post :create, params: {username: 'user', password: 'password'}
      expect(response).to render_template('new')
      expect(assigns(:username)).to eql('user')
    end

    context '[valid login and password]' do
      it "should log the user in" do
        post :create, params: {username: 'user', password: 'password123'}
      end

      it "should redirect to the :next parameter if given" do
        post :create, params: {username: 'user', password: 'password123', next: '/foo/bar'}
        expect(session[:user_id]).to eql(@user.id)
        expect(response).to redirect_to('/foo/bar')
      end

      it "should redirect to the root URL otherwise" do
        post :create, params: {username: 'user', password: 'password123'}
        expect(session[:user_id]).to eql(@user.id)
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe '#destroy' do
    before(:each) { login_as FactoryBot.create(:user) }

    it "should log the user out" do
      delete :destroy
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_url)
    end
  end
end
