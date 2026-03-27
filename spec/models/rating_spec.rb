# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rating, type: :model do
  subject { FactoryBot.build(:rating) }

  it 'is valid with valid attributes' do
    rating = FactoryBot.build(:rating)
    expect(rating).to be_valid
  end

  it { should belong_to(:user) }
  it { should belong_to(:book) }

  it { should validate_presence_of(:value) }
  it { should validate_inclusion_of(:value).in_range(1..5) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:book_id) }
end
