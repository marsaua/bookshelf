require 'rails_helper'

RSpec.describe Book, type: :model do
  it 'is valid with valid attributes' do
    book = FactoryBot.build(:book)
    expect(book).to be_valid
  end
    it { should belong_to(:user) }
    it { should have_many(:book_requests)}
    it { should have_one(:active_lent).class_name("LentBook")}
    it { should have_many(:ratings)}
    it { should have_many(:comments)}
    it { should have_one_attached(:image) }

    it { should validate_presence_of(:title) }
    

end
