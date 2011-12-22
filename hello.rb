require 'sinatra'
require "open-uri"
require "json"
require "yaml"

set :public_folder, File.dirname(__FILE__) + '/static'

API_URL = "http://countdown.tfl.gov.uk/stopBoard/%d"

get '/' do
  response = open(API_URL % "55951"){ |f| f.read }
  @data = JSON.parse(response)
  @buses = @data["arrivals"]
  erb :index
end