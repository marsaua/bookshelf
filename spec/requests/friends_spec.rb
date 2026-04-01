require 'rails_helper'

RSpec.describe "Friends", type: :request do

  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET /friends" do
    it 'returns 200' do
      get friends_path
      expect(response).to have_http_status(:ok)
    end

    it 'shows recieved pending requests' do
      FactoryBot.create(:friendship, user: other_user, friend: user, status: :pending)
      get friends_path
      expect(response.body).to include(other_user.first_name)
    end

    it 'shows accepted friends' do
      FactoryBot.create(:friendship, user: other_user, friend: user, status: :accepted)
      get friends_path
      expect(response.body).to include(other_user.first_name)
    end

    it 'does not show rejected friends' do
      FactoryBot.create(:friendship, user: other_user, friend: user, status: :rejected)
      get friends_path
      expect(response.body).not_to include(other_user.first_name)
    end
  end

  describe "POST /friends" do
    context 'with valid params' do
      it 'creates a friendship' do
        expect {
          post friendships_path, params: { friend_id: other_user.id }
        }.to change(Friendship, :count).by(1)
      end  

      it 'creates a friendship with pending status' do
        post friendships_path, params: {friend_id: other_user.id}
        expect(Friendship.last.status).to eq('pending')
      end

      it 'do not create friendship with user more then once ' do
        FactoryBot.create(:friendship, user: user, friend: other_user)
        expect{
          post friendships_path, params: {friend_id: other_user.id}
        }.not_to change(Friendship, :count)
      end
    end
    context 'with invalid params' do
      it 'does not create a friendship' do
        expect {
          post friendships_path, params: {friend_id: ""}
      }.not_to change(Friendship, :count)
      end 
    end
  end

  describe 'DELETE /friends/:id' do
    it 'deletes the friendship' do
      friendship = FactoryBot.create(:friendship, user: user, friend: other_user)
      expect {
        delete friendship_path(friendship)
      }.to change(Friendship, :count).by(-1)
    end
  end
end
