require 'sinatra'
require 'sinatra/content_for'
require "open-uri"
require "json"
require "yaml"

set :public_folder, File.dirname(__FILE__) + '/static'

API_URL = "http://countdown.tfl.gov.uk/stopBoard/%d"

error do
  @e = request.env['sinatra_error']
  erb :exception
end

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
  @stop_routes = Array.new
  @buses.each do |bus|
    if @stop_routes.include? bus["routeName"]
      #@stop_routes << bus["routeName"]
    else
      @stop_routes << bus["routeName"]
    end
  end
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

get '/api/:id.json' do
  @stop = params[:id]
  response = open(API_URL % @stop){ |f| f.read }
  @data = JSON.parse(response)
  @buses = @data["arrivals"]
  @stop_routes = Array.new
  @buses.each do |bus|
    if @stop_routes.include? bus["routeName"]
      #@stop_routes << bus["routeName"]
    else
      @stop_routes << bus["routeName"]
    end
  end
  @cookie = request.cookies["bus_stops"]
  @is_favourite = false
  if @cookie
    stops = @cookie.split(',')
    if stops.include? params[:id]
      @is_favourite = true
    end
  end
  return @data["arrivals"].to_json
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

get '/stop/:id/:route' do
  @stop = params[:id]
  @route = params[:route]
  response = open(API_URL % @stop){ |f| f.read }
  @data = JSON.parse(response)
  @buses = Array.new
  @data["arrivals"].each do |bus|
    if bus["routeName"] == params[:route]
      @buses << bus
    end
  end
  @cookie = request.cookies["bus_stops"]
  @is_favourite = false
  if @cookie
    stops = @cookie.split(',')
    if stops.include? params[:id]
      @is_favourite = true
    end
  end
  erb :stop_route_detail
end

post '/search' do
  redirect "/stop/#{params[:stop]}"
end