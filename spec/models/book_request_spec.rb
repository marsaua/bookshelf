# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookRequest, type: :model do
  it 'is valid with valid attributes' do
    book_request = FactoryBot.build(:book_request)
    expect(book_request).to be_valid
  end
  it { should belong_to(:book) }
  it { should belong_to(:requester).class_name('User') }

  describe 'validations' do
    it { should define_enum_for(:status).with_values(pending: 0, accepted: 1, declined: 2, lent: 3) }

    it 'does not allow duplicate pending request from same user on same book' do
      existing = FactoryBot.create(:book_request)
      duplicate = FactoryBot.build(:book_request, book: existing.book, requester: existing.requester)
      expect(duplicate).not_to be_valid
    end

    it 'allows new request if previous is accepted' do
      existing = FactoryBot.create(:book_request, :accepted)
      new_request = FactoryBot.build(:book_request, book: existing.book, requester: existing.requester)
      expect(new_request).to be_valid
    end
  end
end
