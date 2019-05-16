require 'sinatra'
require 'json'
require 'bundler'
Bundler.setup(:default)
require 'ruby-scanner-scaffolding'
require 'ruby-scanner-scaffolding/healthcheck'
require_relative "./nikto_worker"

set :port, 8080
set :bind, '0.0.0.0'
set :environment, :production

client = NiktoWorker.new(
	'http://localhost:8080',
	'nikto_webserverscan',
	['PROCESS_TARGETS']
)

healthcheckClient = Healthcheck.new

get '/status' do
	status 500
	if client.healthy?
		status 200
	end
	content_type :json
	healthcheckClient.check(client)
end

