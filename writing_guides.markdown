Writing TourGuide data files is a fairly simple process.  This page will break down the options available to the author to make it even easier.

Files to edit
-------------

The files that contain TourGuide data are saved under either Alliance or Horde within the TourGuide addon folder.
You can edit one of the existing files and simply save over what is there (though backing up the original file is recommended).

If you create a new file, save it in the appropriate folder and add the name of your file to TourGuide.toc (in the main folder).
This is the "Table of Contents" that WoW uses to load addon files on startup.
Please note that you must include the name of the subfolder as well as the full file name.

File format
-----------

TourGuide data files are fairly simple.  Each file should cover one logical zone/level block of leveling.
Note that the user may travel between more than one zone in a guide, if the travel is not a relocation to a new quest hub.
The file simply registers a guide with the core addon by passing 4 things...

 | |
-|-|
Title | A string describing the zone and level range
Next Guide | An optional string, the next guide to load when this guide is completed
Faction | _Required_  Alliance or Horde, of course.  Guides that aren't for the player's faction are dropped to save memory
Data function | A function that returns a string block containing the actual guide data.  Note that blank lines are allowed to make this more readable, just make sure those lines don't contain any stray whitespace (spaces, tabs, etc)

### Example

    TourGuide:RegisterGuide("Tanaris (47-48)", "Hinterlands (48)", "Alliance", function()
    return [[
    F Gadgetzan
    A The Thirsty Goblin |QID|2605|
    h Gadgetzan
    A The Dunemaul Compound |QID|5863|
    A Thistleshrub Valley |QID|3362|
    ]] end)

Data format
-----------

A single objective in a guide will look something like this:

    A Quest Name |N|A note with coords (12,34)| |QID|1234|

 | |
-|-|-
A | The objective type.  Accept, Complete, Turnin, Buy, etc...
Quest Name | The objective title.  This is displayed to the user and in many cases, used for auto-detection of completion.
&#124;N&#124;...&#124; | A note tag, there are a number of different tags.  There are all *optional*

### Quest chains

There are a number of quests that have the same name due to quest chains.  `|QID|...|` tags help solve this problem, but you should still let the user know where in the chain they are:

    A Panther Mastery (Part 1) |QID|190|

If the user starts a guide when they're already in the middle of a chain, they will have to manually check the quests in the chain they've already finished... just like they must do with the normal quests they've finished.

Objective types
---------------

 | | |
-|-|-|
A | Accept quest | Tells the user to accept a quest.  Displays a "!" icon.  Autocompletes when the objective name (minus "(Part 1)") is found in the quest log.
C | Complete | Complete a quest's objectives.  Kill something, loot something, whatever.  Note that some quests do not need this step, mainly delivery-type quests.  Auto-completes when the title is found in the quest log and is marked "Complete" there.
T | Turn-in | Turn in the quest.  Like A and C, uses the tile to complete when the quest is turned in.
R<br>F<br>b<br>H | Run<br>Fly<br>Boat<br>Hearth | Run/fly/boat/hearth to a destination.  Only difference is the icon shown.  Completes on (sub-)zone change when the title matches the new zone or subzone name.  Run objectives should only be used if the player is relocating, not for "run back to town and turn in quests".  For quest turnins just note where to go in the tooltip: `|N|Back at Refugee Point|` <br> Note that guides should generally *start* with a travel objective, and not end with them.  The player may load any guide they want and the first thing you want them to do is travel to the quest hub.  There's no reason to send them to the next area at the very end of a guide, instead let the next guide send the player where he needs to be.
B | Buy | Buy an item.  If a 'loot' tag is provided, completes when the loot is received, otherwise completes when an item that matches the title is received.  For title match use the format "[Item Name]"
U | Use | Use an item in your inventory, like a potion that allows you to see the quest mob.  Completes when you use the item.  Requires a `|U|...|` tag to function.
h | Set hearth | Set your hearth to a new location.  Auto-completes when it detects the text "&lt;title&gt; is now your home."
f | Get&nbsp;flight&nbsp;point | Remind the user to grab the flight point.  Completes on the popup text "Discovered flight point".  These should only be used if the flight point is out of the way and might not be seen on the minimap tracking.
N | Note | Give the user a general note.  Note objectives can auto-complete with a loot tag or quest-objective tag pair, otherwise no auto-completion.  ***Do not rely heavily on these, they should only be used when no other type works.***
K | Kill | Kill a specific mob (usually many times).  Can auto-complete with a loot tag or quest-objective tag pair

