
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
	["Quest accepted: (.*)"] = "Qu\195\170te accept\195\169e: (.*)",
	["^You .*Hitem:(%d+).*(%[.+%])"] = "^Vous .*Hitem:(%d+).*(%[.+%])",
	["|cffff4500This quest is not listed in your current guide"] = "|cffff4500Cette qu\195\170te n'est pas list\195\169e dans votre guide actuel",
	["This panel lets you choose a guide to load.  Upon completion the next guide will load automatically.  Completed guides can be reset by shift-clicking."] = "Ce panneau vous permet de choisir le guide que vous souhaitez suivre.  Lorsqu'il sera termin\195\169, le prochain guide sera charg\195\169 automatiquement.  Shift-Clic r\195\169initialisera un guide d\195\169j\195\160 termin\195\169.",
	["These settings are saved on a per-char basis."] = "Ces r\195\169glages sont sp\195\169cifiques pour chaque personnage.",
	["Guides"] = "Guides",
	["Config"] = "R\195\169glages",
	["|cff%02x%02x%02x%d%% complete"] = "|cff%02x%02x%02x%d%% termin\195\169e",
	["No Guide Loaded"] = "Aucun guide charg\195\169",
	["Accept quest"] = "Acceptez la qu\195\170te",
	["Complete quest"] = "Terminez la qu\195\170te",
	["Turn in quest"] = "Validez la qu\195\170te",
	["Kill mob"] = "Tuez la cr\195\169ature",
	["Run to"] = "Allez \195\160",
	["Fly to"] = "Envolez-vous \195\160",
	["Set hearth"] = "Fixez votre foyer",
	["Use hearth"] = "Utilisez votre pierre de foyer",
	["Note"] = "Note",
	["Use item"] = "Utilisez l'objet",
	["Buy item"] = "Achetz l'objet",
	["Boat to"] = "Prenez le bateau pour",
	["Get flight point"] = "Apprenez une destination",
	["Tour Guide - Help"] = "Tour Guide - Aide",
	["Confused?  GOOD!  Okey, fine... here's a few hints."] = "Vous \195\170tes perdu?  BIEN!  Bon, d'accord... voici quelques indices.",
	["Automatically track quests"] = "Suivi des qu\195\170tes automatique",
	["Automatically toggle the default quest tracker for current 'complete quest' objectives."] = "Affiche automatiquement le suivi des qu\195\170tes pour les objectifs des 'qu\195\170tes en cours'.",
	["Show status frame"] = "Montrer la fen\195\170tre d'\195\169tat",
	["Display the status frame with current quest objective."] = "Montrer la fen\195\170tre d'\195\169tat avec les objectifs courant",
	["Map note coords"] = "Montre les coordonn\195\169es des notes",
	["Map coordinates found in tooltip notes (requires TomTom)."] = "Montre les coordonn\195\169es trouv\195\169es dans le 'tooltip' des notes (n\195\169cessite TomTom)",
	["Automatically map questgivers"] = "Montre automatiquement les donneurs de qu\195\170tes",
	["Automatically map questgivers for accept and turnin objectives (requires LightHeaded and TomTom)."] = "Montre automatiquement les donneurs de qu\195\170tes pour les \195\169tapes de prise de qu\195\170tes det de validation de qu\195\170tes (n\195\169cessite LightHeaded et TomTom.)",
	["Always map coords from notes"] = "Toujours montrer les coordonn\195\169es trouv\195\169es dans les notes",
	["Map note coords even when LightHeaded provides coords."] = "Montrer les coordonn\195\169es trouv\195\169es dans les notes m\195\170me si LightHeaded les fournit.",
	["Help"] = "Aide",
	["Guides"] = "Guides",
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
