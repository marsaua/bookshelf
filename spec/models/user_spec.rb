require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = FactoryBot.build(:user)
    expect(user).to be_valid
  end
    it { should have_many(:books) }
    it { should have_many(:friendships)}
    it { should have_many(:received_friends).through(:received_friendships) }
    it { should have_many(:received_friendships) }
    it { should have_many(:friends).through(:friendships) }
    it { should have_many(:book_requests)}
    it { should have_many(:lent_books)}
    it { should have_many(:ratings)}
    it { should have_many(:comments)}
    it { should have_one_attached(:avatar) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }

end
