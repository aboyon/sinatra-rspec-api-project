ENV['SINATRA_ENV'] = 'test'

require File.dirname(__FILE__) + '/../service'
require 'rspec'
require 'rack/test'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
	Sinatra::Application
end

describe "service" do

	before(:each) do
		User.delete_all
		User.create(
			:name     => "david",
			:email    => "jdsilveira@gmail.com",
			:password => "password",
			:bio      => "ruby_man")
	end

	describe "GET on /api/v1/users/:name" do 

		it "should return hello" do
			get "/api/v1/hello"
			last_response.should be_ok
			last_response.body.should == "hola"
		end		

		it "should return a user by name" do
			get "/api/v1/users/david"
			last_response.should be_ok
			attributes = JSON.parse(last_response.body)
			attributes["user"]["name"].should == "david"
			attributes["user"]["email"].should == "jdsilveira@gmail.com"
		end

	end

	describe "POST on /api/v1/users" do
		it "should create a new user" do
			post '/api/v1/users', {
				:name  		=> "Ana",
				:email 		=> "ana@silveira.com",
				:password 	=> "princesas",
				:bio		=> "mi hija"
			}.to_json
			last_response.should be_ok
			get "/api/v1/users/Ana"
			attributes = JSON.parse(last_response.body)
			attributes["user"]["name"].downcase.should == 'ana'
		end
	end

	describe "PUT on /api/v1/users/:name" do
		it "should change the biography for user ana" do
			put '/api/v1/users/david', {
				:bio => 'ex-php'
			}.to_json
			last_response.should be_ok
			get '/api/v1/users/david'
			attributes = JSON.parse(last_response.body)["user"]
			attributes["bio"].should == "ex-php"
		end
	end

end