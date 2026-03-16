class BookRequest < ApplicationRecord
  belongs_to :book
  belongs_to :requester, class_name: "User", foreign_key: "requester_id"

  enum :status, { pending: 0, accepted: 1, declined: 2, lent: 3 }

  delegate :user, to: :book, prefix: :book

  validates :book_id, uniqueness: { scope: :requester_id, message: "You already requested this book." }

end
