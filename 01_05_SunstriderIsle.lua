
local TourGuide = TourGuide
local _, class = UnitClass("player")

local questsequence = class == "WARLOCK" and
[[A Reclaiming Sunstrider Isle
C Reclaiming Sunstrider Isle
T Reclaiming Sunstrider Isle
A Unfortunate Measures
A Warlock Training
T Warlock Training
A Windows to the Source
t Train (Level 2)
A Well Watcher Solanian
T Well Watcher Solanian
A The Shrine of Dath'Remar
A Solanian's Belongings |N|Don't forget to equip the bag he gives you|
A A Fistful of Slivers
A Thirst Unending
C Unfortunate Measures
T Unfortunate Measures
A Report to Lanthan Perilon
T Report to Lanthan Perilon
A Aggression
C Aggression
C The Shrine of Dath'Remar
C Thirst Unending
C A Fistful of Slivers
C Solanian's Belongings |N|South near a crystal, Southwest near a pond, West near treants|
T Thirst Unending
T A Fistful of Slivers
t Train (Level 4)
T The Shrine of Dath'Remar
T Solanian's Belongings
T Aggression
C Windows to the Source
A Felendren the Banished
C Felendren the Banished
T Windows to the Source
T Felendren the Banished
A Aiding the Outrunners
I Tainted Arcane Sliver |I|20483|
R Dawning Lane]]
	or
[[A Reclaiming Sunstrider Isle
C Reclaiming Sunstrider Isle
T Reclaiming Sunstrider Isle
A Unfortunate Measures
A YOUR CLASS QUEST
T YOUR CLASS QUEST
t Train (Level 2)
A Well Watcher Solanian
T Well Watcher Solanian
A The Shrine of Dath'Remar
A Solanian's Belongings |N|Don't forget to equip the bag he gives you|
A A Fistful of Slivers
A Thirst Unending
C Unfortunate Measures
T Unfortunate Measures
A Report to Lanthan Perilon
T Report to Lanthan Perilon
A Aggression
C Aggression
C The Shrine of Dath'Remar
C Thirst Unending
C A Fistful of Slivers
C Solanian's Belongings |N|South near a crystal, Southwest near a pond, West near treants|
T Thirst Unending
T A Fistful of Slivers
t Train (Level 4)
T The Shrine of Dath'Remar
T Solanian's Belongings
T Aggression
A Felendren the Banished
C Felendren the Banished |N|You should find an item while doing this quest which starts "Tainted Arcane Sliver"|
T Felendren the Banished
A Aiding the Outrunners
I Tainted Arcane Sliver |I|20483|
R Dawning Lane]]


TourGuide:ParseObjectives(questsequence)

