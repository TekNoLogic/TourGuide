**All bugs should be submitted to [GitHub](http://github.com/tekkub/TourGuide/issues).**

Please look over the list first to make sure your issue isn't listed.

If I post something that needs feedback from you, and you never reply, I will close the ticket out without a second thought!  Make sure you're using a valid email address with GitHub and that you have email notifications turned on.

Important info you should include
---------------------------------

* The version you are running (Please look it up in the TourGuide.toc file, don't just say "the latest")
* The version of related addons (LightHeaded, TomTom) if the bug may relate to them
* The guide (zone and level) you are using.  If you aren't using the included guides, you should report guide issues to the author.
* The exact title of the objective (usually quest name) and the type (accept, complete, turnin, run...)
* What you were doing when the bug occurred

Known conflicts
---------------

There are a number of "Quest Level" addons that append the quest's recommended level to the front of the text in the quest log and other places.
A good number of these addons do this by hooking GetQuestLogTitle and modifying it's return values. _*This is a very bad practice.*_
The addons listed below do this, they may break TG's auto-detection, and I do not intend to compensate for their bad code in TourGuide.
If you want quest levels that don't interfere I've written [Quel'evel](http://www.wowinterface.com/downloads/fileinfo.php?id=8631) as an alternative.

* QuestLevel by Elkano (and the many &quot;revived&quot; versions floating around)
* QuestLongList by Zevzabich
* QuestIOn *Can be disabled by turning off the quest level feature*
* Extended Quest Log 3

Submitting patches
------------------

I have had many problems with submitted patch files, they never seem to be in the correct format.  Please fork my repo and push changes directly to your fork.  See below for details.

Hot forking action!
-------------------

If you know how to use git, then I really shouldn't need to tell you how to get commits to me.
Simply fork [my repo on GitHub](http://github.com/tekkub/tourguide) and push to your new fork.
You don't even have to contact me, I'll just pull the changes in as I see them come in!

***Please read [How to edit TourGuide guides](http://github.com/tekkub/TourGuide/tree/docs/writing_guides.markdown) before you submit files!***
