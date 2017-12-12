FactoryBot.define do
  factory :user do
    sequence(:username) { |i| "user-#{i}" }
    password { FFaker::Internet.password(6) }
  end
end
