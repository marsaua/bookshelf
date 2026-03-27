# frozen_string_literal: true

FactoryBot.define do
  factory :book_request do
    association :book
    association :requester, factory: :user
    status { :pending }

    trait :accepted do
      status { :accepted }
    end

    trait :declined do
      status { :declined }
    end

    trait :lent do
      status { :lent }
    end
  end
end