Tags
----

Tags are appended onto an objective line.  They are optional, and any number can be used on one line.  Order does not matter, as long as they come after the title.

 | | |
-|-|-|
&#124;N&#124;...&#124; | Note | The primary tag.  This text is displayed in the tooltip and in the objective frame.  It is also parsed for coords in the format "(12,56)" or "(12.34, 56.78)", and these are mapped with [TomTom](http://www.wowinterface.com/downloads/info7032-TomTom.html) if available.
&#124;QID&#124;1234&#124; | Quest ID | **Every** ACCEPT, COMPLETE and TURNIN objective must have one of these.  You can find these IDs easily by looking at the URL for the quest on Wowhead.
&#124;O&#124; | Optional | Objective is not shown if the quest is not in the user's log.  For ACCEPT objectives, if a loot or item tag are also provided the objective is not displayed if the player does not have the items needed.
&#124;L&#124;1234&#124;  &#124;L&#124;1234 2&#124; | Loot | Objective auto-completes or is shown (if optional) when the user has the items.  Takes an ItemID and optional quantity.  If used with `|O|` on an ACCEPT objective, the objective will be skipped if the user does not have the item (and quantity) needed.
&#124;U&#124;1234&#124; | Use | An item to be used.  Gives the user a button to click.  Useful for quests where you must use an item on a mob, equip something, drink something, etc.  Should not be used if the player must have an item to be able to interact with a node, only if the player is FORCED to open their bags and use the item.  If used along with `|O|` on an ACCEPT objective, the objective will only appear if the user has the item to use.
&#124;PRE&#124;Quest Name&#124; | Prerequsite | Used with the optional tag to only show a quest if another quest has been completed in the same guide.  Note that the prerequisite quest must be optional as well, normal quests will appear to be complete if the user drops the quest and manually checks it off of the list.
&#124;C&#124;Priest, ...&#124; | Class | Only displays the objective if the player is of one of the classes listed herein.  Useful for class-specific quests.  Accepts multiple classes, and uses the localized name.
&#124;R&#124;Night Elf, ...&#124; | Race | Only displayed if the player's race matches.  Like `|C|`, multiple races are supported per objective, and it takes a localized value.
&#124;Z&#124;Darnassus&#124; | Zone | Overrides the mapping zone for the objective.  If not defined the objective's waypoints will use the guide title for the zone.  If the title isn't a valid zone name, the player's current zone is used.  These should not be used heavily, if the player is changing locations to another zone and doing more than turnins, accepts and maybe one or two completes, a new guide should be started.  Remember, relocation to a new quest hub usually means you should start a new guide!
&#124;NODEBUG&#124; | No debug | Supresses debug warnings for an objective.  Use for quests that don't follow correct title case, for example [A Little Help From My Friends](http://www.wowhead.com/?quest=4491)
&#124;Q&#124;Quest&nbsp;Name&#124;<br> &#124;QO&#124;Some&nbsp;Mob&nbsp;slain:&nbsp;10/10&#124; | Sub-objective | Completes when a sub-objective of the quest matches the QO tag.  *Both values must be specified.*  Works with Note and Kill objectives.  Like quest titles, this is case-sensitive and must match the quest log text EXACTLY.
&#124;T&#124; | Town | 	Signifies that an objective takes place in a "town".  Generally a "town" has a flight point and an inn, but that's not always the case (WPL for example).  Usually used for accept/turnin blocks.  No functional effect beyond changing the objective list's background color to provide a visual queue to the player.

Guide design guidelines
-----------------------

To help keep the guides consistent with each other, I ask that you follow these basic rules when creating guides.
Note that some of the guides I've written (mainly the earliers ones) don't follow these rules.
I will change them when I get a chance, but it's not my first priority right now.

### Use decent English

***This is the most important rule of all.***  I'm not asking for Ph.D. thesis quality here.  Write your notes out in good, plain, simple English.   Like on this page, use correct punctuation and capitalization.   Break apart run-on sentences.   Write like you're writing a newspaper article, not a text message from a cell phone.   If English isn't your native language that's totally acceptable, if basic typing is beyond you however...

### Guide the player, don't hold their hand

This is the second most important rule!   The focus of this addon is to help guide the user through fast leveling, it is not to hold their hand and play the game for them.   It should be assumed that the player understands the basic mechanics of the game.   They can find quests on their own, repair their armor, sell their junk, restock their water... you don't have to tell them to wipe their own ass.   It's okay to give the player a little nudge, but don't take it to the extreme of telling the user where every NPC's exact location, when to buy water, when to train, when to grab a flight point that they encounter as they're collecting quests...

