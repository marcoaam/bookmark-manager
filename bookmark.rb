require 'sinatra'
require 'data_mapper'
require 'rack-flash'
require './lib/link'
require './lib/tag'
require './lib/user'
require './app/data_mapper_setup'
require './lib/send_email'
require 'rest-client'

class BookmarkManager < Sinatra::Base

	enable :sessions
	set :session_secret, 'super secret'
	use Rack::Flash
	use Rack::MethodOverride

	get '/' do
		@links = Link.all
		erb :index
	end

	post '/links' do
	  url = params[:url]
	  title = params[:title]
	  tags = params[:tags].split(" ").map do |tag|
  		Tag.first_or_create(:text => tag)
		end
		Link.create(:url => url, :title => title, :tags => tags)
	  redirect to('/')
	end

	get '/tags/:text' do
	  tag = Tag.first(:text => params[:text])
	  @links = tag ? tag.links : []
	  erb :index
	end

	get '/users/new' do
		@user = User.new
		erb :"users/new"
	end

	get '/users/recover-password' do
		erb :"users/recover-password"
	end

	post '/users/recover-password' do
		user = User.first(:email => params[:email])
		if user
			user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
			user.password_token_timestamp = Time.now
			user.save
			send_simple_message(user)
			flash[:notice] = "A email has been sent with a temporary password, check your inbox and follow instructions"
			redirect to('/')
		else
			flash[:notice] = "Email not valid"
			redirect to('/users/recover-password')
		end
	end

	get '/users/reset-password/:token' do
		@token = params[:token]
		erb :"users/change-password"
	end

	post '/users/set-new-password' do
		user = User.first(:password_token => params[:token])
		user.update(:password => params[:password],
								:password_confirmation => params[:password_confirmation],
								:password_token => nil,
								:password_token_timestamp => nil)
		flash[:notice] = "Password succesfully changed, you can sign in with your password now"
		redirect to("/")
	end

	post '/users' do
		@user = User.create(:email => params[:email],
												:password => params[:password],
												:password_confirmation => params[:password_confirmation])
		if @user.save
			session[:user_id] = @user.id
			redirect to('/')
		else
			flash.now[:errors] = @user.errors.full_messages
			erb :"users/new"
		end
	end

	get '/sessions/new' do
		erb :"sessions/new"
	end

	post '/sessions' do
  email, password = params[:email], params[:password]
  user = User.authenticate(email, password)
  if user
    session[:user_id] = user.id
    redirect to('/')
  else
    flash[:errors] = ["The email or password is incorrect"]
    erb :"sessions/new"
  end
	end

	delete '/sessions' do
		session[:user_id] = nil
		flash[:notice] = "Good bye!"
		redirect to('/')
	end

	get '/links/new' do
		erb :"links/new"
	end

	helpers do

	  def current_user    
	    @current_user ||= User.get(session[:user_id]) if session[:user_id]
	  end

	end

end