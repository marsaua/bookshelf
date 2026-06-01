# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookRequestsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:owner) { FactoryBot.create(:user) }
  let(:book) { FactoryBot.create(:book, user: owner) }

  before { sign_in user }

  describe 'POST /book_requests' do
    context 'when requester is not friends with the book owner' do
      it 'redirects to the book page with an alert' do
        post book_requests_path, params: { book_request: { book_id: book.id } }

        expect(response).to redirect_to(book_path(book))
        expect(flash[:alert]).to eq('You must be friends with the owner to request this book.')
      end

      it 'does not create a book request' do
        expect {
          post book_requests_path, params: { book_request: { book_id: book.id } }
        }.not_to change(BookRequest, :count)
      end
    end

    context 'when requester is friends with the book owner' do
      before do
        FactoryBot.create(:friendship, user: user, friend: owner, status: :accepted)
      end

      it 'creates a book request' do
        expect {
          post book_requests_path, params: { book_request: { book_id: book.id } }
        }.to change(BookRequest, :count).by(1)
      end
    end
  end
end
