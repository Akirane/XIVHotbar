# xivhotbar - [WIP]
This version is further work on SirEdeonX's original addon, you can check his work from here: https://github.com/SirEdeonX/FFXIAddons/tree/master/xivhotbar. 

![XIVHotbar](/images/demo/demo1.png)

## Dependencies

- Shortcuts addon (Can be downloaded from the Windower launcher).

## Getting started

Create a folder with following structure inside *data* folder:

```
	<name-of-character>/<job>.lua
```

### Example of a basic `RDM.lua` file:

```lua

	-- Main job
	xivhotbar_keybinds_job['Base'] = {
	  {'battle 1 1', 'ma', 'Cure IV', 'stal', ' '},
	}
	
	-- Sub job
	xivhotbar_keybinds_job['SCH'] = {
	  {'b 3 1', 'ja', 'Light Arts', 'me', 'L.A.'},
	}
	
	return xivhotbar_keybinds_job
```

When you've saved the changes you've made, proceed with reloading using `//htb reload` or `//lua reload xivhotbar`. More in-depth examples are provided, `check data/Akirane` and `data/Waruharu`.

### Breakdown of each value in an action 
Let's say you have the following action:

```lua 
	{'b 1 1', 'ja', 'Stymie', 'me', 'Sty.', 'Stymie-image'}
```

| Column | Value        | Description                                                                                     |
|--------|--------------|-------------------------------------------------------------------------------------------------|
| 1      | b 1 1        | First row, first column in battle field.                                                        |
| 2      | ja           | Action Type OR custom command.                                                                  |
| 3      | Stymie       | Name of the spell/ability/command                                                               |
| 4      | me           | Target, this field can be empty                                                                 |
| 5      | Sty.         | Text which will appear on screen                                                                |
| 6      | Stymie-image | This field is optional, if the field is not nil it will use an image from images/custom folder. |

## Commands

- `//htb reload`: After you have made changes to the job-file, use this function to apply the new changes.
- `\`: Change between hotbar 1 and 2.

##### How this version differentiates

- Job files now use `.lua` instead of `.xml` files. The main difference is everything loads much faster now. This means there's no ingame support for inserting new actions.
- MP and TP costs have been removed, spells/weaponskills becomes grayed out when you are unable to use them.
- It's now possible to bind any key! You can bind E for Dia II or CTRL+D for Cure IV if you so desire.
- The addon now uses ingame scaling, meaning if you use 1920x1080 for the game, but 1280x720 for the menus, the addon will no longer appear outside the screen boundary.

##### What is currently broken

- The settngs.xml file will most likely not work as intended, edit with caution. 

##### Latest Changes:
```
 08/06/2020
 	- Fixed OffsetX and OffsetY in settings.xml, now they should reposition the hotbar properly.
 07/06/2020
 	- Added clickable icons and first version of hovering.
 05/06/2020
 	- Added a brief explanation on getting started.
 	- Removed old libraries related to .xml-files.
	- keyboard_mapper.lua has received an overhaul which makes it easier to work with keybinds now. Instead of '!a' you type in 'ALT + A' instead. 
	- An inventory counter has been implemented.
	- The number of hotbars has been increased to 5. I would like to implement a way to toggle as many hotbars as you like eventually.
	- The hotbar now is now hidden during conversations with NPC or zoning.
	- player.lua has been simplified.
	- The functions `windower.ffxi.get_spell_recasts()` and `windower.ffxi.get_ability_recasts()` will now only be called once per prerender update.
 2/1/20 
	- Corrected some minor spelling errors, will eventually push a new update based on feedback received. 
 1/1/20
	- Added support for changing actions based on which avatar you are summoning. Take a look at data/Akirane/SMN.lua if you need an example on how to use it.
 30/11/19
	- Now most file operations use .lua instead of .xml files, making loading much faster.
	- Increased the number of hotbars showed simultaneously from 3 to 4.
	- Added numbers to distinguish which hotbars are currently in use.
	- Disabled the auto switching of hotbars in battle, press "\" to toggle between them instead.
	- Removed MP and TP cost as they were inaccurate.
	- Removed progression bar on abilities/spells because of changing between hotbars caused them to start over with full boxes.

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

## Currently supported addons

- GearSwap
- Send

## How to use:

- keyboard_mapper.lua have a table called keyboard.hotbar_table, there you can bind keys.

## Limitations:
1. This addon binds keys, these keybinds will remain even after the addon is unloaded. Therefore take care with what you bind. 
2. Due to how all SP share the same recast timer, it's currently not possible to show an icon for SP-abilities automatically, I recommend referencing to an image like this:

### Adding an image to SP-abilities

1. Copy the matching icon from `<xivhotbar-location>/images/icons/abilities` then paste it to `<xivhotbar-location>/images/icons/custom` remember to rename it to something else.
2. I want to map **Stymie** to the hotbar, therefore I renamed the image to "Stymie.png".
3. Each action accepts 5 or 6 items, the difference with the ladder is it tells the addon to use a custom .png image.

```
  {'battle 5 0', 'ja',  'Stymie', 'me', 'Stym.', 'Stymie'},
```

If you have done everything correctly, you'll end up with the following:

![Stymie](/images/demo/demo2.PNG)



## Done:

1. Add key mapping
