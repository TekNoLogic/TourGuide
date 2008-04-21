
--~ local path = "C:\\Program Files\\World of Warcraft\\Interface\\AddOns\\TourGuide\\"

local function readfile(file)
	local f = io.open(file, "r")
	if not f then return "" end
	local o = f:read("*all")
	f:close()
	return o
end

local function writefile(file, data)
	local f = assert(io.open(file, "w"), "Cannot open file to write")
	f:write(data)
	f:close()
end

local function shell(c)
	os.execute(c.." > temp")
	local o = readfile("temp")
	os.execute("del temp")
	return o
end


dofile("LH_QIDNames.lua")

local US, RS = string.char(31), string.char(30)
local matchstr = string.format("%s(%%d+)%s%s([^%s]+)%s", US, US, RS, RS, RS)

local qids, dups, count, numdups = {}, {}, 0, 0
for qid,name in string.gfind(LH_QIDNames, matchstr) do
	count = count + 1
	if not qids[name] then
		qids[name] = qid
	else
		numdups = numdups + 1
		dups[name] = true
	end
end

for name in pairs(dups) do qids[name] = nil end

local files = {}
for file in string.gfind(shell("dir /b TourGuide_Alliance\\*.lua"), "([^\n]+)") do table.insert(files, "TourGuide_Alliance\\"..file) end
for file in string.gfind(shell("dir /b TourGuide_Horde\\*.lua"), "([^\n]+)") do table.insert(files, "TourGuide_Horde\\"..file) end

for _, filename in pairs(files) do
	local orig = readfile(filename)
	local newfile = ""
	for line in string.gfind(orig, "([^\n]*)\n") do
		local _, _, tag, questname, rest = string.find(line, "^([ACT]) ([^|]+)(.*)$")
		if questname and string.sub(questname, string.len(questname)) == " " then questname = string.sub(questname, 1, string.len(questname) - 1) end
		local newline = questname and not string.find(line, "|QID|%d+|") and qids[questname] and (line.." |QID|"..qids[questname].."|")
	--~ 	local newline = questname and not string.find(line, "|QID|%d+|") and (line.." |QID|"..(qids[questname] or "???").."|")

		newfile = newfile..(newline or line).."\n"
	end

	writefile(filename, newfile)
end
