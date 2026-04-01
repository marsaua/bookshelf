require 'rails_helper'

RSpec.describe CommentsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:book) { FactoryBot.create(:book) }
  let(:comment) { FactoryBot.create(:comment, user: user, book: book) }

  before { sign_in user }

  describe 'POST /comments' do
    context 'with valid params' do
      it 'creates a comment' do
        expect {
          post comments_path, params: { comment: { body: 'Great book!', book_id: book.id } }
        }.to change(Comment, :count).by(1)
      end

      it 'redirects back' do
        post comments_path, params: { comment: { body: 'Great book!', book_id: book.id } }
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid params' do
      it 'does not create a comment' do
        expect {
          post comments_path, params: { comment: { body: '', book_id: book.id } }
        }.not_to change(Comment, :count)
      end
    end
  end

  describe 'DELETE /comments/:id' do
    it 'deletes the comment' do
      comment
      expect {
        delete comment_path(comment)
      }.to change(Comment, :count).by(-1)
    end

    it 'redirects to book path' do
      delete comment_path(comment)
      expect(response).to redirect_to(book_path(book))
    end
  end
end