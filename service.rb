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
databases = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(databases[env])


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
