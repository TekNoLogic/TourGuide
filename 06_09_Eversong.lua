
local questsequence =
[[A Roadside Ambush |N|Down the path|
T Delivery To The North Sanctum
A Malfunction at the West Sanctum
T Malfunction at the West Sanctum |N|To the west, duh|
A Arcane Instability
C Arcane Instability
C Darnassian Intrusions
T Arcane Instability
T Darnassian Intrusions
A Fish Heads, Fish Heads... |N|Follow the path west|
C Fish Heads, Fish Heads...
T Fish Heads, Fish Heads...
A The Ring of Mmmrrrggglll
I Captain Kelisendra's Lost Rutters |I|21776|
A Grimscale Pirates!
A Lost Armaments
R Fairbreeze Village@run@
A Pelt Collection
A The Wayward Apprentice
A Situation At Sunsail Anchorage
h Fairbreeze Village@hearth@
T Roadside Ambush |N|To the north|
A Soaked Pages
C Soaked Pages |N|The Grimoire is in the water just south west of that bridge|
T Soaked Pages
A Taking The Fall
R Falconwing Square
I Incriminating Documents |I|20765|
A The Dwarven Spy
t Train (Level 6) |N|Train level 8 if you can|
C The Dwarven Spy |N|Near North Sanctum|
T The Dwarven Spy |N|Falconwing Square|
t Train (Level 8)
A The Dead Scar |N|To the East|
C The Dead Scar |N|Slightly to the South|
T The Dead Scar
T Taking The Fall |N|Stillwhisper Pond to the East|
A Swift Discipline
R Farstrider Retreat |N|To the Southeast|
A Amani Encroachment
A The Spearcrafter's Hammer
A The Magister's Apprentice
T The Wayward Apprentice |N|To the Southwest|
A Corrupted Soil
C Corrupted Soil
T Corrupted Soil
A Unexpected Results
C Unexpected Results
T Unexpected Results
A Research Notes
G Until level 9]]


TourGuide.itemstartedquests = {}
TourGuide:ParseObjectives(questsequence)
