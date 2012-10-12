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
		User.create([{
			:name     => "david",
			:email    => "jdsilveira@gmail.com",
			:password => "password",
			:bio      => "ruby_man"
			},{
			:name     => "paraborrar",
			:email    => "paraborrar@gmail.com",
			:password => "todelete",
			:bio      => "todelete"
		}])
	end

	describe "GET on /api/v1/hello" do
		it "should return hello" do
			get "/api/v1/hello"
			last_response.should be_ok
			last_response.body.should == "hola"
		end
	end

	describe "GET on /api/v1/users/:name" do 
		it "should return a user by name" do
			get "/api/v1/users/david"
			last_response.should be_ok
			attributes = JSON.parse(last_response.body)
			attributes["user"]["name"].should == "david"
		end

		it "should return a user by name and the email should be valid" do
			get "/api/v1/users/paraborrar"
			last_response.should be_ok
			attributes = JSON.parse(last_response.body)
			attributes["user"]["email"].should == "paraborrar@gmail.com"
		end

		it "should return a NOT found error message" do
			get "/api/v1/users/notfounduser"
			last_response.should_not be_ok
			attributes = JSON.parse(last_response.body)
			attributes["error"].should == "user not found"
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

		it "should not create a user since data is not valid" do
			post '/api/v1/users', {
				:bio		=> "mi hija"
			}.to_json
			last_response.should_not be_ok
			attributes = JSON.parse(last_response.body)
			attributes["name"].first.should == "can't be blank"
			attributes["email"].first.should == "can't be blank"
		end
	end

	describe "POST on /api/v1/users/:user/login" do

		it "should validate a given user with a valid credentials" do
			post '/api/v1/users/david/login', {
					:password => 'password'
				}.to_json
			last_response.should be_ok
			attributes = JSON.parse(last_response.body)
			attributes['user']['email'].should == 'jdsilveira@gmail.com'
		end

		it "should reject the user credentials, valid user but wrong password" do
			post '/api/v1/users/david/login', {
					:password => 'wrongpassword'
				}.to_json
			last_response.status.should == 400
			attributes = JSON.parse(last_response.body)
			attributes['error'].downcase.should == 'invalid credentials'
		end
	end

	describe "PUT on /api/v1/users/:name" do

		# just a test to check that you cannot use the PUT method without
		# provide a username
		it "should thrown an error if no user is given" do
			put '/api/v1/users', {
				:bio => "na na na"
			}.to_json
			last_response.should_not be_ok
		end

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

	describe "DELETE on /api/v1/users/:name" do
		it "should remove a given user with name 'paraborrar'" do
			delete '/api/v1/users/paraborrar', {}.to_json
			last_response.should be_ok
			get '/api/v1/users/paraborrar'
			last_response.should_not be_ok
		end
	end

end