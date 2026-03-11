require 'net/http'
require 'json'
require 'openssl'

class GoogleBooksService
  API_URL = "https://www.googleapis.com/books/v1/volumes"

  def self.search(query)
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(
      q: query,
      key: ENV['GOOGLE_BOOKS_API_KEY'],
      maxResults: 5,
      langRestrict: 'en' 
    )

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Get.new(uri)
    request['Referer'] = 'http://localhost:3000' 
    response = http.request(request)
    Rails.logger.debug "GOOGLE API RESPONSE: #{response.body}"
    data = JSON.parse(response.body)

    data['items']&.map do |item|
      info = item['volumeInfo']
      {
        title: info['title'],
        author: info['authors']&.first,
        description: info['description'],
        image: info['imageLinks']&.dig('thumbnail'),
        genre: info['categories']&.first
      }
    end
  end
end