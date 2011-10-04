#Import all the packages required for magic
require 'rubygems'
require 'sinatra'
require 'net/http'
require 'uri'

#Do this stuff when we start up in production (i.e. not every time a request comes in)
configure :production do

	#Fetch the original BMTG's database dump	
	fullsrc = Net::HTTP.get(URI.parse("http://www.gandronics.com/bmovie_dump.php"))
	#Split the file in to an array of lines, using HTMl tags as line boundaries
	lines = fullsrc.split(/<[^>]*>/)
	#Pick only the lines of the format "text: more text"
	lines = lines.select{|item| item =~ /\w*: .*/}

	#dimension our arrays
	$intros = []
	$adjectives = [] 
	$modifiers = [] 
	$creatures = []
	$places = []
	$tags = []

	#For each line in the file
	lines.each do |item|
		#Based on the first letter of the line, figure out whether it's an 
		#intro, adjective, modifier, creature, place, or tag and push it on to 
		#the appropriate array using a regex to extract the rest of the line
		case item[0,1]
		when 'i'
			m = item.match /intro: (.*)/
			$intros << m[1]
		when 'a'
			m = item.match /adjective: (.*)/
			$adjectives << m[1]
		when 'm'
			m = item.match /modifier: (.*)/
			$modifiers << m[1]
		when 'c'
			m = item.match /creature: (.*)/
			$creatures << m[1]
		when 'p'
			m = item.match /place: (.*)/
			$places << m[1]
		when 't'
			m = item.match /tag: (.*)/
			$tags << m[1]
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
		title = $intros.choice + " " + title
	end

	#One in four chance to pick a random adjective 
	if(0.25 < rand)
		title += $adjectives.choice + " "
	end

	if(0.25 < rand)
		title += $adjectives.choice + " "
	end

	if(0.5 < rand)
		title += $modifiers.choice 
	end

	#We always have a creature
	title += $creatures.choice

	if(0.5 < rand)
		title += " From " + $places.choice 
	end

	if(0.5 < rand)
		title += $tags.choice
	end

	#Return our assembled title
	return title
end


#This is where the magic of Sinatra, the framework, happens
#When someone makes a request to the page, generate a title, and then render
#the page template (views/bmovie.erb), and substitute the generated title in to 
#the template
get '/' do
	erb :bmovie, :locals => {:title => generate()}
end

get '/dump' do
	dump = ""
	$intros.each { |i| dump += "intro: #{i}<br/>\n" }
	$adjectives.each { |i| dump += "adjective: #{i}<br/>\n" }
	$modifiers.each { |i| dump += "modifier: #{i}<br/>\n" }
	$creatures.each { |i| dump += "creature: #{i}<br/>\n" }
	$places.each { |i| dump += "place: #{i}<br/>\n" }
	$tags.each { |i| dump += "tag: #{i}<br/>\n" }

	return dump
end
