
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
	["This panel lets you choose a guide to load.  Upon completion the next guide will load automatically.  Completed guides can be reset by shift-clicking."] = "Hier kannst Du einen Guide ausw\195\164hlen. Nach dessen Beendigung wird der n\195\164chste Guide automatisch geladen. Beendete Guides k\195\182nnen mit Umschalt-Klick zur\195\188ckgesetzt werden.",
	["These settings are saved on a per-char basis."] = "Diese Einstellungen werden pro Charakter gespeichert.",
	["Guides"] = "Guides",
	["Config"] = "Einstellungen",
	["|cff%02x%02x%02x%d%% complete"] = "|cff%02x%02x%02x%d%% abgeschlossen",
	["No Guide Loaded"] = "Kein Guide ausgew\195\164hlt",
	["Accept quest"] = "Quest annehmen",
	["Complete quest"] = "Quest abschlie\195\159en",
	["Turn in quest"] = "Quest abgeben",
	["Kill mob"] = "Gegner t\195\182ten",
	["Run to"] = "Gehe zu",
	["Fly to"] = "Fliege zu",
	["Set hearth"] = "Ruhestein setzen",
	["Use hearth"] = "Ruhestein benutzen",
	["Note"] = "Hinweis",
	["Use item"] = "Gegenstand benutzen",
	["Buy item"] = "Gegenstand kaufen",
	["Boat to"] = "Schiff nach",
	["Get flight point"] = "Flugpunkt holen",
	["Tour Guide - Help"] = "Tour Guide - Hilfe", 
	["Confused?  GOOD!  Okey, fine... here's a few hints."] = "Verwirrt? Okay, gut... hier sind ein paar Tipps.",
	["Automatically track quests"] = "Automatische Questverfolgung",
	["Automatically toggle the default quest tracker for current 'complete quest' objectives."] = "Standard-Questverfolgung f\195\188r die aktuellen 'Quest abschlie\195\159en'-Ziele aktivieren.",
	["Show status frame"] = "Questziele anzeigen",
	["Display the status frame with current quest objective."] = "Anzeige mit den aktuellen Questzielen aktivieren",
	["Map note coords"] = "Koordinaten anzeigen",
	["Map coordinates found in tooltip notes (requires TomTom)."] = "Guide-Koordinaten auf der Karte anzeigen (ben\195\182tigt TomTom)",
	["Automatically map questgivers"] = "Questgeber anzeigen",
	["Automatically map questgivers for accept and turnin objectives (requires LightHeaded and TomTom)."] = "Automatisch Questgeber zum Annehmen und Abgeben auf der Karte anzeigen (erfordert LightHeaded und TomTom.)",
	["Always map coords from notes"] = "Koordinaten immer aus Guide",
	["Map note coords even when LightHeaded provides coords."] = "Verwende Guide-Koordinaten auch dann, wenn LightHeaded Koordinaten anbietet.",
	["Help"] = "Hilfe",
	["Guides"] = "Guides",
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
