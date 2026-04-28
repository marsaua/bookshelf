# frozen_string_literal: true

class UserMailer < ApplicationMailer
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
