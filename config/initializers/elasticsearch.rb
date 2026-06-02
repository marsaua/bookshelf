Searchkick.client = Elasticsearch::Client.new(
  url: ENV['ELASTICSEARCH_URL'],
  transport_options: {
    ssl: { verify: false }
  }
)