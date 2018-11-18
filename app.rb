
require "sinatra"
require "sinatra/reloader"
require "json"

post_path = File.dirname(__FILE__) + "/data/post.json"
user_path = File.dirname(__FILE__) + "/data/user.json"

enable :sessions

get '/' do
  erb :login
end

post '/login' do

  data = []
  open(user_path) do |io|
    data = JSON.load(io)
  end

  name = nil
  id = nil
  data.each do |row|
    if row['user_name'] == params[:user_name] && row['user_pass'] == params[:user_pass]
      id = row['user_id']
      name = row['user_name']
    else
      session[:user_id] = nil
    end
  end

  session[:user_id] = id
  session[:user_name] = name


  redirect '/form'
end

get '/signup' do
  erb :signup
end

post '/signup' do

  data = []
  open(user_path) do |io|
    data = JSON.load(io)
  end

  if data.size > 0
    last_id = data.last['user_id']
  else
    last_id = 0
  end

  datum = {
    "user_id" => last_id + 1,
    "user_name" => params[:new_user_name],
    "user_pass" => params[:new_user_pass]
  }

  data << datum

  open(user_path, "w") do |io|
    JSON.dump(data, io)
  end

  redirect '/'

end

get '/form' do

  if session[:user_id].nil?
    redirect '/'
  end

  erb :form
end

get '/logout' do
  session[:user_id] = nil
  redirect '/'
end

post '/save' do

  datum = {
    "creater_id" => session[:user_id],
    "creater_name" => session[:user_name],
    "up-time" => DateTime.now,
    "msg" => params[:msg]
  }

  data = []
  open(post_path) do |io|
    data = JSON.load(io)
  end

  data << datum

  open(post_path, "w") do |io|
    JSON.dump(data, io)
  end

  redirect '/view'
end

get '/view' do


  open(post_path) do |io|
    @data = JSON.load(io)
  end

  erb :view
end
