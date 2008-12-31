require 'rubygems'
require 'json'
require 'rest_client'

describe "JobQ" do
  describe "POSTing" do
    it "should add an item to the queue" do
      response = RestClient.post(URL, :data => 100)
      h = JSON.parse(response)
      
      h.should have_key("success")
      h["success"].should be_true
    end
  end

  describe "GETing" do
    it "should receive an item from the queue" do
      response = RestClient.get(URL)
      h = JSON.parse(response)

      h.should have_key("data")
    end
  end

  describe "DELETEing" do
    it "should clear the queue" do
      response = RestClient.delete(URL)
      h = JSON.parse(response)

      h.should have_key("success")
      h["success"].should be_true
    end
  end

  it "should receive a simple item from the queue" do
    # Clear the queue
    RestClient.delete(URL)

    # Add a new item
    RestClient.post(URL, :data => "Hey, Boys".to_json)

    # Get an item
    response = RestClient.get(URL)
    h = JSON.parse(response)

    h["data"].should == "Hey, Boys"
  end

  it "should receive a complex item from the queue" do
    # Clear the queue
    RestClient.delete(URL)

    # Add a new item
    RestClient.post(URL, :data => {"complex" => "item"}.to_json)

    # Get an item
    response = RestClient.get(URL)
    h = JSON.parse(response)

    h["data"].should have_key("complex")
    h["data"]["complex"].should == "item"
  end

  URL = "http://localhost:9952"
end

