require 'grape'
require 'rack/cache'

class API < Grape::API
  format :json

  get do
    { count: 1 }
  end
end

use Rack::Cache
use Rack::ETag

run API
