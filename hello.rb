require 'sinatra'
require "open-uri"
require "json"
require "yaml"

set :public_folder, File.dirname(__FILE__) + '/static'

API_URL = "http://countdown.tfl.gov.uk/stopBoard/%d"

get '/' do
  stops = request.cookies["bus_stops"]
  @cookies = request.cookies
  if stops
    @favourites = stops.split(',')
  end
  erb :index
end


get '/stop/:id' do
  @stop = params[:id]
  response = open(API_URL % @stop){ |f| f.read }
  @data = JSON.parse(response)
  @buses = @data["arrivals"]
  @cookie = request.cookies["bus_stops"]
  @is_favourite = false
  if @cookie
    stops = @cookie.split(',')
    if stops.include? params[:id]
      @is_favourite = true
    end
  end
  erb :stop_detail
end

get '/stop/:id/favourite' do
  cookie = request.cookies["bus_stops"]
  if cookie
    stops = cookie.split(',')
    if stops.include? params[:id]
      stops.delete(params[:id])
    else
      stops << params[:id]
    end
    response.set_cookie("bus_stops", {:value => stops.join(','), :path => "/"})
  else
    response.set_cookie("bus_stops", {:value => params[:id], :path => "/"})
  end
  redirect request.referer
end

post '/search' do
  redirect "/stop/#{params[:stop]}"
end