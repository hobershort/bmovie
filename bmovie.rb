require 'rubygems'
require 'sinatra'
require 'net/http'
require 'uri'

#fullsrc = Net::HTTP.get(URI.parse("http://www.gandronics.com/bmovie_dump.php"))
configure :production do
	fullsrc = File.read("bmovie_dump.php")
	lines = fullsrc.split(/<[^>]*>/)
	lines = lines.select{|item| item =~ /\w*: .*/}

	item = lines.pop
	$intros = []
	$adjectives = [] 
	$modifiers = [] 
	$creatures = []
	$places = []
	$tags = []

	lines.each do |item|
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


def generate()

	title = "The "

	if(0.5 < rand)
		title = $intros.choice + " " + title
	end

	if(0.25 < rand)
		title += $adjectives.choice + " "
	end

	if(0.25 < rand)
		title += $adjectives.choice + " "
	end

	if(0.5 < rand)
		title += $modifiers.choice 
	end

	title += $creatures.choice

	if(0.5 < rand)
		title += " From " + $places.choice 
	end

	if(0.5 < rand)
		title += $tags.choice
	end

	return title
end

get '/' do
	erb :bmovie, :locals => {:title => generate()}
end
