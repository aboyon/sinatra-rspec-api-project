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
	end

	describe "GET on /api/v1/users/:name" do 

		before(:each) do
			User.create(
				:name     => "david",
				:email    => "jdsilveira@gmail.com",
				:password => "password",
				:bio      => "ruby_man")
		end

		it "should return a user by name" do
			get "/api/v1/users/david"
			last_response.should be_ok
			attributes = JSON.parse(last_response.body)
			attributes["user"]["name"].should == "david"
		end

	end

end