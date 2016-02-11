require 'grape'

class API < Grape::API
  format :json

  get do
    if_modified_since = Time.parse(headers['If-Modified-Since']) if headers.key?('If-Modified-Since') rescue nil
    if if_modified_since && @@last_modified && if_modified_since <= @@last_modified
      body false
      status :not_modified
    else
      @@last_modified ||= Time.now.utc
      header 'Cache-Control', "private,max-age=0,must-revalidate"
      header 'Last-Modified', CGI.rfc1123_date(@@last_modified)
      { count: 1 }
    end
  end
end

run API
