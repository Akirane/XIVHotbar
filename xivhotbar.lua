--[[    BSD License Disclaimer
        Copyright © 2017, SirEdeonX
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
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Addon description
_addon.name = 'XIVHotbar'
_addon.author = 'Akirane, Edeon'
_addon.version = '0.1'
_addon.language = 'english'
_addon.commands = {'xivhotbar', 'htb', 'execute'}

-- Libs
config = require('config')
file = require('files')
texts = require('texts')
images = require('images')
tables = require('tables')
packets = require('packets')
resources = require('resources')
xml = require('libs/xml2')   -- TODO: REMOVE

-- User settings
local defaults = require('defaults')
local settings = config.load(defaults)
config.save(settings)

-- Load theme options according to settings
local theme = require('theme')
local theme_options = theme.apply(settings)

-- Addon Dependencies
local action_manager = require('action_manager')
local keyboard = require('keyboard_mapper')
local player = require('player')
local ui = require('ui')
local xiv

-----------------------------
-- Main
-----------------------------

-- initialize addon
function initialize()


    local windower_player = windower.ffxi.get_player()
    local server = resources.servers[windower.ffxi.get_info().server].en

    if windower_player == nil then return end

    player:initialize(windower_player, server, theme_options)
    player:load_hotbar()
    ui:setup(theme_options)
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
    ui.hotbar.ready = true
    ui.hotbar.initialized = true
    bind_keys()
end

-- Initialize with lua 
function initialize_lua()
    local windower_player = windower.ffxi.get_player()
    local server = resources.servers[windower.ffxi.get_info().server].en

    if windower_player == nil then return end

    player:initialize(windower_player, server, theme_options)
    player:load_hotbar()
    ui:setup(theme_options)
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
    ui.hotbar.ready = true
    ui.hotbar.initialized = true
    bind_keys()
end

-- bind keys
function bind_keys()
    for hotbar_index = 1, ui.hotbar.rows do --i, v in ipairs(keyboard.hotbar_table) do
        for skill_index = 1, ui.hotbar.columns do
            -- print('bind '..keyboard.hotbar_table[hotbar_index][skill_index]..' input //htb execute '..hotbar_index..' '..skill_index)
            windower.send_command('bind '..keyboard.hotbar_table[hotbar_index][skill_index]..' input //htb execute '..hotbar_index..' '..skill_index)
        end
    end
end


-- trigger hotbar action
function trigger_action(slot)
    player:execute_action(slot)
    ui:trigger_feedback(player.hotbar_settings.active_hotbar, slot)
end

-- toggle between field and battle hotbars
function toggle_environment()
    player:toggle_environment()

    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
end

-- set battle environment
function set_battle_environment(in_battle)
    player:set_battle_environment(in_battle)
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
end

-- reload hotbar
function reload_hotbar()
    player:load_hotbar()
    ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
end

-- change active hotbar
function change_active_hotbar(new_hotbar)
    player:change_active_hotbar(new_hotbar)
end

-----------------------------
-- Addon Commands
-----------------------------

-- command to set an action in a hotbar
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
    player:add_action(new_action, environment, hotbar, slot)
    player:save_hotbar()
    reload_hotbar()
end

-- command to delete an action from an hotbar
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

-- command to copy an action to another slot
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

-- command to update action alias
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

-- command to update action icon
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

-----------------------------
-- Bind Events
-----------------------------

-- -- ON LOGOUT
windower.register_event('logout', function()
    ui:hide()
end)

-- ON COMMAND
windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'
    local args = {...}

    -- if command == 'reload' then
    --     return reload_hotbar()

    if command == 'set' then
        set_action_command(args)
    elseif command == 'del' or command == 'delete' then
        delete_action_command(args)
    elseif command == 'cp' or command == 'copy' then
        copy_action_command(args, false)
    elseif command == 'mv' or command == 'move' then
        copy_action_command(args, true)
    elseif command == 'ic' or command == 'icon' then
        update_icon_command(args)
    elseif command == 'al' or command == 'alias' then
        update_alias_command(args)
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





    elseif command == 'execute' then
        -- print("Running execute command. "..tonumber(args[1]).." "..tonumber(args[2]))
        change_active_hotbar(tonumber(args[1]))
        if tonumber(args[2]) <= 10 then 
            if tonumber(args[2]) == 10 then 
                trigger_action(0)
            else
                trigger_action(tonumber(args[2]))
            end
        end
    elseif command == 'flush' then
        print("Flushing...")
        flush_old_keybinds()
    elseif command == 'reload' then
        flush_old_keybinds()
        bind_keys()
        player:load_hotbar()
    end
end)

-- ON KEY
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

-- ON PRERENDER
windower.register_event('prerender',function()
    if ui.hotbar.ready == false then
        return
    end

    if ui.feedback.is_active then
        -- print('Feedback active.')
        ui:show_feedback()
    end
    -- local t = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
    -- local distance = 0
    -- if t ~= nil then 
    --     distance = t.distance:sqrt()
    -- end

    if ui.is_setup and ui.hotbar.hide_hotbars == false then
        ui:check_recasts(player.hotbar, player.vitals, player.hotbar_settings.active_environment, distance)
    end
end)
-- ON MP CHANGE
windower.register_event('mp change', function(new, old)
    player.vitals.mp = new
    ui:check_vitals(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
end)

-- OM TP CHANGE
windower.register_event('tp change', function(new, old)
    player.vitals.tp = new
    ui:check_vitals(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
end)

-- ON STATUS CHANGE
windower.register_event('status change', function(new_status_id)
    -- hide/show bar in cutscenes
    if ui.hotbar.hide_hotbars == false and new_status_id == 4 then
        ui.hotbar.hide_hotbars = true
        ui:hide()
    elseif ui.hotbar.hide_hotbars and new_status_id ~= 4 then
        ui.hotbar.hide_hotbars = false
        ui:show(player.hotbar, player.hotbar_settings.active_environment)
    end
end)

-- ON LOGIN/LOAD

windower.register_event('login', 'load', function()
    if windower.ffxi.get_player() ~= nil then
        player.id = windower.ffxi.get_player().id
        initialize()
    end
end)
windower.register_event('zone change', 'load', function()

--     player:update_id(windower.get_player().id)
end)

-- ON ACTION USED

windower.register_event('action', function(act)
    -- print('used', act.param)
    if (act.param == 211 or act.param == 212) then 
        if (act.actor_id == player.id and act.category == 0x06) then
            player:load_job_ability_actions(act.param)
            ui:load_player_hotbar(player.hotbar, player.vitals, player.hotbar_settings.active_environment)
        end
    end
end)

-- ON ZONE 

windower.register_event('incoming chunk', function(id, data)
    if (id == 0x00A) then 
        ui.hotbar.hide_hotbars = false
        ui:show(player.hotbar, player.hotbar_settings.active_environment)
    elseif (id == 0x00B) then
        ui.hotbar.hide_hotbars = true
        ui:hide()
    end
end)

windower.register_event('add item', 'remove item', function(id, bag, index, count)
    ui:update_inventory_count()
end)

-- ON JOB CHANGE
windower.register_event('job change',function(main_job, main_job_level, sub_job, sub_job_level)
    player:update_jobs(resources.jobs[main_job].ens, resources.jobs[sub_job].ens)
    reload_hotbar()
end)