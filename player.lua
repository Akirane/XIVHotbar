--[[
        Copyright © 2020, SirEdeonX, Akirane
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivhotbar nor the
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

--local storage = require('storage')
local action_manager = require('action_manager')
require('luau')
str = require('strings')
texts = require('texts')
local player = {}
local current_zone = 0 
local job_root = {}

local current_stance = nil
buff_table = {
    [211] = 'Light Arts',
    [212] = 'Dark Arts',
	-- Avatars
	[1001] = 'Carbuncle',
	[1002] = 'Ifrit',
	[1003] = 'Shiva',
	[1004] = 'Leviathan',
	[1005] = 'Ramuh',
	[1006] = 'Fenrir',
	[1007] = 'Diabolos',
	[1008] = 'Alexander',
	[1009] = 'Cait Sith',
	[1010] = 'Garuda',
	[1011] = 'Odin',
	[1012] = 'Titan',
	[1013] = 'Atomos',
	-- Weapons
	[2001] = 'Sword',
	[2002] = 'Dagger',
	[2003] = 'Club',
}

--job_functions = {}

player.name = ''
player.main_job = ''
player.sub_job = ''
player.server = ''

player.vitals = {}
player.vitals.mp = 0
player.vitals.tp = 0
player.id = 0

player.hotbar = {}

player.hotbar_settings = {}
player.hotbar_settings.max = 1
player.hotbar_settings.active_hotbar = 1
player.hotbar_settings.active_environment = 'battle'

_innerG = {}
_innerG.xivhotbar_keybinds_job = {}
general_table = {}
general_table.xivhotbar_keybinds_general = {}

local debug = false

weaponskill_enum = {
	dagger = 2,
	sword = 3,
	club = 11,
}

local current_weaponskill = 0

function player:get_current_weapontype()
	return current_weaponskill
end

function create_table(_new_table, _table_key)
    setmetatable(_new_table, {
    __index = function(g, k)
        local t = rawget(rawget(g, table_key), k)
        if not t then
            t = {}
            rawset(rawget(g, table_key), k, t)
        end
        return t
    end,
    __newindex = function(g, k, v)
        local t = rawget(rawget(g, table_key), k)
        if t and type(v) == 'table' then
            for k, v in pairs(v) do
                t[k] = v
            end
        end
    end
})
end

local keybinds_job_table = {
    __index = function(g, k)
        local t = rawget(rawget(g, 'xivhotbar_keybinds_job'), k)
        if not t then
            t = {}
            rawset(rawget(g, 'xivhotbar_keybinds_job'), k, t)
        end
        return t
    end,
    __newindex = function(g, k, v)
        local t = rawget(rawget(g, 'xivhotbar_keybinds_job'), k)
        if t and type(v) == 'table' then
            for k, v in pairs(v) do
                t[k] = v
            end
        end
    end
}

local general_keybinds_table = {
    __index = function(g, k)
        local t = rawget(rawget(g, 'xivhotbar_keybinds_general'), k)
        if not t then
            t = {}
            rawset(rawget(g, 'xivhotbar_keybinds_general'), k, t)
        end
        return t
    end,
    __newindex = function(g, k, v)
        local t = rawget(rawget(g, 'xivhotbar_keybinds_general'), k)
        if t and type(v) == 'table' then
            for k, v in pairs(v) do
                t[k] = v
            end
        end
    end
}

-- Initialize keybinds tables
setmetatable(_innerG, keybinds_job_table)
--setmetatable(_innerJ, keybinds_job_table)
setmetatable(general_table, general_keybinds_table)

-- initialize player
function player:initialize(windower_player, server, theme_options)
    self.name = windower_player.name
    self.main_job = windower_player.main_job
    self.sub_job = windower_player.sub_job
    self.server = server
    self.buffs = windower_player.buffs
    self.id = windower_player.id
    self.hotbar_settings.max = theme_options.hotbar_number
    self.hotbar_rows = theme_options.rows
    self.vitals.mp = windower_player.vitals.mp
    self.vitals.tp = windower_player.vitals.tp
end

function player:update_zone(zone_id)
	current_zone = zone_id
end

-- update player jobs
function player:update_jobs(main, sub)
    self.main_job = main
    self.sub_job = sub

    --storage:update_filename(main, sub)
end

function player:update_id(new_id)
    self.id = new_id
end

-- load hotbar for current player and job combination
function player:load_hotbar()
    self:reset_hotbar()
    self:load_from_lua() 
end

function player:swap_icons(swap_table)
	local s_row = swap_table.source.row
	local s_slot = swap_table.source.slot
	local d_row = swap_table.dest.row
	local d_slot = swap_table.dest.slot

	if (debug == true) then
		print(string.format("DEBUG [Source]: Row: %d, Slot: %d, [Dest]: Row: %d, Col: %d", s_row, s_slot, d_row, d_slot))
	end

    if self.hotbar_settings.active_environment == 'battle' then
		if (debug == true) then
			print("DEBUG Dropping at battle")
		end

		if (self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot] ~= nil) then
			if(self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot] == nil) then
				self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot] = table.copy(self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot] , true)
				self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot] = nil

				-- Write the changes after swapping the actions
				local dest_action = self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot] 
				player:write_changes(dest_action, d_row, d_slot, s_row, s_slot, 'b')
			else
				temp_slot = table.copy(self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot], true)
				self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot] = table.copy(self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot], true)
				self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot] = temp_slot

				-- Write the changes after swapping the actions
				local dest_action = self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot] 
				local source_action = self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot] 
				player:write_changes(source_action, s_row, s_slot, d_row, d_slot, 'b')
				player:write_changes(dest_action, d_row, d_slot, s_row, s_slot, 'b')
			end
		else
			print("XIVHOTBAR: Cannot swap icons if the dragged icon is empty!")
		end
    else -- field
		if (debug == true) then
			print("DEBUG Dropping at field")
		end

		if (self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot] ~= nil) then
			if(self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot] == nil) then
				self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot] = table.copy(self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot] , true)
				self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot] = nil

				-- Write the changes after swapping the actions
				local dest_action = self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot] 
				player:write_changes(dest_action, d_row, d_slot, s_row, s_slot, 'f')
			else
				temp_slot = table.copy(self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot], true)
				self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot] = table.copy(self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot], true)
				self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot] = temp_slot

				-- Write the changes after swapping the actions
				local dest_action = self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot] 
				local source_action = self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot] 
				player:write_changes(source_action, s_row, s_slot, d_row, d_slot, 'f')
				player:write_changes(dest_action, d_row, d_slot, s_row, s_slot, 'f')
			end
		else
			print("XIVHOTBAR: Cannot swap icons if the dragged icon is empty!")
		end
    end
