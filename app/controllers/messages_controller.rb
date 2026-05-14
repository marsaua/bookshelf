# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:user_id].present? && params[:book_id].present?
      @other_user = User.find(params[:user_id])
      @book = Book.find(params[:book_id])
      @messages = Message.conversation_between(current_user.id, @other_user.id, @book.id)
                         .visible_for(current_user)
      Message.where(sender_id: @other_user.id, receiver_id: current_user.id, book_id: @book.id, read: [false, nil])
             .update_all(read: true)
      render :conversation
    else
      @conversations = Message.conversations_for(current_user)
    end
  end

  def destroy
    @message = Message.find(params[:id])
    return head :forbidden unless participant?(@message)

    if params[:scope] == 'for_all'
      return head :forbidden unless @message.sender_id == current_user.id

      broadcast_delete(@message)
      @message.destroy
    elsif @message.sender_id == current_user.id
      @message.update!(deleted_by_sender: true)
    else
      @message.update!(deleted_by_receiver: true)
    end

    head :ok
  end

  def destroy_conversation
    @other_user = User.find(params[:user_id])
    @book = Book.find(params[:book_id])
    messages = Message.conversation_between(current_user.id, @other_user.id, @book.id)

    if params[:scope] == 'for_all'
      messages.each { |m| broadcast_delete(m) }
      messages.destroy_all
    else
      messages.where(sender_id: current_user.id).update_all(deleted_by_sender: true)
      messages.where(receiver_id: current_user.id).update_all(deleted_by_receiver: true)
    end

    head :ok
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
                                     message_id: @message.id,
                                     sender_id: current_user.id,
                                     sender_name: current_user.first_name,
                                     created_at: @message.created_at.strftime('%H:%M')
                                   })
      render json: { message_id: @message.id }
    else
      render json: { error: 'Could not send message' }, status: :unprocessable_entity
    end
  end

  private

  def channel_key
    ids = [current_user.id, params[:receiver_id].to_i].sort
    "#{ids[0]}_#{ids[1]}_book_#{params[:book_id]}"
  end

  def participant?(message)
    message.sender_id == current_user.id || message.receiver_id == current_user.id
  end

  def broadcast_delete(message)
    ids = [message.sender_id, message.receiver_id].sort
    key = "#{ids[0]}_#{ids[1]}_book_#{message.book_id}"
    ActionCable.server.broadcast("chat_#{key}", { type: 'delete', message_id: message.id })
  end
end
