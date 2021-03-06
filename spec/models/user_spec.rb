require 'rails_helper'

RSpec.describe User, type: :model do
  context '[hooks]' do
    describe '#password' do
      it "should encrypt the password" do
        expect(FactoryBot.create(:user, password: 'test123').crypted_password).not_to be_nil
      end

      it "should not change the password if not given" do
        user = FactoryBot.create(:user)
        expect { user.update_attribute :email, 'hi@there.com' }.not_to change(user, :password)
      end
    end
  end

  describe '#valid_password?' do
    before :each do
      @user = FactoryBot.create(:user, username: 'username', password: 'password123')
    end

    it "should return false given an invalid password" do
      expect(@user.valid_password?('wrong')).to be(false)
    end

    it "should return true given a valid password" do
      expect(@user.valid_password?('password123')).to be(true)
    end
  end
end
