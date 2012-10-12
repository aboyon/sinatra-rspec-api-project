require 'rubygems'
require 'typhoeus'
require 'json'

class User
	# Setting up the :base_uri as accesor for the client_spect.rb test 
	# using a "meta-class"
	class << self; attr_accessor :base_uri end

	# in some way this client method, is a mask for the magic method
	# self_by_name provided by the active_record gem
	def self.find_by_name(name)
		response = Typhoeus::Request::get("#{base_uri}/api/v1/users/#{name}")
		if (response.code == 200)
			JSON.parse(response.body)
		elsif (response.code == 404)
			nil
		else
			raise response.body
		end
	end

end
