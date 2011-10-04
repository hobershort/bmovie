#Import all the packages required for magic
require 'rubygems'
require 'sinatra'
require './generator'

helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end

gen = ""

#Do this stuff when we start up in production (i.e. not every time a request comes in)
configure :production do
	gen = Generator.new()
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
