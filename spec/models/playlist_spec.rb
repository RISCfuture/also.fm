require 'rails_helper'

RSpec.describe Playlist, type: :model do
  describe '#tag_names' do
    it "should return a list of hashtags" do
      playlist = FactoryBot.create(:playlist)
      FactoryBot.create :tag, playlist: playlist, name: 'goose'
      FactoryBot.create :tag, playlist: playlist, name: 'dog'
      playlist.tags.reload

      expect(playlist.tag_names(reload: true)).to eql("#goose #dog")
    end
  end

  context '[hooks]' do
    context '[tag names]' do
      it "should save tags from tag names" do
        playlist = FactoryBot.build(:playlist, tag_names: '#foo #bar')
        playlist.save!
        expect(playlist.tags.count).to be(2)
        expect(playlist.tags.find_by_name('foo')).not_to be_nil
        expect(playlist.tags.find_by_name('bar')).not_to be_nil
      end

      it "should add new tags" do
        playlist = FactoryBot.create(:playlist)
        FactoryBot.create :tag, name: 'foo', playlist: playlist
        playlist.update tag_names: '#foo #bar'
        expect(playlist.tags.count).to be(2)
        expect(playlist.tags.find_by_name('foo')).not_to be_nil
        expect(playlist.tags.find_by_name('bar')).not_to be_nil
      end

      it "should remove deleted tags" do
        playlist = FactoryBot.create(:playlist)
        FactoryBot.create :tag, name: 'foo', playlist: playlist
        FactoryBot.create :tag, name: 'bar', playlist: playlist
        playlist.update tag_names: '#foo'
        expect(playlist.tags.count).to be(1)
        expect(playlist.tags.find_by_name('foo')).not_to be_nil
      end
    end

    describe '#name' do
      it "should default to the URL" do
        expect(FactoryBot.create(:playlist, name: nil, url: 'http://www.foo.com').name).
            to eql('http://www.foo.com')
        expect(FactoryBot.create(:playlist, name: 'foo', url: 'http://www.foo.com').name).
            to eql('foo')
      end
    end

    context '[email]' do
      it "should send an email if the for_user has an email" do
        for_user = FactoryBot.create(:user, email: 'sancho@example.com')
        playlist = FactoryBot.build(:playlist, for_user: for_user)
        message = instance_double('ActionMailer::MessageDelivery')
        expect(message).to receive(:deliver_now).once
        expect(PlaylistMailer).to receive(:new_playlist).once.with(playlist).and_return(message)
        playlist.save
      end
    end
  end
end
