require 'grape'

class API < Grape::API
  format :json

  get do
    etag = headers['If-None-Match']
    if etag && @@etag && etag == @@etag
      body false
      status :not_modified
    else
      @@etag ||= SecureRandom.hex(12)
      header 'Cache-Control', "private,max-age=0,must-revalidate"
      header 'E-Tag', @@etag
      { count: 1 }
    end
  end
end

run API
