require 'grape'
require 'rack/cache'

require 'active_support'
require 'cachy'

Cachy.cache_store = ActiveSupport::Cache::MemoryStore.new

class API < Grape::API
  format :json

  get do
    Cachy.cache 'count' do
      sleep 3
      { count: 1 }
    end
  end
end

use Rack::Cache
use Rack::ETag

run API
