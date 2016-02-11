require 'grape'

class API < Grape::API
  format :json

  get do
    # private = this user only
    # max-age = don't store
    # must-revalidate = don't serve when server is down
    header 'Cache-Control', "private,max-age=0,must-revalidate"

    # Nirvana was on top of the charts on January 1st, 1990
    header 'Expires', 'Fri, 01 Jan 1990 00:00:00 GMT'

    { count: 1 }
  end
end

run API
