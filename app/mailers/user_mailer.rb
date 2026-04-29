# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def friendship_request(recipient, requester)
    @recipient = recipient
    @requester = requester

    email_text = render template: 'user_mailer/friendship_request', formats: [:text]

    MailgunService.send(
      to: "#{recipient.first_name} <#{recipient.email}>",
      subject: "#{requester.first_name} #{requester.last_name} wants to be your friend on Bookshelf",
      text: email_text
    )
  end

  def reset_password_instructions(user, token)
    @user = user
    @token = token

    email_text = render template: 'user_mailer/reset_password_instructions', formats: [:text]

    MailgunService.send(
      to: "#{user.first_name} <#{user.email}>",
      subject: 'Reset your Bookshelf password',
      text: email_text
    )
  end
end
