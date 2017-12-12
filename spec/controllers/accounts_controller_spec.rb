require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  describe '#destroy' do
    before(:each) { login_as(@user = FactoryBot.create(:user)) }

    it "should delete the current user's account" do
      delete :destroy
      expect(response).to redirect_to(root_url)
      expect(session[:user_id]).to be_nil
      expect { @user.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
