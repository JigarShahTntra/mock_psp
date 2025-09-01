# mock_psp.rb (simple Rack app)
require 'json'
require 'securerandom'
require 'rack'
require 'rack/handler/webrick'
begin
  require 'byebug'
rescue LoadError
  module Kernel
    def byebug; end
  end
end

app = Proc.new do |env|
  byebug if ENV['DEBUG'] == '1'
  req = Rack::Request.new(env)
  if req.path == '/payments/authorize' && req.post?
    body = JSON.parse(req.body.read) rescue {}
    # approve if amount < 5000 cents, otherwise decline
    status = (body.dig('amount','total').to_i < 5000) ? 'approved' : 'declined'

    response_body = {
      id: "psp_#{SecureRandom.hex(6)}",
      status: status,
      auth_code: "AUTH#{rand(9999)}"
    }.to_json

    [200, { 'Content-Type' => 'application/json' }, [response_body]]
  else
    [404, { 'Content-Type' => 'text/plain' }, ['not found']]
  end
end

Rack::Handler::WEBrick.run(app, Port: 4567)
