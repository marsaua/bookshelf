# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  it 'is valid with valid attributes' do
    comment = FactoryBot.build(:comment)
    expect(comment).to be_valid
  end
  it { should belong_to(:user) }
  it { should belong_to(:book) }

  it { should validate_presence_of(:body) }
end
