require 'net/http'
require 'uri'

class Generator
	def initialize()
		#Fetch the original BMTG's database dump	
		fullsrc = Net::HTTP.get(URI.parse("http://www.gandronics.com/bmovie_dump.php"))
		#Split the file in to an array of lines, using HTMl tags as line boundaries
		lines = fullsrc.split(/<[^>]*>/)
		#Pick only the lines of the format "text: more text"
		lines = lines.select{|item| item =~ /\w*: .*/}

		#dimension our arrays
		@words = {}
		@words[:intro] = []
		@words[:adjective] = [] 
		@words[:modifier] = [] 
		@words[:creature] = []
		@words[:place] = []
		@words[:tag] = []

		#For each line in the file
		lines.each do |item|
			#Based on the first letter of the line, figure out whether it's an 
			#intro, adjective, modifier, creature, place, or tag and push it on to 
			#the appropriate array using a regex to extract the rest of the line
			case item[0,1]
			when 'i'
				m = item.match /intro: (.*)/
				@words[:intro] << m[1]
			when 'a'
				m = item.match /adjective: (.*)/
				@words[:adjective] << m[1]
			when 'm'
				m = item.match /modifier: (.*)/
				@words[:modifier] << m[1]
			when 'c'
				m = item.match /creature: (.*)/
				@words[:creature] << m[1]
			when 'p'
				m = item.match /place: (.*)/
				@words[:place] << m[1]
			when 't'
				m = item.match /tag: (.*)/
				@words[:tag] << m[1]
			else
				if(item =~ /\S/)
					puts "Line not matched: " + item
				end
			end
		end
	end
	
	#This method will get called each time we get a request, and returns a title
	def generate()

		title = "The "

		#50/50 change to pick a random intro and stick it in front of the title
		if(0.5 < rand)
			title = @words[:intro].choice + " " + title
		end

		#One in four chance to pick a random adjective 
		if(0.25 < rand)
			title += @words[:adjective].choice + " "
		end

		if(0.25 < rand)
			title += @words[:adjective].choice + " "
		end

		if(0.5 < rand)
			title += @words[:modifier].choice 
		end

		#We always have a creature
		title += @words[:creature].choice

		if(0.5 < rand)
			title += " From " + @words[:place].choice 
		end

		if(0.5 < rand)
			title += @words[:tag].choice
		end

		#Return our assembled title
		return title
	end

	def dump()
	
		dump = ""
		@words.each do |type, items|
			items.each do |item|
				dump += "#{type.to_s}: #{item}<br/>\n"
			end
		end
		
		return dump
	end

	def add(type, word)
		type = type.to_sym

		if(word.strip == "")
			return "You have to tell me which word to add."
		end
		
		if(@words.has_key? type)
			if @words[type].include? word
				return "That word is already in the database."
			else
				@words[type] << word
			end
		else
			return "That's not a type of word I recognize."
		end
		
		return nil
	end
end
