# frozen_string_literal: true

FactoryBot.define do
  factory :lent_book do
    association :book
    association :lender, factory: :user
    association :borrower, factory: :user
    lent_at { Time.current }
    returned_at { nil }
  end
end
