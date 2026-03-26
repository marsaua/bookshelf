FactoryBot.define do
  factory :book do
    association :user
    title { Faker::Book.title }
    author { Faker::Book.author }
    category { Faker::Book.genre }
    cover_url { Faker::Internet.url }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price }
  end
end
