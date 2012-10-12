# DRY... create a bootstrap file and avoid repeated code!!

ENV['SINATRA_ENV'] = 'test'

require 'rspec'
require 'rack/test'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
	Sinatra::Application
end