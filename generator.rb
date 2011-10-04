require 'net/http'
require 'uri'
require 'thread'

class Generator

	LOCAL_FILENAME = "added_words.txt"
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
		
		@added_words = {}
		@added_words[:intro] = []
		@added_words[:adjective] = [] 
		@added_words[:modifier] = [] 
		@added_words[:creature] = []
		@added_words[:place] = []
		@added_words[:tag] = []

		@file_lock = Mutex.new

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

		#Read in our file of existing words 
		begin
			File.open(LOCAL_FILENAME, "r").each do |line|
				m = line.match /(\w*): (.*)/
				if(m != nil)
					type = m[1].to_sym
					word = m[2]
					@words[type] << word
					@added_words[type] << word
				end
			end
		rescue SystemCallError #if the file doesn't exist
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

	def update_file
		return #we can't do shit if we can't write to this file
		@file_lock.synchronize {
			outf = File.new(LOCAL_FILENAME, "w")
			@added_words.each do |type, items|
				items.each do |item|
					outf.write("#{type.to_s}: #{item}\n")
				end
			end

			outf.close()
		}
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
				@added_words[type] << word
				update_file()
			end
		else
			return "That's not a type of word I recognize."
		end
		
		return nil
	end

	def delete(type, word)
		type = type.to_sym
		if(@added_words.has_key? type) #make sure we weren't passed a bogus type
			if( @added_words[type].delete(word) != nil ) #the word was previously in the array
				update_file()
			end
		end
	end

	def get_added_words
		return @added_words
	end
end
