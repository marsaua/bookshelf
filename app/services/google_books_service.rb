# frozen_string_literal: true

require 'net/http'
require 'json'

class GoogleBooksService
  API_URL = 'https://www.googleapis.com/books/v1/volumes'

  def self.search(query)
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(
      q: query,
      key: ENV.fetch('GOOGLE_BOOKS_API_KEY', nil),
      maxResults: 5,
      langRestrict: 'en'
    )

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 5) do |http|
      http.get(uri.request_uri)
    end

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "Google Books API error: #{response.code}"
      return []
    end

    data = JSON.parse(response.body)

    (data['items'] || []).map do |item|
      info = item['volumeInfo']
      {
        title: info['title'],
        author: info['authors']&.first,
        description: info['description'],
        image: info['imageLinks']&.dig('thumbnail'),
        category: info['categories']&.first,
        publisher: info['publisher'],
        language: info['language'],
        page_count: info['pageCount']
      }
    end
  rescue JSON::ParserError, Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error "GoogleBooksService failed: #{e.class} #{e.message}"
    []
  end
end
