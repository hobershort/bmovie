#Import all the packages required for magic
require 'rubygems'
require 'sinatra'
require 'data_mapper'
require './generator'
require './best'


helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end

gen = ""


configure :production do
	DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

configure :development do
	DataMapper.setup(:default, "sqlite3:database.db")
end

#Do this stuff when we start up in production (i.e. not every time a request comes in)
configure :production, :development do
	gen = Generator.new()
	DataMapper.auto_migrate!
end

#This is where the magic of Sinatra, the framework, happens
#When someone makes a request to the page, generate a title, and then render
#the page template (views/bmovie.erb), and substitute the generated title in to 
#the template
get '/' do
	erb :bmovie, :locals => {:title => gen.generate()}
end

get '/dump' do
	return gen.dump
end

get '/add' do
	erb :add
end

get '/add/*/*' do |type,word|
	word = h word
	message = gen.add(type, word)
	erb :add, :locals => {:success => (message == nil), :message => message}
end

get '/delete' do
	erb :delete, :locals => {:words => gen.get_added_words}
end

post '/new-best' do
	if(params[:title])
		best = Best.new
		best.title = params[:title]
		best.save
		puts best
		return "Added" 
	else
		return "Error: title submitted to server is null!"
	end
end

get '/best-of' do
	puts Best.all 
	erb :best, :locals => {:best => Best.all()}
end

delete '/*/*' do |type,word|
	gen.delete(type, word)
end
