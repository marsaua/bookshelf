require 'net/http'
require 'uri'

class MailgunService
    DOMAIN = ENV['MAILGUN_DOMAIN']
  
    def self.send(to:, subject:, text:)
      uri = URI("https://api.mailgun.net/v3/#{DOMAIN}/messages")
      
      req = Net::HTTP::Post.new(uri)
      req.basic_auth('api', ENV['MAILGUN_API_KEY'])
      req.set_form_data(
        from: "Mailgun <postmaster@#{DOMAIN}>",
        to: to,
        subject: subject,
        text: text
      )
  
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
    end
  end