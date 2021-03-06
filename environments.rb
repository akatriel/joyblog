configure :development do
 set :path, 'sqlite3:joyblog.sqlite3'
 set :show_exceptions, true
end

configure :production do
  # Database connection
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
 
  ActiveRecord::Base.establish_connection(
    :adapter  => 'postgresql',
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
end

 # config.active_record.raise_in_transactional_callbacks = true