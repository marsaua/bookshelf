require "net/http"
require "json"

class GoogleBooksService
  API_URL = "https://www.googleapis.com/books/v1/volumes"

  def self.search(query)
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(
      q: query,
      key: ENV["GOOGLE_BOOKS_API_KEY"],
      maxResults: 5,
      langRestrict: "en"
    )

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.get(uri.request_uri)
    end

    Rails.logger.debug "RESPONSE CODE: #{response.code}"
    Rails.logger.debug "RESPONSE BODY: #{response.body}"

    data = JSON.parse(response.body)

    data["items"]&.map do |item|
      info = item["volumeInfo"]
      {
        title: info["title"],
        author: info["authors"]&.first,
        description: info["description"],
        image: info["imageLinks"]&.dig("thumbnail"),
        category: info["categories"]&.first
      }
    end
  end
end
