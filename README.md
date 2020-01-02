# xivhotbar - [WIP]
This version is further work on SirEdeonX's original addon, you can check his work from here: https://github.com/SirEdeonX/FFXIAddons/tree/master/xivhotbar. 

![XIVHotbar](/images/demo/demo1.png)

##### How this version differentiates

- Job files now use `.lua` instead of `.xml` files. The main difference is everything loads much faster now. This means there's no ingame support for inserting new actions.
- MP and TP costs have been removed, spells/weaponskills becomes grayed out when you are unable to use them.
- It's now possible to bind any key! You can bind E for Dia II or CTRL+D for Cure IV if you so desire.
- The addon now uses ingame scaling, meaning if you use 1920x1080 for the game, but 1280x720 for the menus, the addon will no longer appear outside the screen boundary.

##### What is currently broken

- The settngs.xml file will most likely not work anymore as intended. I'll fix this next.

##### Latest Changes:
```
 2/1/20 
	- Corrected some minor spelling errors, will eventually push a new update based on feedback received. 
 1/1/20
	- Added support for changing actions based on which avatar you are summoning. Take a look at data/Akirane/SMN.lua if you need an example on how to use it.
 30/11/19
	- Now most file operations use .lua instead of .xml files, making loading much faster.
	- Increased the number of hotbars showed simultaneously from 3 to 4.
	- Added numbers to distinguish which hotbars are currently in use.
	- Disabled the auto switching of hotbars in battle, press "\" to toggle between hotbars.
	- Removed MP and TP cost.

 09/05/17
    - Added various addon commands
 08/05/17
    - Hotbar files are now inside a server directory so characters with same name don't override each other
    - fixed chat input triggering hotbar
    - removed key to hide bar and added setting ToggleBattleMode
    - fixed job change and battle notice bugs. 
    - added PSDs for custom icons to repository
 07/05/17
    - released WIP version
 ```

##### Currently supported addons

- GearSwap
- Send

##### How to use:

- keyboard_mapper.lua have a table called keyboard.hotbar_table, there you can bind keys.

##### Limitations:
1. This addon binds keys, these keybinds will remain even after the addon is unloaded. Therefore take care with what you bind. 
2. Due to how all SP share the same recast timer, it's currently not possible to show an icon for SP-abilities.

##### Done:

1. Add key mapping

