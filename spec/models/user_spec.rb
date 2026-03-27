# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = FactoryBot.build(:user)
    expect(user).to be_valid
  end
  it { should have_many(:books) }
  it { should have_many(:friendships) }
  it { should have_many(:received_friends).through(:received_friendships) }
  it { should have_many(:received_friendships) }
  it { should have_many(:friends).through(:friendships) }
  it { should have_many(:book_requests) }
  it { should have_many(:lent_books) }
  it { should have_many(:ratings) }
  it { should have_many(:comments) }
  it { should have_one_attached(:avatar) }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }

  describe '#friendship_with' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:user) }

    context 'when friendship exists' do
      let!(:friendship) { FactoryBot.create(:friendship, user: user, friend: other_user) }

      it 'returns the friendship' do
        expect(user.friendship_with(other_user)).to eq(friendship)
      end
    end

    context 'when friendship does not exist' do
      it 'returns nil' do
        expect(user.friendship_with(other_user)).to be_nil
      end
    end
  end

  describe '#all_friends' do
    let(:user) { FactoryBot.create(:user) }
    let(:friend1) { FactoryBot.create(:user) }
    let(:friend2) { FactoryBot.create(:user) }

    before do
      FactoryBot.create(:friendship, :accepted, user: user, friend: friend1)
      FactoryBot.create(:friendship, :accepted, friend: user, user: friend2)
    end

    it 'returns all accepted friends from both sides' do
      expect(user.all_friends).to include(friend1, friend2)
    end

    it 'does not include pending friends' do
      pending_user = FactoryBot.create(:user)
      FactoryBot.create(:friendship, user: user, friend: pending_user)
      expect(user.all_friends).not_to include(pending_user)
    end
  end
end
