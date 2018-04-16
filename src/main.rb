require 'sinatra'
require_relative "./nikto_worker"

set :port, 8080
set :bind, '0.0.0.0'
set :environment, :production

client = NiktoWorker.new(
    'http://localhost:8080/rest',
    'nikto_webserverscan',
    ['NIKTO_TARGET', 'NIKTO_PORTS', 'NIKTO_PARAMETER']
)

get '/' do
  'Nikto-Client is started'
end

get '/id' do
  client.worker_id
end

get '/internal/health' do
  client.worker_id
end