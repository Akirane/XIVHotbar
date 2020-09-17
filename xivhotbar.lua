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

--[[
-- Big thanks to:
-- - Akaden & Rubenator: For the inspiration to the moving icons/hotbars part
-- - Maverickdfz:        Inspiration to the mouse actions
--]]

_addon.name = 'XIVHotbar'
_addon.author = 'Edeon, Akirane'
_addon.version = '0.5'
_addon.language = 'english'
_addon.commands = {'xivhotbar', 'htb', 'execute'}

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
require('luau')

-- User settings --
local defaults = require('defaults')
local settings = config.load(defaults)
config.save(settings)

-- Load theme options according to settings --
local theme = require('theme')
local theme_options = theme.apply(settings)


-- Addon Dependencies --
local keyboard = require('lib/keyboard_mapper')
local box = require('lib/move_box')
local player = require('lib/player')
local ui = require('lib/ui')
local xiv
local current_zone = 0
local state = {
	ready = false,
	demo = false,
	inventory_ready = false,
	inventory_loading = false
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

	local inventory = windower.ffxi.get_items()
	local equipment = inventory['equipment']
	if (theme_options.enable_weapon_switching == true) then
		weapon_id = windower.ffxi.get_items(equipment['main_bag'], equipment['main']).id
		skill_type = resources.items[weapon_id].skill
		player:load_weaponskill_actions(skill_type)
	end
	current_mp = windower_player.vitals.mp
	current_tp = windower_player.vitals.tp
	ui:update_mp(current_mp)
	ui:update_tp(current_tp)
    player:initialize(windower_player, server, theme_options)
    player:load_hotbar()
    keyboard:bind_keys(theme_options.rows, theme_options.columns)
    ui:load_player_hotbar(player:get_hotbar_info())
    ui.hotbar.ready = true
    ui.hotbar.initialized = true
	state.ready = true
	print('[20/08/2020] XIVHOTBAR: Type "//htb help" for more info')
	print('[23/08/2020] XIVHOTBAR: Keybinds have been moved to data/keybinds.lua.')
	print('[15/09/2020] XIVHOTBAR: Description for icons has been added.')
end


-- trigger hotbar action --
function trigger_action(slot)
    player:execute_action(slot)
    ui:trigger_feedback(player:get_active_hotbar(), slot)
end


-- toggle between field and battle hotbars --
function toggle_environment()
    player:toggle_environment()

    ui:load_player_hotbar(player:get_hotbar_info())
end


-- set battle environment --
function set_battle_environment(in_battle)
    player:set_battle_environment(in_battle)
    ui:load_player_hotbar(player:get_hotbar_info())
end


-- reload hotbar --
function reload_hotbar()
    player:load_hotbar()
    ui:load_player_hotbar(player:get_hotbar_info())
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
    player:insert_action(args)
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


-----------------
-- Bind Events --
-----------------

-- ON LOGOUT --
windower.register_event('logout', 'unload', function()
    ui:hide()
	keyboard:unbind_keys(theme_options.rows, theme_options.columns)
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

     if command == 'reload' then 
         reload_hotbar() 
	 elseif command == 'set' then
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
            ui:load_player_hotbar(player:get_hotbar_info())
		end
        windower.chat.input('/ma '..args[1]..' <me>')
    elseif command == 'execute' then
        change_active_hotbar(tonumber(args[1]))
        if tonumber(args[2]) <= theme_options.columns then 
			trigger_action(tonumber(args[2]))
        end
    elseif command == 'reload' then
        flush_old_keybinds()
        bind_keys()
        player:load_hotbar()
	elseif command == 'add' then
		player:insert_action(args)
	elseif command == 'move' then
		state.demo = not state.demo
		if state.demo then
			log("Layout mode enabled!") 
			log("Click, then drag an action onto another slot to change its location.")
			log("Click between the rows, then drag to move the hotbars.")
			log("To save the changes, type '//htb move' then hit enter.")
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


local current_hotbar = -1
local current_action = -1

local function mouse_hotbars(type, x, y, delta, blocked)

	return_value = false

	if not ui.hotbar.hide_hotbars then
		if type == 1 then -- Mouse left click
			local hotbar, action = ui:hovered(x, y)
			if(action ~= nil) then
				current_hotbar = hotbar
				current_action = action
				return_value = true
			else
				return_value = false
			end
		elseif type == 2 then -- Mouse left release
			if(current_action ~= -1) then
				local hotbar, action = ui:hovered(x, y)
				if(action ~= nil) then
					if (action == 100) then
						toggle_environment()
					elseif(hotbar == current_hotbar and action == current_action) then
						player:change_active_hotbar(hotbar)
						trigger_action(action)
					end
				end
				current_hotbar = -1
				current_action = -1
				return_value = true
			else
				return_value = false
			end
		elseif type == 0 then -- Mouse move
			local hotbar, action = ui:hovered(x, y)
			if(action ~= nil and hotbar ~= nil) then
				ui:light_up_action(x, y, hotbar, action, player:get_hotbar_info())
				return_value = true
			else
				ui:hide_hover()
				return_value = false
			end
		end
	end

	return return_value
end

-- Mouse Events
windower.register_event('mouse', function(type, x, y, delta, blocked)

	return_value = nil
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
		if (moved_row_info.swapped_slots.active == true) then
			player:swap_actions(moved_row_info.swapped_slots)
			ui:swap_icons(moved_row_info.swapped_slots)
			moved_row_info.swapped_slots.active = false
            ui:load_player_hotbar(player:get_hotbar_info())
		elseif (moved_row_info.row_active == true) then
			ui:move_icons(moved_row_info)
		elseif (moved_row_info.removed_slot.active == true) then
			player:remove_action(moved_row_info.removed_slot)
			moved_row_info.removed_slot.active = false
            ui:load_player_hotbar(player:get_hotbar_info())
		end
        ui:check_recasts(player:get_hotbar_info())
		--ui:check_hover()
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
        ui:show(player:get_hotbar_info())
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
		coroutine.sleep(2)
    end
end)

function check_action_used(act)
	if state.ready == true then
		if (act.param == 211 or act.param == 212) then 
			if (act.actor_id == player.id and act.category == 0x06) then
				player:load_job_ability_actions(act.param)
				ui:load_player_hotbar(player:get_hotbar_info())
			end
		end
	end
end


-- ON ACTION USED --
windower.register_event('action', check_action_used)

function get_weapon_type(byte_one, byte_two)
	if (theme_options.enable_weapon_switching == true) then
		if (state.inventory_loading == false) then
			log("Loading weapons...")
			state.inventory_loading = true
		end
		if (windower.ffxi.get_items(byte_one, byte_two).id ~= 0) then
			skill_type = resources.items[windower.ffxi.get_items(byte_one, byte_two).id].skill
			if(skill_type  ~= player:get_current_weapontype()) then
				player:load_weaponskill_actions(skill_type)
				reload_hotbar()
			end
			if (state.inventory_ready == false) then
				state.inventory_ready = true
				log("Loading complete!")
			end
		else
			coroutine.sleep(7)
			get_weapon_type(byte_one, byte_two)
		end
	end
end

-- ON ZONE  --
windower.register_event('incoming chunk', function(id, data)
	if state.ready == true then
		if (id == 0x00A) then current_zone = packets.parse('incoming', data)['Zone']
			ui.hotbar.hide_hotbars = false
			ui:show(player:get_hotbar_info())
		elseif (id == 0x00B) then
			ui.hotbar.hide_hotbars = true
			ui:hide()
		elseif id == 0x50 and data:byte(6) == 0 then
			get_weapon_type(data:byte(7), data:byte(5))
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
    player:update_job(resources.jobs[main_job].ens, resources.jobs[sub_job].ens)
    reload_hotbar()
end)
