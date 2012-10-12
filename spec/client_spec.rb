require File.dirname(__FILE__) + '/bootstrap'
require File.dirname(__FILE__) + '/../client'

describe "client" do
	
	before(:each) do
		User.base_uri = "http://localhost:3000"
	end

	describe "getting user information" do

		it "should return a user" do
			user = User.find_by_name('tito')['user'];
			user["email"].should == 'tito@cosa.com'
		end

		it "should return null since this is an invalid user" do
			User.find_by_name('anselmomarini').should be_nil
		end
	end

	describe "creating" do
		it "should create user" do
			user = User.create(:name => 'pomelo', :email => 'pomelo@rock.com', :bio => 'another-rock-star')["user"]
			user["name"].should == 'pomelo'
			User.find_by_name('pomelo')['user']['email'].should == 'pomelo@rock.com'
		end
	end

end