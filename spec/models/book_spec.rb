# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, type: :model do
  it 'is valid with valid attributes' do
    book = FactoryBot.build(:book)
    expect(book).to be_valid
  end
  it { should belong_to(:user) }
  it { should have_many(:book_requests) }
  it { should have_one(:active_lent).class_name('LentBook') }
  it { should have_many(:ratings) }
  it { should have_many(:comments) }
  it { should have_one_attached(:image) }

  it { should validate_presence_of(:title) }

  describe '#lent?' do
    context 'when active_lent present' do
      let(:book) { FactoryBot.create(:book) }

      before { FactoryBot.create(:lent_book, book: book, returned_at: nil) }

      it 'returns true' do
        expect(book.lent?).to be true
      end
    end

    context 'when no active_lent' do
      let(:book) { FactoryBot.create(:book) }

      it 'returns false' do
        expect(book.lent?).to be false
      end
    end
  end

  describe '#average_rating' do
    let(:book) { FactoryBot.create(:book) }

    it 'returns average of ratings' do
      FactoryBot.create(:rating, book: book, value: 4)
      FactoryBot.create(:rating, book: book, value: 2)
      expect(book.average_rating).to eq(3.0)
    end

    it 'returns nil when no ratings' do
      expect(book.average_rating).to be_nil
    end
  end
end
