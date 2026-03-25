# frozen_string_literal: true

class BookMailer < ApplicationMailer
  def ask_to_read(user, book_request)
    @user = user
    @requester = book_request.requester
    @book = book_request.book

    email_text = render template: 'book_mailer/ask_to_read', formats: [:text]

    ::MailgunService.send(
      to: "#{user.first_name} <#{user.email}>",
      subject: "#{@requester.first_name} would like to borrow your book",
      text: email_text
    )
  end
end
