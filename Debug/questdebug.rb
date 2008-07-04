#! /c/ruby/bin/ruby

require 'xmlsimple'



credentials = File.read("c:\\Users\\Tekkub\\.wowicreds.txt")
username, password = $1, $2 if credentials =~ /\A(.+)\n(.+)\Z/

unless username && password
	puts "Could not find username and password"
	exit 1
end


#~ first_guide = $*[0]
#~ unless first_guide
	#~ puts "Usage: first_guide"
	#~ exit 1
#~ end


guides = []

xml_file = XmlSimple.xml_in File.read("Guides.xml")
xml_file["Script"].map{|v| v["file"]}.each do |lua_file|
	guide = File.read lua_file
	if guide =~ /TourGuide:RegisterGuide\("([^"]+)", "?([^"]+)"?, "?[^"]+"?, function\(\).*\[\[(.+)\]\]/m
		guide_name, next_guide, data = $1, $2, $3
		guides << data
	else
		puts "*** Error parsing #{lua_file}"
		exit 1
	end
end

quests = {"A" => [], "C" => [], "T" => [], "O" => []}
ACT = %w|A C T|
tag_regexes = [/\|(O|NODEBUG|T)\|/, /\|(N|R|C|Z|SZ|Q|QO|PRE)\|[^|]+\|/, /\|(QID|U|L)\|\d+\|/, /\|L\|\d+ \d+\|/]
actiontypes = "ACTKRHhFfNBbUP"

guides.each do |guide|
	lines = guide.split(/[\n\r]+/)
	lines.each do |line|
		tag_stripped = line.clone
		tag_regexes.each {|re| tag_stripped.gsub!(re, "")}
		puts "Bad tag? " + line if tag_stripped =~ /\|/

		puts "TODO! " + line if line =~ /todo/i

		puts "Bad char - " + line if line =~ /[“”’]/

		if line =~ /\A(.) ([^|]+)\|/
			type, name = $1, $2
			puts "Invalid action - " + line unless actiontypes.match(type)

			if line =~ /\|QID\|(\d+)\|/
				qid = $1
				quests["O"] << qid if line =~ /\|O\|/
				puts "Unneeded NODEBUG flag: " + line if line =~ /\|O\|/ && line =~ /\|NODEBUG\|/
				unless line =~ /\|NODEBUG\|/
					puts "Bad title case " + line if name =~ /[^:]\s(For|A|The|Or|In|Then|From|To)\s/

					if ACT.include? type
						#~ puts "Duplicate objective: #{line}" if quests[type].include? qid
						quests[type] << qid unless quests[type].include? qid
					else
						puts "QID on non-ACT objective: #{line}"
					end
				end
			else
				puts "Missing QID: #{line}" if ACT.include? type
			end
		end
	end
end

puts "Missing turnin: #{(quests["A"] - quests["T"]).join(", ")}" unless (quests["A"] - quests["T"]).empty?
puts "Missing accept: #{(quests["T"] - quests["A"] - quests["O"]).join(", ")}" unless (quests["T"] - quests["A"] - quests["O"]).empty?
puts "Missing accept and turnin: #{(quests["C"] - quests["A"] - quests["T"]).join(", ")}" unless (quests["C"] - quests["A"] - quests["T"]).empty?