end

function player:remove_icon(remove_table)

	local row = remove_table.source.row
	local slot = remove_table.source.slot

    if self.hotbar_settings.active_environment == 'battle' then
		if (self.hotbar['battle']['hotbar_' .. row]['slot_' .. slot] ~= nil) then
			player:write_remove(self.hotbar['battle']['hotbar_' .. row]['slot_' .. slot], row, slot, 'b')
			self.hotbar['battle']['hotbar_' .. row]['slot_' .. slot] = nil
		end
	else
		if (self.hotbar['battle']['hotbar_' .. row]['slot_' .. slot] ~= nil) then
			player:write_remove(self.hotbar['field']['hotbar_' .. row]['slot_' .. slot], row, slot, 'f')
			self.hotbar['field']['hotbar_' .. row]['slot_' .. slot] = nil
		end
	end
end

subjob_actions = {}
subjob_actions.xivhotbar_keybinds_job = {}
actions = {}
general_actions = {}
stance_actions = {}
local job_ability_actions = {}
weaponskill_actions = {}
weaponskill_actions.xivhotbar_keybinds_job = {}
weaponskill_actions = {}

local function determine_action_type(type)
end

local function fill_table(file_table, file_key, actions_table)
	-- Slot_key is for example 'battle 1 2' in a job file.
	local slot_key = T(file_table[1]:split(' '))
	actions_table.environment[file_key] = slot_key[1]
	actions_table.hotbar[file_key]      = slot_key[2]
	actions_table.slot[file_key]        = slot_key[3]
	actions_table.type[file_key]        = file_table[2]
	actions_table.action[file_key]      = file_table[3]
	actions_table.target[file_key]      = file_table[4]
	actions_table.alias[file_key]       = file_table[5]
	if (file_table[6] ~= nil) then
		actions_table.icon[file_key]    = file_table[6]
	end
end

function player:add_actions(action_table)
    for key in pairs(action_table.environment) do 
        self:add_action(
			action_manager:build(
				action_table.type[key], 
				action_table.action[key], 
				action_table.target[key], 
				action_table.alias[key], 
				action_table.icon[key] 
			),
            action_table.environment[key],
            action_table.hotbar[key],
            action_table.slot[key]
        )
    end
end

