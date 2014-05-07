require 'sinatra'
require 'rest_client'
require 'json'


PROXY = {}

ENV.each do |key, value|
  if key.start_with?('PROXY_')
    PROXY[key.gsub('PROXY_', '')] = value
  end
end

TESTING = ENV['TESTING']

get '/proxy/:proxy' do

  unless PROXY.has_key?(params[:proxy])
    response.status = 404
    return "404: proxy not found"
  end

  proxy = PROXY[params[:proxy]]
  proxy_address = Resolv.getaddress(URI(proxy).host)
  RestClient.proxy = proxy
  port = request.port == 80  ? '' : ":#{request.port}"
  uri = "#{request.scheme}://#{request.host}#{port}/myip"
  uri = TESTING ? 'http://ip.jsontest.com' : uri
  request = RestClient::Resource.new(uri, :timeout => 2)
  data = request.get
  pdata = JSON.parse data

  if pdata['ip'] == proxy_address
    "OK: #{pdata['ip']}"
  else
    response.status = 409
    "409: Conflict error: The ip isn't the proxy IP #{pdata['ip']}"
  end
end


get '/myip' do
  content_type :json
  { :ip => request.ip }.to_json
end


get '/' do
  "Hey, get out of here."
end

