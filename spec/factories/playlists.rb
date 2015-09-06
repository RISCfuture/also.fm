FactoryGirl.define do
  factory :playlist do
    association :for_user, factory: :user
    sequence(:url) { |i| FFaker::Internet.http_url + "/#{i}" }
    name { FFaker::BaconIpsum.sentence(3) }
    priority { rand(I18n.t('models.playlist.priorities').size) }
  end
end
