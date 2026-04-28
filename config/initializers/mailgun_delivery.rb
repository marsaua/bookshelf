# frozen_string_literal: true

class MailgunDeliveryMethod
  def initialize(settings); end

  def deliver!(mail)
    body = mail.multipart? ? mail.text_part&.body&.decoded.to_s : mail.body.decoded.to_s

    MailgunService.send(
      to: mail.to.first,
      subject: mail.subject,
      text: body
    )
  end
end

ActionMailer::Base.add_delivery_method :mailgun, MailgunDeliveryMethod
