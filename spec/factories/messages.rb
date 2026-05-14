FactoryBot.define do
  factory :message do
    sender { nil }
    receiver { nil }
    book { nil }
    body { "MyText" }
    read { false }
  end
end