local function remove_actions(action_table)
	for key, val in pairs(action_table.environment) do
		self:remove_action(action_table.environment[key],
							action_table.hotbar[key],
							action_table.slot[key])
	end
end

local function parse_binds(fhotbar)
	for key, val in pairs(fhotbar['Base']) do
		fill_table(fhotbar['Base'][key], key, actions)
	end

    if (fhotbar[buff_table[current_stance]] ~= nil) then

        local stance_table = fhotbar[buff_table[current_stance]]
        for key, val in pairs(stance_table) do
            fill_table(stance_table[key], key, stance_actions)
        end
    end

	if (fhotbar[player.sub_job] ~= nil) then
		for key, val in pairs(fhotbar[player.sub_job]) do
			fill_table(fhotbar[player.sub_job][key], key, subjob_actions)
		end
	else
		for key, val in pairs(subjob_actions.environment) do
			self:remove_action()
		end
		subjob_actions = {}
	end

	if (current_weaponskill == weaponskill_enum.dagger) then
		if (fhotbar['Dagger'] ~= nil) then
			for key, val in pairs(fhotbar['Dagger']) do
				fill_table(fhotbar['Dagger'][key], key, weaponskill_actions)
			end
		end
	elseif (current_weaponskill == weaponskill_enum.sword) then
		if (fhotbar['Sword'] ~= nil) then
			for key, val in pairs(fhotbar['Sword']) do
				fill_table(fhotbar['Sword'][key], key, weaponskill_actions)
			end
		end
	elseif (current_weaponskill == weaponskill_enum.club) then
		if (fhotbar['Club'] ~= nil) then
			for key, val in pairs(fhotbar['Club']) do
				fill_table(fhotbar['Club'][key], key, weaponskill_actions)
			end
		end
	end
end

local function parse_general_binds(hotbar)
	for key, val in pairs(hotbar['Root']) do
		fill_table(hotbar['Root'][key], key, general_actions)
	end
end

function init_action_table(actions_table)
    actions_table.environment = {}
    actions_table.hotbar = {}
    actions_table.slot = {}
    actions_table.type = {}
    actions_table.action = {}
    actions_table.target = {}
    actions_table.alias = {}
	actions_table.icon = {}
end

function player:load_weaponskill_actions(skill_type)
	current_weaponskill = skill_type
end

function player:load_job_ability_actions(buff_id)
    current_stance = buff_id
    self:load_from_lua()
end

-- load a hotbar from existing lua file
function player:load_from_lua()

    init_action_table(subjob_actions)
    init_action_table(weaponskill_actions)
    init_action_table(actions)
    init_action_table(general_actions)
    init_action_table(stance_actions)

    local basepath = windower.addon_path .. 'data/'..player.name..'/'
    local file = loadfile(basepath .. player.main_job .. '.lua')
    local general_file = loadfile(basepath .. 'General.lua')
    if file == nil then 
        print(string.format("XIVHOTBAR: Couldn't find the job file %s.lua!", player.main_job))
    else
        setfenv(file, _innerG)
        local root = file()
        job_root = root
        if not root then
            _innerG.xivhotbar_keybinds_job = {}
            _innerG._binds = {}
            return
        end
        _innerG.xivhotbar_keybinds_job = {}
        _innerG.xivhotbar_keybinds_job[root] = _innerG.xivhotbar_keybinds_job[root] or 'Root'
        parse_binds(root)

		self:add_actions(actions)
        if (subjob_actions.environment ~= nil) then
			self:add_actions(subjob_actions)
        end
        if (stance_actions.environment ~= nil) then
            self:add_actions(stance_actions)
        end
		self:add_actions(weaponskill_actions)
    end

    if general_file == nil then 
        print("Error, couldn't find file 'General.lua'")
    else
        setfenv(general_file, general_table)
        local general_root = general_file()
        if not general_root then
            general_table.xivhotbar_keybinds_general = {}
            general_table.binds = {}
            return
        end
        general_table.xivhotbar_keybinds_general = {}
        general_table.xivhotbar_keybinds_general[general_root] = general_table.xivhotbar_keybinds_general[general_root] or 'Root'
        parse_general_binds(general_root)

		self:add_actions(general_actions)
    end
end

