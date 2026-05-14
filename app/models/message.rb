# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :book

  validates :body, presence: true

  scope :unread_for, ->(user) { where(receiver_id: user.id, read: [false, nil]) }

  def self.conversation_between(user1_id, user2_id, book_id)
    where(book_id:)
      .where(
        '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
        user1_id, user2_id, user2_id, user1_id
      )
      .order(:created_at)
  end

  def self.conversations_for(user)
    all_messages = where('sender_id = :id OR receiver_id = :id', id: user.id)
                   .includes(:sender, :receiver, :book)
                   .order(created_at: :desc)

    seen = {}
    conversations = []

    all_messages.each do |msg|
      other_user = msg.sender_id == user.id ? msg.receiver : msg.sender
      key = "#{other_user.id}_#{msg.book_id}"
      next if seen[key]

      seen[key] = true
      conversations << { other_user:, book: msg.book, last_message: msg, unread_count: 0 }
    end

    unread_counts = unread_for(user).group(:sender_id, :book_id).count
    conversations.each do |conv|
      conv[:unread_count] = unread_counts[[conv[:other_user].id, conv[:book].id]] || 0
    end

    conversations
  end
end
