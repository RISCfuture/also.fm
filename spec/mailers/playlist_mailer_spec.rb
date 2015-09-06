require 'rails_helper'

RSpec.describe PlaylistMailer, type: :mailer do
  describe '#new_playlist' do
    it "should send an email to the for_user" do
      user     = FactoryGirl.create(:user, email: 'test@example.com')
      playlist = FactoryGirl.create(:playlist, for_user: user)
      mail     = PlaylistMailer.new_playlist(playlist)
      expect(mail.to).to eql(%w(test@example.com))
      expect(mail.from).to eql(%w(noreply@alsofm.herokuapp.com))
      expect(mail.subject).to eql("New music for you to listen to!")
    end

    it "should not send an email if the for_user has no email address" do
      user     = FactoryGirl.create(:user, email: nil)
      playlist = FactoryGirl.create(:playlist, for_user: user)
      mail     = PlaylistMailer.new_playlist(playlist)
      expect(mail.message).to be_kind_of(ActionMailer::Base::NullMail)
    end
  end
end
