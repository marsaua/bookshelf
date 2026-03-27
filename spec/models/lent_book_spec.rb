# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LentBook, type: :model do
  subject { FactoryBot.build(:lent_book) }

  it 'is valid with valid attributes' do
    lent_book = FactoryBot.build(:lent_book)
    expect(lent_book).to be_valid
  end

  it { should belong_to(:book) }
  it { should belong_to(:lender).class_name('User') }
  it { should belong_to(:borrower).class_name('User').optional }

  describe 'scopes' do
    let!(:active_lent) { FactoryBot.create(:lent_book, returned_at: nil) }
    let!(:returned_lent) { FactoryBot.create(:lent_book, returned_at: Time.current) }

    it 'active returns only not returned books' do
      expect(LentBook.active).to include(active_lent)
      expect(LentBook.active).not_to include(returned_lent)
    end

    it 'returned returns only returned books' do
      expect(LentBook.returned).to include(returned_lent)
      expect(LentBook.returned).not_to include(active_lent)
    end
  end

  describe '#borrower_display' do
    context 'when borrower exists' do
      let(:borrower) { FactoryBot.create(:user) }
      let(:lent_book) { FactoryBot.create(:lent_book, borrower: borrower) }

      it 'returns borrower full name' do
        expect(lent_book.borrower_display).to eq("#{borrower.first_name} #{borrower.last_name}")
      end
    end

    context 'when no borrower' do
      let(:lent_book) { FactoryBot.create(:lent_book, borrower: nil, borrower_name: 'John Doe') }

      it 'returns borrower_name' do
        expect(lent_book.borrower_display).to eq('John Doe')
      end
    end
  end

end
