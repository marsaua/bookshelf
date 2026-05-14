class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{channel_key}"
  end

  def receive(data)
    message = Message.create!(
      sender: current_user,
      receiver: User.find(data["receiver_id"]),
      book: Book.find(data["book_id"]),
      body: data["body"]
    )

    ActionCable.server.broadcast("chat_#{channel_key}", {
      message: message.body,
      sender_id: current_user.id,
      sender_name: current_user.first_name,
      created_at: message.created_at.strftime("%H:%M")
    })
  end

  private

  def channel_key
    ids = [params[:user_id], params[:receiver_id]].map(&:to_i).sort
    "#{ids[0]}_#{ids[1]}_book_#{params[:book_id]}"
  end
end