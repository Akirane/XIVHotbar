# xivhotbar - [WIP]
This version is further work on SirEdeonX's original addon, you can check his work from here: https://github.com/SirEdeonX/FFXIAddons/tree/master/xivhotbar. The test branch contains new experimental features that might end up in the master branch.

[!XIVHotbar](/images/demo/demo2.png)
##### Latest Changes:
```
 1/1/20
	- [test_branch] Added support for changing actions based on which avatar you are summoning. Take a look at data/Akirane/SMN.lua if you need an example on how to use it.
 30/12/20
	- [test_branch] Reimplemented support for multiple characters.
 30/11/19
	- Now most file operations use .lua instead of .xml files, making loading much faster.
	- Increased the number of hotbars showed simultaneously from 3 to 4.
	- Added numbers to distinguish which hotbars are currently in use.
	- Disabled the auto switching of hotbars in battle, press "\" to toggle between hotbars.
	- Removed MP and TP cost.

 09/05/17
    - Added various addon commands
 08/05/17
    - Hotbar files are now inside a server directory so characte:>rs with same name don't override each other
    - fixed chat input triggering hotbar
    - removed key to hide bar and added setting ToggleBattleMode
    - fixed job change and battle notice bugs. 
    - added PSDs for custom icons to repository
 07/05/17
    - released WIP version
 ```

##### Limitations:
1. This addon binds keys, these keybinds will remain even after the addon is unloaded. Therefore take care with what you bind. 
2. Due to how all SP share the same recast timer, it's currently not possible to show an icon for SP-abilities and they will show up as blank icons instead. The macros work however.

##### Done:

1. Add key mapping

