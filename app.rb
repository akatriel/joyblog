require 'sinatra'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require './environments'
require 'sinatra/cross_origin'
require 'aws-sdk'
require 'pp'

class Rightbrain < ActiveRecord::Base
	has_many :uploads
end

class Leftbrain < ActiveRecord::Base
	has_many :uploads
end

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])
})

s3 = Aws::S3::Resource.new
S3_BUCKET = s3.bucket(ENV['AWS_BUCKET'])

class Upload < ActiveRecord::Base
	belongs_to :leftbrain
	belongs_to :rightbrain
end

before /leftbrain|rightbrain/ do

	@s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')

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
	@uploads
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
	@uploads = {}
	@leftbrain.each do |i|
		@uploads[i.id] = Upload.where(leftbrainid: i.id)
	end
	erb :leftbrainFeed
end

get '/rightbrain/feed' do
	@rightbrain = Rightbrain.all.reverse
	@uploads = {}
	@rightbrain.each do |i|
		@uploads[i.id] = Upload.where(rightbrainid: i.id)
	end
	erb :rightbrainFeed
end

get '/leftbrain/:id' do
	@leftbrain = Leftbrain.find params[:id]
	@uploads = Upload.where(leftbrainid: @leftbrain.id)
	erb :leftbrainEdit
end

get '/rightbrain/:id' do
	@rightbrain = Rightbrain.find params[:id]
	@uploads = Upload.where(rightbrainid: @rightbrain.id)
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

get '/leftbrain/:id/addphoto' do
	cross_origin
	@leftbrain = Leftbrain.find params[:id]
	erb :leftbrainPhoto
end

get '/rightbrain/:id/addphoto' do
	cross_origin
	@rightbrain = Rightbrain.find params[:id]
	erb :rightbrainPhoto
end

post '/leftbrain/:id/addphoto' do
	leftbrain = Leftbrain.find params[:id]
	f = Upload.new
	f.url = params[:file]
	f.leftbrainid = leftbrain.id
	if f.save
		redirect "/leftbrain/#{leftbrain.id}"
	else
		flash[:alert] = "There was an issue uploading this file."
		redirect "/leftbrain/#{leftbrain.id}/addphoto"
	end
end

post '/rightbrain/:id/addphoto' do
	rightbrain = Rightbrain.find params[:id]
	f = Upload.new
	f.url = params[:file]
	f.rightbrainid = rightbrain.id
	if f.save
		redirect "/rightbrain/#{rightbrain.id}"
	else
		flash[:alert] = "There was an issue uploading this file."
		redirect "/rightbrain/#{rightbrain.id}/addphoto"
	end
end

get '/upload/:id/delete' do
	@upload = Upload.find params[:id]
	erb :deleteUpload
end

delete '/upload/:id/delete' do
	u = Upload.find params[:id]
	redurl = ""
	unless u.leftbrainid.nil?
		redurl = '/leftbrain/' << u.leftbrainid.to_s
	else
		redurl = '/rightbrain/' << u.rightbrainid.to_s
	end
	u.destroy
	redirect redurl
end