require 'active_record'
require 'sinatra'
require_relative 'models/user.rb'
require 'logger'

# setting up a logger. levels -> DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
log = Logger.new(STDOUT)
log.level = Logger::DEBUG 

# setting up the environment
env_index = ARGV.index("-e")
env_arg = ARGV[env_index + 1] if env_index
env = env_arg || ENV["SINATRA_ENV"] || "development"
log.debug "env: #{env}"

use ActiveRecord::ConnectionAdapters::ConnectionManagement
databases = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(databases[env])
log.debug "#{databases[env]} database connection established"

# HTTP entry points
# get a user by name

get '/api/v1/hello' do
	"hola"
end

get '/api/v1/users/:name' do
	user = User.find_by_name(params[:name])
	if user
		user.to_json
	else
		error 404, {:error => "user not found"}.to_json
	end
end

post '/api/v1/users' do
	begin
		user = User.create(JSON.parse(request.body.read))
		if user.valid?
			user.to_json
		else
			error 400, user.errors.to_json
		end
	rescue => e
		error 400, { :error => e.message}.to_json
	end
end

put '/api/v1/users/:name' do
	user = User.find_by_name(params[:name])
	if user
		begin
			if user.update_attributes(JSON.parse(request.body.read))
				user.to_json
			else
				error 400, user.errors.to_json
			end
		rescue => e
			error 400, {:error => e.message}.to_json
		end
	else
		error 404, {:error => 'User not found'}.to_json
	end
end