require 'sinatra'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require './environments'

class Rightbrain < ActiveRecord::Base
end

class Leftbrain < ActiveRecord::Base
end

enable :sessions

helpers do
	def protected!
		return if authorized?
		headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
		halt 401, "Not authorized\n"
	end

	def authorized?
		user = ENV['JOYBLOG_USERNAME']
		pass = ENV['JOYBLOG_PASSWORD']

		@auth ||=  Rack::Auth::Basic::Request.new(request.env)
		@auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [user, pass]
	end	
	def h(text)
    	Rack::Utils.escape_html(text)
  	end
end

get '/' do
	erb :landing
end

get '/admin' do
	protected!
	@leftbrain = Leftbrain.all.reverse
	@rightbrain = Rightbrain.all.reverse
	erb :admin
end

post '/leftbrain/create' do
	post = Leftbrain.new(title: params[:title], body: params[:body])
	if post.save
		redirect 'leftbrain/feed'
	else
		flash[:alert] = "There was an issue creating the post."
		redirect '/admin'
	end
end

post '/rightbrain/create' do
	post = Rightbrain.new(title: params[:title], body: params[:body])
	if post.save
		redirect 'rightbrain/feed'
	else
		flash[:alert] = "There was an issue creating the post."
		redirect '/admin'
	end
end

get '/leftbrain/feed' do
	@leftbrain = Leftbrain.all.reverse
	erb :leftbrainFeed
end

get '/rightbrain/feed' do
	@rightbrain = Rightbrain.all.reverse
	erb :rightbrainFeed
end

get '/leftbrain/:id' do
	@leftbrain = Leftbrain.find params[:id]
	erb :leftbrainEdit
end

get '/rightbrain/:id' do
	@rightbrain = Rightbrain.find params[:id]
	erb :rightbrainEdit
end

put '/leftbrain/:id' do
  p = Leftbrain.find params[:id]
  p.body = params[:body]
  p.title = params[:title]
  p.updated_at = Time.now
  if p.save
  	redirect '/admin'
  else
  	flash[:alert] = "There was an error updating your post"
  	redirect 'leftbrain/:id'
  end
end

put '/rightbrain/:id' do
  p = Rightbrain.find params[:id]
  p.body = params[:body]
  p.title = params[:title]
  p.updated_at = Time.now
  if p.save
  	redirect '/admin'
  else
  	flash[:alert] = "There was an error updating your post"
  	redirect 'rightbrain/:id'
  end
end

get '/leftbrain/:id/delete' do
  @post = Leftbrain.find params[:id]
  erb :leftbrainDelete
end

get '/rightbrain/:id/delete' do
  @post = Rightbrain.find params[:id]
  erb :rightbrainDelete
end

delete '/leftbrain/:id' do
  p = Leftbrain.find params[:id]
  p.destroy
  redirect '/admin'
end

delete '/rightbrain/:id' do
  p = Rightbrain.find params[:id]
  p.destroy
  redirect '/admin'
end