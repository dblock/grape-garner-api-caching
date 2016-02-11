require 'grape'

class API < Grape::API
  format :json

  get do
    # expire in a year
    expire_in = 60 * 60 * 24 * 365

    # private = this user only, otherwise public (which can be stored in a CDN)
    header 'Cache-Control', "private,max-age=#{expire_in}"
    header 'Expires', CGI.rfc1123_date(Time.now.utc + expire_in)

    { count: 1 }
  end
end

run API
