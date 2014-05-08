require 'sinatra/base'
require 'rest_client'
require 'json'
require 'digest'


PROXY = {}

ENV.each do |key, value|
  if key.start_with?('PROXY_')
    PROXY[key.gsub('PROXY_', '')] = value
  end
end

TESTING = ENV['TESTING']
HTTP_USER = ENV['HTTP_USER']


class Protected < Sinatra::Base
  if HTTP_USER
    use Rack::Auth::Basic, "Protected Area" do |username, password|
      stored_user, stored_password = HTTP_USER.split(':')
      password_hash = Digest::SHA256.new() << password
      username == stored_user && password_hash.hexdigest == stored_password
    end
  end
  
  
  get '/proxy/:proxy' do
  
    unless PROXY.has_key?(params[:proxy])
      response.status = 404
      return "404: proxy not found"
    end
  
    proxy = PROXY[params[:proxy]]
    proxy_address = Resolv.getaddress(URI(proxy).host)
    RestClient.proxy = proxy
    port = request.port == 80  ? '' : ":#{request.port}"
    uri = "#{request.scheme}://#{request.host}#{port}/public/myip"
    uri = TESTING ? 'http://ip.jsontest.com' : uri
    request = RestClient::Resource.new(uri, :timeout => 2, :open_timeout => 2)
    data = request.get
    pdata = JSON.parse data
  
    if pdata['ip'] == proxy_address
      "OK: #{pdata['ip']}"
    else
      response.status = 409
      "409: Conflict error: The ip isn't the proxy IP #{pdata['ip']}"
    end
  end

  get '/' do
    "Hey, get out of here."
  end
end

class Public < Sinatra::Base
  get '/myip' do
    content_type :json
    { :ip => request.ip }.to_json
  end
end
