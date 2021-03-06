require 'sinatra/base'
require 'rack-flash'

class UsersController < ApplicationController

   use Rack::Flash

   get '/users' do
     if Helpers.is_logged_in?(session)
       @user = User.find(session[:user_id])
       @users = User.all
       erb :'/users/index'
     else
       flash[:message] = "Please signup or login to view that page."
       redirect to '/'
     end
   end

  get '/signup' do
    if Helpers.is_logged_in?(session)
      @user = User.find(session[:user_id])
      flash[:message] = "You are already logged in."
      redirect to "/users/#{@user.slug}"
    else
      erb :'users/signup'
    end
  end

  post '/signup' do
    @user = User.create(username: params[:username], email: params[:email], password: params[:password])
    if @user.valid?
      session[:user_id] = @user.id
      redirect "/users/#{@user.slug}"
    elsif @user.invalid? && User.find_by(username: @user.username)
      flash[:message] = "#{@user.username_validation_method}."
      redirect '/signup'
    else
        flash[:message] = "You must fill out all fields to sign up."
        redirect '/signup'
    end
  end

  get '/login' do
    if Helpers.is_logged_in?(session)
     @user = Helpers.current_user(session)
     flash[:message] = "You are already logged in."
     redirect to "/users/#{@user.slug}"
    else
     erb :'/users/login'
    end
  end

  post '/login' do
   @user = User.find_by(username: params[:username])
   if @user && @user.authenticate(params[:password])
     session[:user_id] = @user.id
     redirect "/users/#{@user.slug}"
   else
      flash[:message] = "The username or password is incorrect."
      redirect '/login'
   end
 end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'/users/show'
  end

  get '/logout' do
    session.clear
    redirect '/'
  end


end
