# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Friendship, type: :model do
  subject { FactoryBot.build(:friendship) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it { should belong_to(:user) }
  it { should belong_to(:friend).class_name('User') }
  it { should define_enum_for(:status).with_values(pending: 0, accepted: 1, rejected: 2) }

  describe 'validations' do
    it 'does not allow duplicate friendship between same users' do
      existing = FactoryBot.create(:friendship)
      duplicate = FactoryBot.build(:friendship, user: existing.user, friend: existing.friend)
      expect(duplicate).not_to be_valid
    end
  end

  describe '.between' do
    let(:user_a) { FactoryBot.create(:user) }
    let(:user_b) { FactoryBot.create(:user) }

    it 'finds friendship in both directions' do
      friendship = FactoryBot.create(:friendship, user: user_a, friend: user_b)
      expect(Friendship.between(user_a, user_b)).to include(friendship)
      expect(Friendship.between(user_b, user_a)).to include(friendship)
    end
  end
end
