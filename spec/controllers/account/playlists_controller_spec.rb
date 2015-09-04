require 'rails_helper'

RSpec.describe Account::PlaylistsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #ack" do
    it "returns http success" do
      get :ack
      expect(response).to have_http_status(:success)
    end
  end

end