### Don't give the user the "runaround"

If the user is heading to a new area where they will perform many objectives (say, heading to a new quest hub), give them a single run/fly objective.   For example, you could give `F Ironforge |N|Fly to Theramore, boat to Menethil, then fly up to IF|` instead of giving them 3 different travel objectives in a row.   If the player is only going to a location to do one thing, simply note the location (with coords if need be) in the objective's notes, this way the player won't get a useless travel objective for something they already turned in.

The same principle applies to returning to town for quest turnins.  Only give a travel objective when moving to a new hub, not every return trip to turn in.   The player may complete quests out of sequence and may not need to turn in at all... instead note the turnin location in the first quest in the block: `|N|Back at Blood Watch|`

### Don't infringe on Joana's or Kopp's copyrights

Now, this is a fun one here.  We *can* use these guides as a base source for the creation of our guides.  We ***cannot*** use the text of their guides directly.  That is infringement.  If you do not believe me, [read up on copyrights](http://www.copyright.gov/circs/circ31.html).   The quest sequence would be a "procedure for doing things", and thus is not copyrightable.  Simply put, we can use their quest sequence, but we can't use their notes.  So please take the time to write your own notes by hand, I really don't want to give anyone valid reason to question this addon and it's data.

### Play your guide!

This is a big one here folks.  Writing the basic guide is easy, using it isn't.  Play thru the guide once, notice what quests don't complete and fix them.  Rewrite comments to be more clear.  Give better coords.  Reorder the sequence for greater efficiency.

*Make sure the guide works as intended.*

### Give exact coords as often as possible

The purchased guides usually only provide integer coords (12,56).  TourGuide uses Cartographer or TomTom, both of which can handle much more exact coords (12.34, 56.78).  Use them every chance you get, integer coords can be off be a decent amount.

### Don't go overboard with coords

Coords are good, flooding the user with them is bad.  Coords should be used to get the user into a general area, or help them find an out of the way item... you don't have to give coords for every single NPC and node the user will interact with.  The user can use LightHeaded if they have issues finding the exact location of something.  Remember, we're here to help push the user in the right direction, not hold their hand thru 70 levels.

If you've properly tagged ACCEPT and TURNIN objectives with QuestIDs and the user has Lightheaded they can opt to automatically map NPCs.  Because of this, you should never need to give questgiver coords!

### Don't rely completely on coords

The user might not have TomTom or Carto (the fool)... make sure you give plain english descriptions and tag coords in as a "bonus".  Use subzone names and compass directions, they help a ton.  This also means not directly referring to coords.  For example:

    |N|Kill Gor'marok at (41.11, 57.31)|
    |N|At (47,66)|

    |N|Kill Gor'marok in a small cave at the Dunemaul Compound (41.11, 57.31)|
    |N|Head southeast to the Eastmoon Ruins (47,66)|

### Don't overuse note objectives

Note objectives usually don't auto-complete, they are meant to convey important info to a user before they do something.  Don't overuse these for trivial things, just use them when it's vital the user knows the information.  Push trivial things into the note tags where the user doesn't have to click to clear them.  Use of notes that auto-complete (for example, when an item has been looted) is acceptable, the point here is to minimize the times a user gets "stuck" and has to manually check off a note.

### Streamline multiple Complete objectives

This one should be obvious, it is the whole point of a guide after all, but I'm still going to say it.  Lets say you have 3 quests you're going to need to kill the same mobs for:

* Collect 14 Buzzard Asses
* Collect 4 High Quality Buzzard Tail Feathers
* Kill 20 Buzzards

When making a guide, you should list these in order such that the second and third quests are most likely complete before the first one is.  Another example of this would be a pair of quests, one that requires killing x mobs in an area, and the other collecting y items off the ground in the same area.  For these, list the item quest first.  The player doesn't want to kill 20 mobs to then discover he should have also been collecting items.  Whenever possible, give the most "direct" quest first, and let the other quests get completed in the process.  TourGuide will track all the quests automatically for the user, so providing the one that requires the most work on the user's part first will speed up their leveling.

### Empty lines are okey!

Use blank lines to break apart your guide code, it makes it easier to read.  Just remember these line cannot contain ANY chars, not even spaces or tabs.

