# Garner + Grape API Caching

### A Basic Ruby Grape APP

Create a `Gemfile`.

```ruby
source 'http://rubygems.org'

gem 'grape'
```

Create an API.

```ruby
require 'grape'

class API < Grape::API
  format :json

  get do
    { count: 1 }
  end
end

run API
```

Try it.

```
$ rackup
[2016-02-11 08:11:57] INFO  WEBrick 1.3.1
[2016-02-11 08:11:57] INFO  ruby 2.2.1 (2015-02-26) [x86_64-darwin15]
[2016-02-11 08:11:57] INFO  WEBrick::HTTPServer#start: pid=98509 port=9292
```

Curl it.

```
$ curl localhost:9292
{"count":1}
```

### Cache Forever (or a Long Time)

```ruby
# expire in a year
expire_in = 60 * 60 * 24 * 365

# private = this user only, otherwise public (which can be stored in a CDN)
header 'Cache-Control', "private,max-age=#{expire_in}"
header 'Expires', CGI.rfc1123_date(Time.now.utc + expire_in)
```

### Don't Ever Cache Dynamic Content

```
# private = this user only
# max-age = don't store
# must-revalidate = don't serve when server is down
header 'Cache-Control', "private,max-age=0,must-revalidate"

# Nirvana was on top of the charts on January 1st, 1990
header 'Expires', 'Fri, 01 Jan 1990 00:00:00 GMT'
```

### If-Modified-Since

```ruby
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
```

Curl once, note the `Last-Modified` date and curl again with `If-Modified-Since: ...`.

```
$ curl localhost:9292"
$ curl localhost:9292 -H "If-Modified-Since:"
```

Note that the time granularity here is in seconds, so it's not going to work for a counter.

### If-None-Match

```ruby
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
```

### Rack::Cache and Rack::Etag

Add `rack-cache` to `Gemfile` and `use` in config.ru.

```ruby
use Rack::Cache
use Rack::ETag
```

Curl once, note the `ETag` and curl again with `If-None-Match: W/"..."`.

Note that this still fetches the data, just avoids sending it. Add a `sleep 3` into the API method to demonstrate.

### Cache Data

Use Cachy, add `gem 'cachy'` to Gemfile.

```ruby
require 'active_support'
require 'cachy'

Cachy.cache_store = ActiveSupport::Cache::MemoryStore.new
```

The API caches the value.

```ruby
Cachy.cache 'count' do
  sleep 3
  { count: 1 }
end
```