-- create a default hotbar
function player:create_default_hotbar()
    windower.console.write('XIVHotbar: no hotbar found. Creating a default hotbar.')

    -- add default actions to the new hotbar
    self:add_action(action_manager:build_custom('attack on', 'Attack', 'attack'), 'field', 1, 1)
    self:add_action(action_manager:build_custom('check', 'Check', 'check'), 'field', 1, 2)
    self:add_action(action_manager:build_custom('returntrust all', 'No Trusts', 'return-trust'), 'field', 1, 9)
    self:add_action(action_manager:build_custom('heal', 'Heal', 'heal'), 'field', 1, 0)
    self:add_action(action_manager:build_custom('check', 'Check', 'check'), 'battle', 1, 9)
    self:add_action(action_manager:build_custom('attack off', 'Disengage', 'disengage'), 'battle', 1, 0)
end

-- reset player hotbar
function player:reset_hotbar()
    self.hotbar = {
        ['battle'] = {},
        ['field'] = {}
    }

    for h=1,self.hotbar_settings.max,1 do
        self.hotbar.field['hotbar_' .. h] = {}
        self.hotbar.battle['hotbar_' .. h] = {}
    end

    self.hotbar_settings.active_hotbar = 1
end

-- toggle bar environment
function player:toggle_environment()
    if self.hotbar_settings.active_environment == 'battle' then
        self.hotbar_settings.active_environment = 'field'
    else
        self.hotbar_settings.active_environment = 'battle'
    end
end

-- set bar environment to battle
function player:set_battle_environment(in_battle)
    local environment = 'field'
    if in_battle then environment = 'battle' end

    self.hotbar_settings.active_environment = environment
end

-- change active hotbar
function player:change_active_hotbar(new_hotbar)
    self.hotbar_settings.active_hotbar = new_hotbar

    if self.hotbar_settings.active_hotbar > self.hotbar_settings.max then
        self.hotbar_settings.active_hotbar = 1
    end
end

-- add given action to a hotbar
function player:add_action(action, environment, hotbar, slot)
    status = true
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    --if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then
        windower.console.write('XIVHOTBAR: invalid hotbar (environment)')
        status = false
    end

    if (tonumber(hotbar) > self.hotbar_rows) then 
        status = false
    elseif self.hotbar[environment]['hotbar_' .. hotbar] == nil then
        windower.console.write('XIVHOTBAR: invalid hotbar (hotbar number)')
        status = false
    end
    if status == true then
        if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then
            self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = {} 
            status = false
        end

        self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = action
    end
end

function player:determine_summoner_id(pet_name)
	for buff_id, buff_name in pairs(buff_table) do
		if buff_name == pet_name then
			return buff_id
		end
	end
	return 0
end

function player:write_remove(action, row, slot, environment)
	if (debug == true) then
		print("player:write_remove was called")
	end

	local basepath = windower.addon_path .. 'data/'..player.name..'/'
	local job_name = player.main_job
	local job_file_location = basepath .. job_name .. '.lua'
	local found_row = player:find_in_file_remove(job_file_location, action, row, slot, environment)

	if (found_row == false) then
		general_file_location = windower.addon_path .. 'data/'..player.name..'/General.lua'
		player:find_in_file_remove(general_file_location, action, row, slot, environment)
	end
end

function player:find_in_file_remove(file_location, action, row, slot, environment)

	local testAc = action.action:lower()
	local row_to_find = string.format('%s %d %d', environment, row, slot)
	local found_row = false
	local fileContent = {}
	local file = io.open(file_location , 'r')

	if (file ~= nil) then
		for line in file:lines() do
			table.insert (fileContent, line)
		end
		for key, val in pairs(fileContent) do
			if (val:contains(row_to_find)) then
				if (val:lower():contains(testAc)) then
					found_row = true
					if (debug == true) then
						print("[player:find_in_file_remove] val:lower():contains(testAc) succeeded")
						print(val)
					end
					fileContent[key] = '0'
					break
				elseif (val:contains("'gs'")) then
					local stripped_row = val:lower()
					i, j = string.find(stripped_row, '%[.*%]')
					k, l = string.find(testAc, '%[.*%]')
					local sub_row = string.sub(stripped_row, i+3, j-3)
					local sub_ac = string.sub(testAc, k+2, l-2)
					if sub_row == sub_ac then
						if (debug == true) then
							print("[player:find_in_file_remove] sub_row == sub_ac succeeded")
							print(val)
						end
						found_row = true
						fileContent[key] = '0'
						break
					end
				end
			end
		end
		if(found_row == true) then
			file = io.open(file_location, 'w')
			for index, value in ipairs(fileContent) do
				if (value ~= '0') then
					file:write(value..'\n')
				end
			end
			io.close(file)
		end
	end
	return found_row
end

