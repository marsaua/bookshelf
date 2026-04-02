# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Ratings', type: :request do
  before { sign_in user }

  let(:user) { FactoryBot.create(:user) }
  let(:book) { FactoryBot.create(:book) }

  describe 'POST /ratings' do
    context 'when rating does not exist' do
      it 'creates a rating' do
        expect do
          post ratings_path, params: { rating: { book_id: book.id, value: 4 } }, as: :json
        end.to change(Rating, :count).by(1)
      end

      it 'saves correct value' do
        post ratings_path, params: { rating: { book_id: book.id, value: 4 } }
        expect(Rating.last.value).to eq(4)
      end
    end

    context 'when rating is already exists' do
      let!(:existing_rating) { FactoryBot.create(:rating, user: user, book: book, value: 3) }

      it 'does not create new rating' do
        expect do
          post ratings_path, params: { rating: { book_id: book.id, value: 5 } }
        end.not_to change(Rating, :count)
      end

      it 'update existing rating' do
        put rating_path(existing_rating), params: { rating: { book_id: book.id, value: 4 } }
        expect(existing_rating.reload.value).to eq(4)
      end
    end
  end
end
