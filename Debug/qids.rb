#! /c/ruby/bin/ruby

require 'net/http'
require 'xmlsimple'


faction = $*[0]
unless faction
	puts "Usage: faction (1 for alliance, 2 for horde)"
	exit 1
end


qids = []

def mine_quests(http, addr, qids)
	#~ puts "Querying zone quests - " + addr
	res = http.get addr
	if res.body =~ /id: 'quests'(.*)\]\}\)\;/
		quests = $1.gsub("\\'", "TEKTOKEN")
		quests.scan(/\{id:(\d+),name:'([^']+)',[^}]+,side:(\d)[^}]+\}/) do |id,name,side|
			qids << [id, name.gsub("TEKTOKEN", "'"), side]
			## Sides: 1 = Alliance, 2 = Horde, 3 = Both
		end
	end
end
#~ {id:10864,name:'A Burden of Souls',level:61,reqlevel:58,side:2,xp:9800,money:20000,category:3483,category2:8},


def get_quest_info(http, qids, qid)
	return qids.assoc(qid) if qids.assoc(qid)

	res = http.get "/?quest=" + qid
	if res.body =~ /g_initPath\(\[0,3,([\d,-]+)\]\)/
		zone = $1.gsub(",", ".")
		mine_quests(http, "/?quests=" + zone, qids)
	end

	qids.assoc(qid)
end


def find_qid(http, quest_name, faction)
	res = http.get "http://www.wowhead.com/?search=" + quest_name.gsub(" ", "+")

	if res.body =~ /id: 'quests'(.*)\]\}\)\;/
		quests = $1.gsub("\\'", "TEKTOKEN")
		quests.scan(/\{id:(\d+),name:'([^']+)',[^}]+,side:(\d)[^}]+\}/) do |id,name,side|
			return id if [faction, "3"].include? side
		end
	end
end


def do_gsubs(lua_file, gsubs)
	old = File.open(lua_file)
	new = File.open(lua_file+".tmp", "w")
	while old.gets do
		line = $_
		gsubs.each {|old_id,new_id| line.gsub! old_id, new_id}
		# change $_, then...
		new.print line
	end
	old.close
	new.close
	#~ File.rename(old_file, "old.orig")
	File.rename(lua_file+".tmp", lua_file)
end


Net::HTTP.start("www.wowhead.com") do |http|
	guides = []

	xml_file = XmlSimple.xml_in File.read("Guides.xml")
	xml_file["Script"].map{|v| v["file"]}.each do |lua_file|
		gsubs = []

		guide = File.read lua_file
		if guide =~ /TourGuide:RegisterGuide\("([^"]+)", "?([^"]+)"?, "?[^"]+"?, function\(\).*\[\[(.+)\]\]/m
			guide_name, next_guide, data = $1, $2, $3

			lines = data.split(/[\n\r]+/)
			lines.each do |line|
				if line =~ /\A. ([^|]+).*\|QID\|(\d+)\|/
					name, qid = $1, $2, $3
					quest_info = get_quest_info(http, qids, qid)
					if quest_info.nil?
						puts "No quest data found - " + line
					else
						puts "Name mismatch - " + line unless quest_info[1] == name.strip.gsub(/ \(Part \d+\)/, "")

						unless [faction, "3"].include? quest_info[2]
							replacement = find_qid(http, quest_info[1], faction)
							gsubs << [qid, replacement] if replacement
							#~ puts "Incorrect faction (#{quest_info[2]}) - " + line + " - Possible replacement: " +
						end
					end
				end
			end

			do_gsubs(lua_file, gsubs) unless gsubs.empty?
		else
			puts "*** Error parsing #{lua_file}"
			exit 1
		end
	end
end
