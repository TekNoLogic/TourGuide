#! /c/ruby/bin/ruby

require 'xmlsimple'


guides = {}

xml_file = XmlSimple.xml_in File.read("Guides.xml")
xml_file["Script"].map{|v| v["file"]}.each do |lua_file|
	guide = File.read lua_file
	if guide =~ /TourGuide:RegisterGuide\("([^"]+)", "?([^"]+)"?, "?[^"]+"?, function\(\).*\[\[(.+)\]\]/m
		guide_name, next_guide, data = $1, $2, $3
		guides[guide_name] = {"next_guide" => next_guide, "data" => data, "file_name" => lua_file}
		guides["first"] ||= guides[guide_name]
	else
		puts "*** Error parsing #{lua_file}"
		exit 1
	end
end

guide = guides["first"]
begin
	next_guide = guide["next_guide"] == "nil" ? nil : guide["next_guide"]
	puts "Sequence ends at guide " + guide["file_name"] unless next_guide
	guide = next_guide ? guides[next_guide] : nil
	puts "Error finding guide " + next_guide if not guide and next_guide
end while guide
