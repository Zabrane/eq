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
    it "should recieve an item from the queue" do
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

  URL = "http://localhost:9952"
end

