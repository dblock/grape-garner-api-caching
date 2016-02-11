require 'grape'
require 'rack/cache'

require 'active_support'
require 'cachy'

Cachy.cache_store = ActiveSupport::Cache::MemoryStore.new

class API < Grape::API
  format :json

  helpers do
    def key(name)
      options = {}
      options[:version] = version
      options[:path] = request.path
      options[:params] = request.GET
      puts options.to_json
      Digest::MD5.hexdigest(options.to_json)
    end
  end

  get do
    Cachy.cache key('count') do
      sleep 3
      { count: 1 }
    end
  end
end

use Rack::Cache
use Rack::ETag

run API
