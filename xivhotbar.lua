--[[    BSD License Disclaimer
        Copyright © 2020, SirEdeonX, Akirane
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of ui.xivhotbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX OR Akirane BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'XIVHotbar'
_addon.author = 'Edeon, Akirane'
_addon.version = '0.3'
_addon.language = 'english'
_addon.commands = {'xivhotbar', 'htb', 'execute'}

---------------------------------
-- User defined macro placeholder
---------------------------------
--
-- Placeholder function for macros in the future.
-- Goal is to be able to define macros in job 
-- files instead of here.
function sch_skillchain()
	windower.chat.input('/party greetings no. 1')
	coroutine.sleep(1)
	windower.chat.input('/party greetings no. 2')
end
----------------------------------------
-- End of user defined macro placeholder
----------------------------------------

-- Libs --
config = require('config')
file = require('files')
texts = require('texts')
images = require('images')
tables = require('tables')
packets = require('packets')
resources = require('resources')

-- User settings --
local defaults = require('defaults')
local settings = config.load(defaults)
config.save(settings)
-- Load theme options according to settings --
local theme = require('theme')
local theme_options = theme.apply(settings)

-- Addon Dependencies --
local action_manager = require('action_manager')
local keyboard = require('keyboard_mapper')
local player = require('player')
local ui = require('ui')
local box = require('lib/move_box')
local xiv
local current_zone = 0
local state = {
	ready = false,
	demo = false,
}

-------
-- Main
-------


-- initialize addon --
function initialize()

    keyboard:parse_keybinds()
    ui:setup(theme_options)
	box:init(theme_options)
    local windower_player = windower.ffxi.get_player()
    local server = resources.servers[windower.ffxi.get_info().server].en

    if windower_player == nil then return end
	local inventory = windower.ffxi.get_items()
	local equipment = inventory['equipment']

	weapon_id = windower.ffxi.get_items(equipment['main_bag'], equipment['main']).id
	current_mp = windower_player.vitals.mp
	current_tp = windower_player.vitals.tp
	ui:update_mp(current_mp)
	ui:update_tp(current_tp)

	skill_type = resources.items[weapon_id].skill
	player:load_weaponskill_actions(skill_type)

    player:initialize(windower_player, server, theme_options)
    player:load_hotbar()
    bind_keys()
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
    ui.hotbar.ready = true
    ui.hotbar.initialized = true
	state.ready = true
	print('XIVHOTBAR: Type "//htb help" for more info')
end


-- bind keys --
function bind_keys()
    for hotbar_index = 1, theme_options.rows do 
        for skill_index = 1, theme_options.columns do
            if (keyboard.hotbar_rows[hotbar_index] ~= nil and keyboard.hotbar_rows[hotbar_index][skill_index] ~= nil) then 
    			windower.send_command('bind '..keyboard.hotbar_rows[hotbar_index][skill_index]..' input //htb execute '..hotbar_index..' '..skill_index)
            end
        end
    end
end


-- trigger hotbar action --
function trigger_action(slot)
    player:execute_action(slot)
    ui:trigger_feedback(player.hotbar_settings.active_hotbar, slot)
end


-- toggle between field and battle hotbars --
function toggle_environment()
    player:toggle_environment()

    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
end


-- set battle environment --
function set_battle_environment(in_battle)
    player:set_battle_environment(in_battle)
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
end


-- reload hotbar --
function reload_hotbar()
    player:load_hotbar()
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
end


-- change active hotbar --
function change_active_hotbar(new_hotbar)
    player:change_active_hotbar(new_hotbar)
end

--------------------
-- Addon Commands -- --
--------------------

-- command to set an action in a hotbar --
function set_action_command(args)
    if not args[5] then
        print('XIVHOTBAR: Invalid arguments: set <mode> <hotbar> <slot> <action_type> <action> <target (optional)> <alias (optional)> <icon (optional)>')
        return
    end

    local environment = args[1]:lower()
    local hotbar = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0
    local action_type = args[4]:lower()
    local action = args[5]
    local target = args[6] or nil
    local alias = args[7] or nil
    local icon = args[8] or nil

    if environment ~= 'battle' and environment ~= 'field' and environment ~= 'b' and environment ~= 'f' then
        print('XIVHOTBAR: Invalid mode. Available modes are "Battle" (b) and "Field" (f).')
        return
    end

    if hotbar < 1 or hotbar > ui.hotbar.rows then
        print('XIVHOTBAR: Invalid hotbar. Please use a number between 1 and 3.')
        return
    end

    if slot < 1 or slot > ui.hotbar.columns then
        print('XIVHOTBAR: Invalid slot. Please use a number between 1 and 10.')
        return
    end

    if target ~= nil then target = target:lower() end


    local new_action = action_manager:build(action_type, action, target, alias, icon)
    --player:add_action(new_action, environment, hotbar, slot)
    --player:save_hotbar()
    reload_hotbar()
end

-- command to delete an action from an hotbar --
function delete_action_command(args)
    if not args[3] then
        print('XIVHOTBAR: Invalid arguments: del <mode> <hotbar> <slot>')
        return
    end

    local environment = args[1]:lower()
    local hotbar = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0

    if environment ~= 'battle' and environment ~= 'field' and environment ~= 'b' and environment ~= 'f' then
        print('XIVHOTBAR: Invalid mode. Available modes are "Battle" (b) and "Field" (f).')
        return
    end

    if hotbar < 1 or hotbar > ui.hotbar.rows then
        print('XIVHOTBAR: Invalid hotbar. Please use a number between 1 and 3.')
        return
    end

    if slot < 1 or slot > ui.hotbar.columns then
        print('XIVHOTBAR: Invalid slot. Please use a number between 1 and 10.')
        return
    end

    player:remove_action(environment, hotbar, slot)
    player:save_hotbar()
    reload_hotbar()
end

function flush_old_keybinds()
    for i=1,ui.hotbar.rows,1 do
        for j=1,ui.hotbar.columns,1 do
            windower.send_command('htb delete f '..i..' '..j)
        end
    end
    for i=1,ui.hotbar.rows,1 do
        for j=1,ui.hotbar.columns,1 do
            windower.send_command('htb delete battle '..i..' '..j)
        end
    end
end

-- command to copy an action to another slot --
function copy_action_command(args, is_moving)
    local command = 'copy'
    if is_moving then command = 'move' end

    if not args[6] then
        print('XIVHOTBAR: Invalid arguments: ' .. command .. ' <mode> <hotbar> <slot> <to_mode> <to_hotbar> <to_slot>')
        return
    end

    local environment = args[1]:lower()
    local hotbar = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0
    local to_environment = args[4]:lower()
    local to_hotbar =  tonumber(args[5]) or 0
    local to_slot =  tonumber(args[6]) or 0

    if (environment ~= 'battle' and environment ~= 'field' and environment ~= 'b' and environment ~= 'f') or
            (to_environment ~= 'battle' and to_environment ~= 'field' and to_environment ~= 'b' and to_environment ~= 'f') then
        print('XIVHOTBAR: Invalid mode. Available modes are "Battle" (b) and "Field" (f).')
        return
    end

    if hotbar < 1 or hotbar > ui.hotbar.rows or to_hotbar < 1 or to_hotbar > ui.hotbar.rows then
        print('XIVHOTBAR: Invalid hotbar. Please use a number between 1 and 3.')
        return
    end

    if slot < 1 or slot > 10 or to_slot < 1 or to_slot > 10 then
        print('XIVHOTBAR: Invalid slot. Please use a number between 1 and 10.')
        return
    end

    player:copy_action(environment, hotbar, slot, to_environment, to_hotbar, to_slot, is_moving)
    player:save_hotbar()
    reload_hotbar()
end

-- command to update action alias --
function update_alias_command(args)
    if not args[4] then
        print('XIVHOTBAR: Invalid arguments: alias <mode> <hotbar> <slot> <alias>')
        return
    end

    local environment = args[1]:lower()
    local hotbar = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0
    local alias = args[4]

    if environment ~= 'battle' and environment ~= 'field' and environment ~= 'b' and environment ~= 'f' then
        print('XIVHOTBAR: Invalid mode. Available modes are "Battle" (b) and "Field" (f).')
        return
    end

    if hotbar < 1 or hotbar > ui.hotbar.rows then
        print('XIVHOTBAR: Invalid hotbar. Please use a number between 1 and '..tostring(ui.hotbar.rows))
        return
    end

    if slot < 1 or slot > 10 then
        print('XIVHOTBAR: Invalid slot. Please use a number between 1 and 10.')
        return
    end

    player:set_action_alias(environment, hotbar, slot, alias)
    player:save_hotbar()
    reload_hotbar()
end

-- command to update action icon --
function update_icon_command(args)
    if not args[4] then
        print('XIVHOTBAR: Invalid arguments: icon <mode> <hotbar> <slot> <icon>')
        return
    end

    local environment = args[1]:lower()
    local hotbar = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0
    local icon = args[4]

    if environment ~= 'battle' and environment ~= 'field' and environment ~= 'b' and environment ~= 'f' then
        print('XIVHOTBAR: Invalid mode. Available modes are "Battle" (b) and "Field" (f).')
        return
    end

    if hotbar < 1 or hotbar > ui.hotbar.rows then
        print('XIVHOTBAR: Invalid hotbar. Please use a number between 1 and 3.')
        return
    end

    if slot < 1 or slot > ui.hotbar.columns then
        print('XIVHOTBAR: Invalid slot. Please use a number between 1 and 10.')
        return
    end

    player:set_action_icon(environment, hotbar, slot, icon)
    player:save_hotbar()
    reload_hotbar()
end

-----------------
-- Bind Events --
-----------------

local function unbind_keys()
    for hotbar_index = 1, theme_options.rows do 
        for skill_index = 1, theme_options.columns do
            if (keyboard.hotbar_rows[hotbar_index] ~= nil and keyboard.hotbar_rows[hotbar_index][skill_index] ~= nil) then 
    			windower.send_command('unbind '..keyboard.hotbar_rows[hotbar_index][skill_index])
            end
        end
    end
end

-- ON LOGOUT --
windower.register_event('logout', 'unload', function()
    ui:hide()
	unbind_keys()
end)

local function save_hotbar(hotbar, index)
	if index <= theme_options.rows then
		local x, y = box:get_pos(index)
		hotbar.OffsetX = x
		hotbar.OffsetY = y
	end
end


local function print_help()
	log("Commands:")
	log("move: Enables moving the hotbars by dragging them, also writes the changes to settings.xml if used again.")
	log("reload: Reloads the hotbar, if you have made changes to the hotbar-file, this is faster for loading.")
	log("Dependencies:")
	log("shortcuts: Used for weapon skills.")
end

-- ON COMMAND --
windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'
    local args = {...}

    -- if command == 'reload' then --
    --     return reload_hotbar() --

    if command == 'set' then
        set_action_command(args)
	elseif command == 'help' then
		print_help()
    elseif command == 'mount' then
        local player_mount = windower.ffxi.get_player()
        for k=1,32 do 
            if player_mount.buffs[k] == 252 then
                windower.chat.input('/dismount')
                return
            end
        end
        if args[1] == nil then 
            windower.chat.input('/mount crab <me>')
        else
            windower.chat.input('/mount '..args[1]..' <me>')
        end
	elseif command == 'summon' then
		local avatar_id = player:determine_summoner_id(args[1])
		if (avatar_id == 0) then
			print("Error, couldn't find avatar '"..args[1].."'... Unable to load actions for it.")
		else
			player:load_job_ability_actions(avatar_id)
            ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
		end
        windower.chat.input('/ma '..args[1]..' <me>')
	elseif command == 'macro' then
		sch_skillchain()
    elseif command == 'execute' then
        change_active_hotbar(tonumber(args[1]))
        if tonumber(args[2]) <= theme_options.columns then 
			trigger_action(tonumber(args[2]))
        end
	elseif command == 'debug' then

		player:debug(args)
		reload_hotbar()
    elseif command == 'reload' then
        flush_old_keybinds()
        bind_keys()
        player:load_hotbar()
	elseif command == 'move' then
		state.demo = not state.demo
		if state.demo then
            print('XIVHOTBAR: Layout mode enabled')
			box:enable()
		else
			save_hotbar(settings.Hotbar.Offsets.First, 1)
			save_hotbar(settings.Hotbar.Offsets.Second, 2)
			save_hotbar(settings.Hotbar.Offsets.Third, 3)
			save_hotbar(settings.Hotbar.Offsets.Fourth, 4)
			save_hotbar(settings.Hotbar.Offsets.Fifth, 5)
			save_hotbar(settings.Hotbar.Offsets.Sixth, 6)

			config.save(settings)
            print('XIVHOTBAR: Layout mode disabled, writing new positions to settings.xml.')
			box:disable()
		end
    end
end)


-- ON KEY --
windower.register_event('keyboard', function(dik, flags, blocked)
    if ui.hotbar.ready == false or windower.ffxi.get_info().chat_open then
        return
    end

    if ui.hotbar.hide_hotbars then
        return
    end

    if dik == theme_options.controls_battle_mode and flags == true then
        toggle_environment()
    end
end)



local function mouse_hotbars(type, x, y, delta, blocked)
	if ui.hotbar.hide_hotbars then
		return false
	end

	if type == 1 then -- Mouse left click
		local hotbar, action = ui:hovered(x, y)
		if(action ~= 0) then
			current_hotbar = hotbar
			current_action = action
			return true
		end
	elseif type == 2 then -- Mouse left release
		if(current_action ~= -1) then
			local hotbar, action = ui:hovered(x, y)
			if(action ~= 0) then
				if (action == 100) then
					toggle_environment()
				elseif(hotbar == current_hotbar and action == current_action) then
					player.hotbar_settings.active_hotbar = hotbar
					trigger_action(action)
				end
			end
			current_hotbar = -1
			current_action = -1
			return true
		end
	elseif type == 0 then -- Mouse move
		local hotbar, action = ui:hovered(x, y)
		if(action ~= 0) then
			ui:light_up_action(hotbar, action)
		else
			ui:light_up_action(nil, nil)
		end
		--if(current_action ~= -1) then
		return false
	end
end

-- ON MOUSE
-- Credit for clicking on action: maverickdfz
-- https://github.com/maverickdfz/FFXIAddons/blob/master/xivhotbar/xivhotbar.lua
--
-- TODO: Fix "hover" effect 
windower.register_event('mouse', function(type, x, y, delta, blocked)

	return_value = false
	if state.ready == true and blocked == false then
		if state.demo == true then
			return_value = box:move_hotbars(type, x, y, delta, blocked)
		else
			return_value = mouse_hotbars(type, x, y, delta, blocked)
		end
	end

    return return_value
end)


-- ON PRERENDER --
windower.register_event('prerender',function()
    if ui.hotbar.ready == false then
        return
    end

    if ui.feedback.is_active then
        ui:show_feedback()
    end

    if ui.is_setup and ui.hotbar.hide_hotbars == false then
		moved_row_info = box:get_move_box_info()
		if (moved_row_info.is_active == true) then
			ui:move_icons(moved_row_info)
		end
        ui:check_recasts(player.hotbar, player.vitals, player.hotbar_settings.active_environment, distance)
		ui:check_hover()
    end
end)


-- ON MP CHANGE --
windower.register_event('mp change', function(new, old)
	ui:update_mp(new)
end)


-- OM TP CHANGE --
windower.register_event('tp change', function(new, old)
	ui:update_tp(new)
end)


-- ON STATUS CHANGE --
windower.register_event('status change', function(new_status_id)
    -- hide/show bar in cutscenes --
    if ui.hotbar.hide_hotbars == false and new_status_id == 4 then
        ui.hotbar.hide_hotbars = true
        ui:hide()
    elseif ui.hotbar.hide_hotbars and new_status_id ~= 4 then
        ui.hotbar.hide_hotbars = false
        ui:show(player.hotbar, player.hotbar_settings.active_environment)
    end
end)


-- ON LOGIN/LOAD --
windower.register_event('login', 'load', function()
    if windower.ffxi.get_player() ~= nil then
		defaults = require('defaults')
		settings = config.load(defaults)
		config.save(settings)
		-- Load theme options according to settings --
		theme = require('theme')
		theme_options = theme.apply(settings)
		local settings = config.load(defaults)
		config.save(settings)
        player.id = windower.ffxi.get_player().id
        initialize()
		--windower.send_command('htb debug battle 1 2 ws "Raging Rush" t')
    end
end)


-- ON ACTION USED --
windower.register_event('action', function(act)
	if state.ready == true then
		if (act.param == 211 or act.param == 212) then 
			if (act.actor_id == player.id and act.category == 0x06) then
				player:load_job_ability_actions(act.param)
				ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
			end
		end
	end
end)


-- ON ZONE  --
windower.register_event('incoming chunk', function(id, data)
	if state.ready == true then
		if (id == 0x00A) then current_zone = packets.parse('incoming', data)['Zone']
			player:update_zone(current_zone)
			ui.hotbar.hide_hotbars = false
			ui:show(player.hotbar, player.hotbar_settings.active_environment)
		elseif (id == 0x00B) then
			ui.hotbar.hide_hotbars = true
			ui:hide()
		-- data:byte(6) == 0 means "main" equipment slot 
		elseif id == 0x50 and data:byte(6) == 0 then
			if (theme_options.enable_weapon_switching == true) then
				skill_type = resources.items[windower.ffxi.get_items(data:byte(7), data:byte(5)).id].skill
				if(skill_type  ~= player:get_current_weapontype()) then
					player:load_weaponskill_actions(skill_type)
					reload_hotbar()
				end
			end
		end
	end
end)

windower.register_event('add item', 'remove item', function(id, bag, index, count)

	if state.ready == true then
		ui:update_inventory_count()
	end
end)


-- ON JOB CHANGE --
windower.register_event('job change',function(main_job, main_job_level, sub_job, sub_job_level)
    player:update_jobs(resources.jobs[main_job].ens, resources.jobs[sub_job].ens)
    reload_hotbar()
end)
