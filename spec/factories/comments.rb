# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    association :user
    association :book
    body { Faker::Lorem.paragraph }
  end
end
