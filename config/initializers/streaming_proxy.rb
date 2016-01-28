require 'rack/streaming_proxy'

Rails.application.configure do
  config.streaming_proxy.logger             = Rails.logger                          # stdout by default
  config.streaming_proxy.log_verbosity      = Rails.env.production? ? :low : :high  # :low or :high, :low by default
  config.streaming_proxy.num_retries_on_5xx = 5                                     # 0 by default
  config.streaming_proxy.raise_on_5xx       = true                                  # false by default

  # Will be inserted at the end of the middleware stack by default.
  config.middleware.use Rack::StreamingProxy::Proxy do |request|
    if request.path.start_with?('/api/manifest/stream/f4m')
      proxy_path = request.path.sub %r{^/api/manifest/stream/f4m/}, ''
      "http://#{proxy_path}"
    end
  end
end