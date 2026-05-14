# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:user_id].present? && params[:book_id].present?
      @other_user = User.find(params[:user_id])
      @book = Book.find(params[:book_id])
      @messages = Message.conversation_between(current_user.id, @other_user.id, @book.id)
      Message.where(sender_id: @other_user.id, receiver_id: current_user.id, book_id: @book.id, read: [false, nil])
             .update_all(read: true)
      render :conversation
    else
      @conversations = Message.conversations_for(current_user)
    end
  end

  def create
    @message = Message.new(
      sender: current_user,
      receiver: User.find(params[:receiver_id]),
      book: Book.find(params[:book_id]),
      body: params[:body]
    )

    if @message.save
      ActionCable.server.broadcast("chat_#{channel_key}", {
                                     message: @message.body,
                                     sender_id: current_user.id,
                                     sender_name: current_user.first_name,
                                     created_at: @message.created_at.strftime('%H:%M')
                                   })
      head :ok
    else
      render json: { error: 'Could not send message' }, status: :unprocessable_entity
    end
  end

  private

  def channel_key
    ids = [current_user.id, params[:receiver_id].to_i].sort
    "#{ids[0]}_#{ids[1]}_book_#{params[:book_id]}"
  end
end
