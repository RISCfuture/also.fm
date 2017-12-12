FactoryBot.define do
  factory :tag do
    association :playlist
    sequence(:name) { |i| FFaker::HipsterIpsum.word + "-#{i}" }
  end
end
