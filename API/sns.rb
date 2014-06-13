require 'rubygems'
require 'sinatra'
require 'sinatra/config_file'
require 'aws-sdk-core'
require 'yaml'
require 'yajl'
require 'sequel'
require 'sequel/adapters/tinytds'
require 'logger'
require 'sinatra/base'
require './DB.rb'

#set settings for AWS
config_file './aws.yml'

#set AWS access
Aws.config[:access_key_id] = settings.ACCESS_KEY_ID
Aws.config[:secret_access_key] = settings.SECRET_ACCESS_KEY
Aws.config[:region] = settings.REGION

#set settings for DB
config_file './database.yml'

#set DB parameters with sequel
DBK = Sequel.connect(
    :adapter  => settings.ADAPTER,
    :host     => settings.HOST,
    :database => settings.DATABASE,
    :user     => settings.NAME,
    :password => settings.PASSWORD,
)


before do
  content_type'application/json'
end

get "/" do
  content_type'html'
  erb :index
end


get "/sendtest" do
  content_type'html'
  erb :message
end

#send sns message to a topic
post "/sendtest" do
  sns = Aws::SNS.new
  resp = sns.publish(
      target_arn: "arn:aws:sns:us-west-2:292873453561:prueba",
      message: params[:message]
  )
  "Message published"  
end

get "/regdevice/e-diet/gcm/post" do
  # matches "GET /post?token=foo&user=bla"
  sns = Aws::SNS.new
  resp = sns.create_platform_endpoint(
    platform_application_arn: "arn:aws:sns:us-west-2:292873453561:app/GCM/e-diet",
    token: params[:token],
    custom_user_data: params[:user],
    attributes: { "Enabled" => "true" }
  )
  "registrado"
end

get "/users/add" do
  content_type'html'
  erb :usersK
end


post "/users/add" do
  #set dataset
  users = DB[:UsersKanjo]
  #create new user in DB
  users.insert(:name => params[:user], :mail => params[:mail], :creationDate => Time.now.getutc)
  users.returning (:idUser)
  puts "user added"
end

get "/users/add/post" do
  # maches "GET /post?user=bla&mail=bla"
  #set dataset
  users = DBK[:UsersKanjo]
  #create new user in DB
  users.insert(:name => params[:user], :mail => params[:mail], :creationDate => Time.now.getutc)
  puts "user added"
end