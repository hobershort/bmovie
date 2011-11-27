require "data_mapper"

class Best
	include DataMapper::Resource
	property :id,	Serial
	property :title, String
	property :votes, Integer, 	:default => 0
end
