require 'active_record'
require 'sqlite3'
require 'aws-sdk'
require 'pp'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => './joyblog.sqlite3'
)

class Upload < ActiveRecord::Base
end

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])
})

s3 = Aws::S3::Resource.new
bucket = s3.bucket(ENV['AWS_BUCKET'])

match_counter = {}
bucket.objects.each do |o| 
	match_counter[o.public_url] ||= 0
end
## count occurences of database upload urls against whats in the s3 bucket
Upload.all.each{|u| match_counter[("https:" << u.url)] += 1 unless match_counter[("https:" << u.url)].nil? }




bucket.objects.each do |obj|
	if match_counter[obj.public_url] == 0
		p "deleted: " << obj.public_url
		obj.delete
	end
end
