require 'sinatra'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require './environments'

class RightBrain < ActiveRecord::Base
end

class LeftBrain < ActiveRecord::Base
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


get '/admin' do
	protected!
	@LeftBrain = LeftBrain.all.reverse
	@rightBrain = RightBrain.all.reverse
	erb :admin
end

post '/leftBrain/create' do
	post = LeftBrain.new(title: params[:title], body: params[:body])
	if post.save
		redirect 'leftBrain/feed'
	else
		flash[:alert] = "There was an issue creating the post."
		redirect '/admin'
	end
end

post '/rightBrain/create' do
	post = RightBrain.new(title: params[:title], body: params[:body])
	if post.save
		redirect 'rightBrain/feed'
	else
		flash[:alert] = "There was an issue creating the post."
		redirect '/admin'
	end
end

get '/leftBrain/feed' do
	@leftBrain = LeftBrain.all.reverse
	erb :leftBrainFeed
end

get '/rightBrain/feed' do
	@leftBrain = RightBrain.all.reverse
	erb :rightBrainFeed
end

get '/leftBrain/:id' do
	@LeftBrain = LeftBrain.find params[:id]
	erb :leftBrainEdit
end

get '/rightBrain/:id' do
	@rightBrain = RightBrain.find params[:id]
	erb :rightBrainEdit
end

put '/leftBrain/:id' do
  p = LeftBrain.find params[:id]
  p.body = params[:body]
  p.title = params[:title]
  p.updated_at = Time.now
  if p.save
  	redirect '/admin'
  else
  	flash[:alert] = "There was an error updating your post"
  	redirect 'leftBrain/:id'
  end
end

put '/rightBrain/:id' do
  p = RightBrain.find params[:id]
  p.body = params[:body]
  p.title = params[:title]
  p.updated_at = Time.now
  if p.save
  	redirect '/admin'
  else
  	flash[:alert] = "There was an error updating your post"
  	redirect 'rightBrain/:id'
  end
end

get '/leftBrain/:id/delete' do
  @post = LeftBrain.find params[:id]
  erb :leftBrainDelete
end

get '/rightBrain/:id/delete' do
  @post = RightBrain.find params[:id]
  erb :rightBrainDelete
end

delete '/leftBrain/:id' do
  p = LeftBrain.find params[:id]
  p.destroy
  redirect '/admin'
end

delete '/rightBrain/:id' do
  p = RightBrain.find params[:id]
  p.destroy
  redirect '/admin'
end