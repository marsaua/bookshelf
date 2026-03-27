# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    association :user
    association :book
    value { rand(1..5) }
  end
end
