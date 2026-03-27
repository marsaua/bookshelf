require 'rails_helper'

RSpec.describe BooksController, type: :request do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe 'GET /books' do
    it 'returns 200' do
      get books_path
      expect(response).to have_http_status(:ok)
    end

    it 'assigns my_books without lent books' do
      book = FactoryBot.create(:book, user: user)
      lent_book = FactoryBot.create(:book, user: user)
      FactoryBot.create(:lent_book, book: lent_book, lender: user)

      get books_path

      expect(assigns(:my_books)).to include(book)
      expect(assigns(:my_books)).not_to include(lent_book)
    end

    it 'assigns lent_books' do
      lent_book = FactoryBot.create(:book, user: user)
      FactoryBot.create(:lent_book, book: lent_book, lender: user)

      get books_path

      expect(assigns(:lent_books)).to include(lent_book)
    end

    context 'with category filter' do
      it 'filters my_books by category' do
        book = FactoryBot.create(:book, user: user, category: 'Fiction')
        other = FactoryBot.create(:book, user: user, category: 'Drama')

        get books_path, params: { category: 'Fiction' }

        expect(assigns(:my_books)).to include(book)
        expect(assigns(:my_books)).not_to include(other)
      end
    end
  end

  describe 'POST /books' do
  context 'with valid params' do
    it 'creates a book' do
      expect {
        post books_path, params: { book: { title: 'Test Book', author: 'Author' } }
      }.to change(Book, :count).by(1)
    end

    it 'redirects to book path' do
      post books_path, params: { book: { title: 'Test Book', author: 'Author' } }
      expect(response).to redirect_to(book_path(Book.last))
    end
  end

  context 'with invalid params' do
    it 'does not create a book' do
      expect {
        post books_path, params: { book: { title: '' } }
      }.not_to change(Book, :count)
    end

    it 'returns unprocessable entity' do
      post books_path, params: { book: { title: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
end