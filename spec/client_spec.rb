require File.dirname(__FILE__) + '/bootstrap'
require File.dirname(__FILE__) + '/../client'

describe "client" do
	
	before(:each) do
		User.base_uri = "http://localhost:3000"
	end

	it "should return a user" do
		user = User.find_by_name('tito')["user"];
		user["email"].should == 'tito@cosa.com'
	end

	it "should return null since this is an invalid user" do
		User.find_by_name('anselmomarini').should be_nil
	end

end