
local localized
local loc = GetLocale()


-----------------------
--      Engrish      --
-----------------------

local engrish = {
	PART_GSUB = "%s%(Part %d+%)",
	PART_FIND = "(.+)%s%(Part %d+%)",

	-- Mapping.lua
	COORD_MATCH = "%(([%d.]+),%s?([%d.]+)%)",
}


----------------------
--      German      --
----------------------

if loc == "deDE" then localized = {
	PART_GSUB = "%s%(Teil %d+%)",
	PART_FIND = "(.+)%s%(Teil %d+%)",
	["(.*) is now your home."] = "(.*) ist jetzt Euer Zuhause.",
	["Quest accepted: (.*)"] = "Quest angenommen: (.*)",
	["^You .*Hitem:(%d+).*(%[.+%])"] = "^Ihr .*Hitem:(%d+).*(%[.+%])",
	["|cffff4500This quest is not listed in your current guide"] = "|cffff4500Diese Quest ist nicht in deinem Guide",
} end


----------------------
--      French      --
----------------------

if loc == "frFR" then localized = {
	PART_GSUB = "%s%(Partie %d+%)",
	PART_FIND = "(.+)%s%(Partie %d+%)",
	["(.*) is now your home."] = "(.*) est maintenant votre foyer.",
	["Quest accepted: (.*)"] = "Qu\234te accept\233e: (.*)",
	["^You .*Hitem:(%d+).*(%[.+%])"] = "^Vous .*Hitem:(%d+).*(%[.+%])",
	["|cffff4500This quest is not listed in your current guide"] = "|cffff4500Cette qu\234te n'est pas list\233 dans votre guide actuel",
} end


----------------------
--      Russian     --
----------------------

if loc == "ruRU" then localized = {
	PART_GSUB = "%s%(\208\167\208\176\209\129\209\130\209\140 %d+%)",
	PART_FIND = "(.+)%s%(\208\167\208\176\209\129\209\130\209\140 %d+%)",
	["(.*) is now your home."] = "\208\146\208\176\209\136 \208\189\208\190\208\178\209\139\208\185 \208\180\208\190\208\188 - (.*).",
	["Quest accepted: (.*)"] = "\208\159\208\190\208\187\209\131\209\135\208\181\208\189\208\190 \208\183\208\176\208\180\208\176\208\189\208\184\208\181: (.*)",
	["^You .*Hitem:(%d+).*(%[.+%])"] = "^\208\146\208\176\209\136\208\176 .*H\208\180\208\190\208\177\209\139\209\135\208\176:(%d+).*(%[.+%])",
	["|cffff4500This quest is not listed in your current guide"] = "|cffff4500\208\173\209\130\208\190\208\179\208\190 \208\183\208\176\208\180\208\176\208\189\208\184\209\143 \208\189\208\181\209\130 \208\178 \208\178\209\139\208\177\209\128\208\176\208\189\208\189\208\190\208\188 \209\128\209\131\208\186\208\190\208\178\208\190\208\180\209\129\209\130\208\178\208\181",
} end


-- Metatable majicks... makes localized table fallback to engrish, or fallback to the index requested.
-- This ensures we ALWAYS get a value back, even if it's the index we requested originally
TOURGUIDE_LOCALE = localized and setmetatable(localized, {__index = function(t,i) return engrish[i] or i end})
	or setmetatable(engrish, {__index = function(t,i) return i end})
