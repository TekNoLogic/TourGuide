#! /c/ruby/bin/ruby

require 'xmlsimple'



credentials = File.read("c:\\Users\\Tekkub\\.wowicreds.txt")
username, password = $1, $2 if credentials =~ /\A(.+)\n(.+)\Z/

unless username && password
	puts "Could not find username and password"
	exit 1
end


first_guide = $*[0]
unless first_guide
	puts "Usage: first_guide"
	exit 1
end


guides = {}

xml_file = XmlSimple.xml_in File.read("Guides.xml")
xml_file["Script"].map{|v| v["file"]}.each do |lua_file|
	guide = File.read lua_file
	if guide =~ /TourGuide:RegisterGuide\("([^"]+)", "?([^"]+)"?, "[^"]+", function\(\).*\[\[(.+)\]\]/m
		guide_name, next_guide, data = $1, $2, $3
		guides[guide_name] = {"next_guide" => next_guide, "data" => data, "file_name" => lua_file}
		guides["first"] = guides[guide_name] if lua_file == first_guide
	else
		puts "*** Error parsing #{lua_file}"
	end
end

quests = {"A" => [], "C" => [], "T" => []}
ACT = %w|A C T|

guide = guides["first"]
begin
	lines = guide["data"].split(/[\n\r]+/)
	lines.each do |line|
		if line =~ /\A(.) ([^|]+)\|/
			type, name = $1, $2
			if line =~ /\|QID\|(\d+)\|/
				qid = $1
				unless line =~ /\|NODEBUG\|/
					if ACT.include? type
						puts "Duplicate objective: #{line}" if quests[type].include? qid
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

	guide = (guide["next_guide"] == "nil" ? nil : guides[guide["next_guide"]])
end while guide

puts "Missing turnin: #{(quests["A"] - quests["T"]).join(", ")}" unless (quests["A"] - quests["T"]).empty?
puts "Missing accept: #{(quests["T"] - quests["A"]).join(", ")}" unless (quests["T"] - quests["A"]).empty?
puts "Missing accept and turnin: #{(quests["C"] - quests["A"] - quests["T"]).join(", ")}" unless (quests["C"] - quests["A"] - quests["T"]).empty?
