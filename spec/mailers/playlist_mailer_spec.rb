require 'rails_helper'

RSpec.describe PlaylistMailer, type: :mailer do
  describe '#new_playlist' do
    it "should send an email to the for_user" do
      user     = FactoryBot.create(:user, email: 'test@example.com')
      playlist = FactoryBot.create(:playlist, for_user: user)
      mail     = described_class.new_playlist(playlist)
      expect(mail.to).to eql(%w[test@example.com])
      expect(mail.from).to eql(%w[noreply@also.fm])
      expect(mail.subject).to eql("New music for you to listen to!")
    end

    it "should not send an email if the for_user has no email address" do
      user     = FactoryBot.create(:user, email: nil)
      playlist = FactoryBot.create(:playlist, for_user: user)
      mail     = described_class.new_playlist(playlist)
      expect(mail.message).to be_kind_of(ActionMailer::Base::NullMail)
    end
  end
end
