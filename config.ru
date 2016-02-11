require 'grape'

class API < Grape::API
  format :json

  get do
    { count: 1 }
  end
end

run API