function player:write_changes(action, d_row, d_slot, s_row, s_slot, environment)


	if (debug == true) then
		print("player:write_changes was called")
	end

	local basepath = windower.addon_path .. 'data/'..player.name..'/'
	local job_name = player.main_job
	local job_file_location = basepath .. job_name .. '.lua'
	local found_row = player:find_in_file(job_file_location, action, d_row, d_slot, s_row, s_slot, environment)

	if (found_row == false) then
		general_file_location = windower.addon_path .. 'data/'..player.name..'/General.lua'
		player:find_in_file(general_file_location, action, d_row, d_slot, s_row, s_slot, environment)
	end
end

function player:find_in_file(file_location, action, d_row, d_slot, s_row, s_slot, environment)

	local testAc = action.action:lower()
	local row_to_find = string.format('%s %d %d', environment, s_row, s_slot)
	local new_row = string.format('%s %d %d', environment, d_row, d_slot)
	local found_row = false
	local fileContent = {}
	local file = io.open(file_location , 'r')

	if (file ~= nil) then
		for line in file:lines() do
			table.insert (fileContent, line)
		end
		for key, val in pairs(fileContent) do
			if (val:contains(row_to_find)) then
				if (debug == true) then
					print("Found the row")
				end
				if (val:lower():contains(testAc)) then
					found_row = true
					val = string.gsub(val, "%w %d %d+", new_row)
					if (debug == true) then
						print("val:lower():contains(testAc) succeeded")
						print(val)
					end
					fileContent[key] = val
					break
				elseif string.find(val, "'%f[%a]gs%f[%A]'") and string.find(val, 'equip') then
					local stripped_row = val:lower()
					print("This is a gearswap row.")
					print(val)
					i, j = string.find(stripped_row, '%[.*%]')
					k, l = string.find(testAc, '%[.*%]')
					local sub_row = string.sub(stripped_row, i+3, j-3)
					local sub_ac = string.sub(testAc, k+2, l-2)
					if sub_row == sub_ac then
						found_row = true
						val = string.gsub(val, "%w %d %d+", new_row)
						if (debug == true) then
							print("sub_row == sub_ac succeeded")
							print(val)
						end
						fileContent[key] = val
						break
					end
				end
			end
		end
		if(found_row == true) then
			file = io.open(file_location, 'w')
			for index, value in ipairs(fileContent) do
				file:write(value..'\n')
			end
			io.close(file)
		end
	end
	return found_row
end

-- execute action from given slot
function player:execute_action(slot)
    local action = self.hotbar[self.hotbar_settings.active_environment]['hotbar_' .. self.hotbar_settings.active_hotbar]['slot_' .. slot]

    if action == nil then return end

	if action.type == 'ct' then
        local command = '/' .. action.action

        if  action.target ~= nil and action.target ~= "" then
            command = command .. ' <' ..  action.target .. '>'
        end

        windower.chat.input(command)
        return
	elseif action.type == 'macro' then
        windower.chat.input('//'.. action.action)
    elseif action.type == 'ws' then
        windower.chat.input('//'.. action.action .. ' <' .. action.target .. '>')
    elseif action.type == 'gs' then
        windower.chat.input('//gs ' .. action.action)
    elseif action.type == 's' then
        windower.chat.input('//send ' .. action.action)
    else
        windower.chat.input('/' .. action.type .. ' "' .. action.action .. '" <' .. action.target .. '>')
    end
end

-- remove action from slot
function player:remove_action(environment, hotbar, slot)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    --if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = nil
end

-- copy action from one slot to another
function player:copy_action(environment, hotbar, slot, to_environment, to_hotbar, to_slot, is_moving)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if to_environment == 'b' then to_environment = 'battle' elseif to_environment == 'f' then to_environment = 'field' end
    --if slot == 10 then slot = 0 end
    --if to_slot == 10 then to_slot = 0 end

    if self.hotbar[environment] == nil or self.hotbar[to_environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil or self.hotbar[to_environment]['hotbar_' .. to_hotbar] == nil then return end

    self.hotbar[to_environment]['hotbar_' .. to_hotbar]['slot_' .. to_slot] = self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot]

    if is_moving then self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = nil end
end

-- update action alias
function player:set_action_alias(environment, hotbar, slot, alias)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    --if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot].alias = alias
end

-- update action icon
function player:set_action_icon(environment, hotbar, slot, icon)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    --if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot].icon = icon
end

-- save current hotbar
function player:save_hotbar()
    local new_hotbar = {}
    new_hotbar.hotbar = self.hotbar

end

return player
