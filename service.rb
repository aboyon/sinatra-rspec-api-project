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

# hello world but in spanish :)
get '/api/v1/hello' do
	"hola"
end

# Getting information about a given user
# usage /api/v1/users/aboyon
get '/api/v1/users/:name' do
	user = User.find_by_name(params[:name])
	if user
		user.to_json
	else
		error 404, {:error => "user not found"}.to_json
	end
end

# Creating a user, but this time, using POST method
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

# Updating/editing user for a given user. Target URL is the same used for
# DELETE or GET user information
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

# deleting a user, using the DELETE method. Target URL is the same used for
# UPDATE or GET user information
delete '/api/v1/users/:name' do
	user = User.find_by_name(params[:name])
	if user
		user.destroy
		user.to_json
	else
		error 404, {:error => 'User not found'}.to_json
	end
end

# now, let's validate a user using his credentials
post '/api/v1/users/:name/login' do
	request_info = JSON.parse(request.body.read)
	user = User.find_by_name_and_password(params[:name], request_info['password'])
	if (user)
		user.to_json
	else
		error 400, {:error => 'invalid credentials'}.to_json
	end
end