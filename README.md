# XIVHotbar - [Version 0.5]
This version is further work on SirEdeonX's original addon, you can check his work from here: https://github.com/SirEdeonX/FFXIAddons/tree/master/xivhotbar. 

![XIVHotbar](/images/demo/hover.gif)

## Note about 17/09/2020 update

- The following issues has been resolved:
	1. Hiding unused icons would print errors indefinitely.
	2. Light Arts/Dark Arts stance changing would not load actions.

- The weapon changing feature has been updated to include all weapon types. If you want to give this feature a try, change the value of EnableWeaponSwitching from false to true in the settings.xml file. The addon will wait for the inventory to be loaded, then it will load in the appropriate weapon type actions. Look at RUN.lua or RDM.lua in data/Akirane/ folder for examples. The keys are following (note they are case sensitive):

|              |         |              |
|--------------|---------|--------------|
| Hand-to-hand | Dagger  | Sword        |
| Great Sword  | Axe     | Great Axe    |
| Scythe       | Polearm | Scythe       |
| Polearm      | Katana  | Great Katana |
| Club         | Staff   | Bow          |
| Marksmanship |         |              |


## Note about 15/09/2020 update

- It's now possible to get the description from hovering over an icon. This option can be disabled by checking the ShowDescription option in settings.xml.

## How this version differentiates

- You can now move the hotbars around by typing in `//htb move`, the movement has a "snapping" feature, meaning it's easier to align the rows.

![XIVHotbar](/images/demo/movement1.gif)

- It's now possible to move/delete icons by dragging the icons.

![XIVHotbar](/images/demo/move_icons.gif)

- The number of rows is customizable. Currently I support up to 6 hotbars.  
- Job files now use `.lua` instead of `.xml` files. The main difference is everything loads much faster now. This means there's no ingame support for inserting new actions.
- MP and TP costs have been removed, spells/weaponskills becomes grayed out when you are unable to use them.
- It's now possible to bind any key! You can bind E for Dia II or CTRL+D for Cure IV if you so desire. The keys the application binds during loading gets unbound when you unload the application.
- The addon now uses ingame scaling, meaning if you use 1920x1080 for the game, but 1280x720 for the menus, the addon will no longer appear outside the screen boundary.
- The icons are clickable with your mouse now. By clicking on "1" or "2" you can change between battle and field environments.
- If you receive sleep/stun/amnesia/silence/etc, the actions will be disabled.


## Note about 23/08/2020 update

Keybinds have been moved to `data/keybinds.lua`. Make a backup of your old `keyboard_mapper.lua` file, then copy the table keyboard.hotbar_rows and paste its contents into the table in `keybinds.lua`

## Customization


Not every setting in **settings.xml** has been re-tested, there's a lot of things that is different now. The following has been tested out:

You can change the following from the settings.xml file:

1. Number of rows and columns. Modify the section **Hotbar/rows** and **Hotbar/columns** for this. For now I recommend leaving the columns on 12.

![Less Columns and Rows](/images/demo/demo_columns.PNG)

2. It's possible to change a row to be vertical or horizontal, if you want a specific hotbar to be vertical set `Vertical` to true whic you can find under the `hotbar` section in the settings.xml file. Below is showing the fifth row as an example.

![Less Columns and Rows](/images/demo/horizontal.PNG)
![Less Columns and Rows](/images/demo/vertical.PNG)

4. It's now possible to hide the inventory count and which hotbar environment you are currently in. Modify **Hotbar/HideBattleNotice** and **Hotbar/HideInventoryCount** for this.

![No extra labels](/images/demo/no_extra_labels.PNG)

5. The slot icons are now scalable. Check the *Hotbar/SlotIconScale* option.
6. It's now possible to change the textsize. Check the *Texts/Size* option.

![UI Scaling](/images/demo/ui_scaling.png)

7. It's now possible to tell this addon to change out weapon skill actions on the fly. Currently only works for club/dagger/sword. Look at the file `data/Akirane/RDM.lua`, at line 113 you have `xivhotbar_keybinds_job['Sword']` and at line 125 you have `xivhotbar_keybinds_job['Dagger']`. The addon can now switch between these two action tables after it has registered you have changed weapon type. Until I have finished this implementation, it will remain disabled for now. You can turn it on by changing the value **Hotbar/EnableWeaponSwitching** from false to true.

8. This addon recognizes the abilities **light arts** and **dark arts**, when you activate one of them and you have a table called `xivhotbar_keybinds_job['Light Arts']` you can update the hotbars with new actions. Look at `data/Akirane/WHM.lua` for example.

## Known issues

If the spells are spelled incorrectly, the ui.lua file will spam an error in the console. If you get this error, check if the spells in your .lua are spelled out correctly. For spells with the character `'` in them you need to add a backslash to escape the character like this: `\'`.

Slots with no actions show feedback if you click on them.

## What's next

- Reimplementating the add/move/remove action feature, but this time for lua files instead. At the moment the player.lua file has a function called `debug(args)` this function is a prototype of the reimplementation, but is very limited right now. If you want to play around with it you can do so by changing the local variable `debug` from false to true. 

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

## Upgrading from older version

Make a backup of your previous job-files located under `data/<character>`.

##### Latest Changes:
```
 22/08/2020
 	- Fixed a bug with the show() function for ui.
 20/08/2020
 	- It's now possible to move the hotbars by using the command `//htb move`
 10/08/2020
 	- Old .xml-files has been removed.
 	- Added further customization.
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
1. Due to how all SP share the same recast timer, it's currently not possible to show an icon for SP-abilities automatically, I recommend referencing to an image like this:

### Adding an image to SP-abilities

1. Copy the matching icon from `<xivhotbar-location>/images/icons/abilities` then paste it to `<xivhotbar-location>/images/icons/custom` remember to rename it to something else.
2. I want to map **Stymie** to the hotbar, therefore I renamed the image to "Stymie.png".
3. Each action accepts 5 or 6 items, the difference with the ladder is it tells the addon to use a custom .png image.

```
  {'battle 5 0', 'ja',  'Stymie', 'me', 'Stym.', 'Stymie'},
```

If you have done everything correctly, you'll end up with the following:

![Stymie](/images/demo/demo2.png)



## Done:

1. Add key mapping
