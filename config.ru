require 'rack'
require 'rack/contrib/try_static'
require 'rack/contrib/not_found'

class CacheSettings
  def initialize app, pat
    @app = app
    @pat = pat
  end
  def call env
    res = @app.call(env)
    path = env["REQUEST_PATH"]
    @pat.each do |pattern,data|
      if path =~ pattern
        res[1]["Cache-Control"] = data[:cache_control] if data.has_key?(:cache_control)
        res[1]["Expires"] = (Time.now + data[:expires]).utc.rfc2822 if data.has_key?(:expires)
        return res
      end
    end
    res
  end
end


# Use in combination with asset_hash
use CacheSettings, {
  /(images|stylesheets|javascripts|favicon)\// =>
     { :cache_control => "max-age=31536000, public",
      :expires => 31536000
    }
}

# gzip
use Rack::Deflater

use ::Rack::TryStatic,
  :root => "build",     # where middleman files are generated
  :urls => %w[/],          # match all requests
  :try => ['.html', 'index.html', '/index.html'] # try these postfixes sequentially

# 404
run Rack::NotFound.new('build/404/index.html')