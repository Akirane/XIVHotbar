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

local file_manager = require('lib/file_manager')
local job_root = {}
local action_manager = {}
local subjob_actions = {}
local actions = {}
local general_actions = {}
local stance_actions = {}
local job_ability_actions = {}
local weaponskill_actions = {}
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
}

weaponskill_actions.xivhotbar_keybinds_job = {}
subjob_actions.xivhotbar_keybinds_job = {}

action_manager.theme_options = {}
action_manager.hotbar = {}
action_manager.hotbar_settings = {}
action_manager.hotbar_settings.max = 1
action_manager.hotbar_settings.active_hotbar = 1
action_manager.hotbar_settings.active_environment = 'battle'

_innerG = {}
_innerG.xivhotbar_keybinds_job = {}
general_table = {}
general_table.xivhotbar_keybinds_general = {}

weaponskill_types = {
	[1] = "Hand-to-hand",
	[2] = "Dagger", 
	[3] = "Sword",
	[4] = "Great Sword",
	[5] = "Axe",
	[6] = "Great Axe",
	[7] = "Scythe",
	[8] = "Polearm",
	[9] = "Katana",
	[10] = "Great Katana",
	[11] = "Club",
	[12] = "Staff",
	[25] = "Bow",
	[26] = "Marksmanship",
}


local function create_table(_new_table, _table_key)
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
setmetatable(general_table, general_keybinds_table)
local CUSTOM_TYPE = 'ct'

local function init_action_table(actions_table)
    actions_table.environment = {}
    actions_table.hotbar = {}
    actions_table.slot = {}
    actions_table.type = {}
    actions_table.action = {}
    actions_table.target = {}
    actions_table.alias = {}
	actions_table.icon = {}
end

function action_manager:init_action_tables()
    init_action_table(subjob_actions)
    init_action_table(weaponskill_actions)
    init_action_table(actions)
    init_action_table(general_actions)
    init_action_table(stance_actions)
end

-- build action
function action_manager:build(type, action, target, alias, icon)
    local new_action = {}

    new_action.type   = type
    new_action.action = action
    new_action.target = target

    if alias == nil then alias = ' ' end
    new_action.alias = alias

    if icon ~= nil then
        new_action.icon = icon
    end

    return new_action

end

-- add given action to a hotbar
local function add_action(am, action, environment, hotbar, slot)
    status = true
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    --if slot == 10 then slot = 0 end

    if am.hotbar[environment] == nil then
        windower.console.write('XIVHOTBAR: invalid hotbar (environment)')
        status = false
    end

    if (tonumber(hotbar) > am.hotbar_rows) then 
        status = false
    elseif am.hotbar[environment]['hotbar_' .. hotbar] == nil then
        windower.console.write('XIVHOTBAR: invalid hotbar (hotbar number)')
        status = false
    end
    if status == true then
        if am.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then
            am.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = {} 
            status = false
        end

        am.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = action
    end
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

function action_manager:update_stance(buff_id)
	current_stance = buff_id
end

-- create a default hotbar
local function create_default_hotbar(action_manager)
    windower.console.write('XIVHotbar: no hotbar found. Creating a default hotbar.')

    -- add default actions to the new hotbar
    action_manager:add_action(action_manager:build_custom('attack on', 'Attack', 'attack'), 'field', 1, 1)
    action_manager:add_action(action_manager:build_custom('check', 'Check', 'check'), 'field', 1, 2)
    action_manager:add_action(action_manager:build_custom('returntrust all', 'No Trusts', 'return-trust'), 'field', 1, 9)
    action_manager:add_action(action_manager:build_custom('heal', 'Heal', 'heal'), 'field', 1, 0)
    action_manager:add_action(action_manager:build_custom('check', 'Check', 'check'), 'battle', 1, 9)
    action_manager:add_action(action_manager:build_custom('attack off', 'Disengage', 'disengage'), 'battle', 1, 0)
end

local function parse_general_binds(hotbar)
	for key, val in pairs(hotbar['Root']) do
		fill_table(hotbar['Root'][key], key, general_actions)
	end
end

local function parse_binds(theme_options, player, hotbar)
	for key, val in pairs(hotbar['Base']) do
		fill_table(hotbar['Base'][key], key, actions)
	end

	if (hotbar[player.sub_job] ~= nil) then
		for key, val in pairs(hotbar[player.sub_job]) do
			fill_table(hotbar[player.sub_job][key], key, subjob_actions)
		end
	else
		for key, val in pairs(subjob_actions.environment) do
			self:remove_action()
		end
		subjob_actions = {}
	end

    if (hotbar[buff_table[current_stance]] ~= nil) then
        local stance_table = hotbar[buff_table[current_stance]]
        for key, val in pairs(stance_table) do
            fill_table(stance_table[key], key, stance_actions)
        end
    end

	if (theme_options.enable_weapon_switching == true) then
		if (weaponskill_types[player.current_weapon] ~= nil) then
			if (hotbar[weaponskill_types[player.current_weapon]] ~= nil) then
				for key, val in pairs(hotbar[weaponskill_types[player.current_weapon]]) do
					fill_table(hotbar[weaponskill_types[player.current_weapon]][key], key, weaponskill_actions)
				end
			end
		end
	end
end

function action_manager:initialize(theme_options)
	self.theme_options       = theme_options
    self.hotbar_settings.max = theme_options.hotbar_number
    self.hotbar_rows         = theme_options.rows
end

function action_manager:reset_hotbar()
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
-- build a custom action
function action_manager:build_custom(action, alias, icon)
    return self:build(CUSTOM_TYPE, action, nil, alias, icon)
end

function action_manager:swap_actions(player, swap_table)
	local s_row  = swap_table.source.row
	local s_slot = swap_table.source.slot
	local d_row  = swap_table.dest.row
	local d_slot = swap_table.dest.slot

    if self.hotbar_settings.active_environment == 'battle' then

		if (self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot] ~= nil) then
			if(self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot] == nil) then
				self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot] = table.copy(self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot] , true)
				self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot] = nil

				-- Write the changes after swapping the actions
				local dest_action = self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot] 
				file_manager:write_changes(dest_action, d_row, d_slot, s_row, s_slot, 'b')
			else
				temp_slot = table.copy(self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot], true)
				self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot] = table.copy(self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot], true)
				self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot] = temp_slot

				-- Write the changes after swapping the actions
				local dest_action = self.hotbar['battle']['hotbar_' .. d_row]['slot_' .. d_slot] 
				local source_action = self.hotbar['battle']['hotbar_' .. s_row]['slot_' .. s_slot] 
				file_manager:write_changes(source_action, s_row, s_slot, d_row, d_slot, 'b')
				file_manager:write_changes(dest_action, d_row, d_slot, s_row, s_slot, 'b')
			end
		else
			print("XIVHOTBAR: Cannot swap icons if the dragged icon is empty!")
		end
    else -- field

		if (self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot] ~= nil) then
			if(self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot] == nil) then
				self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot] = table.copy(self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot] , true)
				self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot] = nil

				-- Write the changes after swapping the actions
				local dest_action = self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot] 
				file_manager:write_changes(dest_action, d_row, d_slot, s_row, s_slot, 'f')
			else
				temp_slot = table.copy(self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot], true)
				self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot] = table.copy(self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot], true)
				self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot] = temp_slot

				-- Write the changes after swapping the actions
				local dest_action = self.hotbar['field']['hotbar_' .. d_row]['slot_' .. d_slot] 
				local source_action = self.hotbar['field']['hotbar_' .. s_row]['slot_' .. s_slot] 
				file_manager:write_changes(source_action, s_row, s_slot, d_row, d_slot, 'f')
				file_manager:write_changes(dest_action, d_row, d_slot, s_row, s_slot, 'f')
			end
		else
			print("XIVHOTBAR: Cannot swap icons if the dragged icon is empty!")
		end
    end
end

function action_manager:remove_action(player, remove_table)

	local row = remove_table.source.row
	local slot = remove_table.source.slot

    if self.hotbar_settings.active_environment == 'battle' then
		if (self.hotbar['battle']['hotbar_' .. row]['slot_' .. slot] ~= nil) then
			file_manager:write_remove(self.hotbar['battle']['hotbar_' .. row]['slot_' .. slot], row, slot, 'b')
			self.hotbar['battle']['hotbar_' .. row]['slot_' .. slot] = nil
		end
	else
		if (self.hotbar['battle']['hotbar_' .. row]['slot_' .. slot] ~= nil) then
			file_manager:write_remove(self.hotbar['field']['hotbar_' .. row]['slot_' .. slot], row, slot, 'f')
			self.hotbar['field']['hotbar_' .. row]['slot_' .. slot] = nil
		end
	end
end

function action_manager:insert_action(player_subjob, args)
    if not args[6] then
        print('XIVHOTBAR: Invalid arguments: set <mode> <hotbar> <slot> <action_type> <action> <target (optional)> <alias (optional)> <icon (optional)>')
        return
    end
    local prio = args[1]:lower()
    local row = tonumber(args[2]) or 0
    local slot = tonumber(args[3]) or 0
    local action_type = args[4]:lower()
    local action = args[5]
    local target = args[6] or nil
    local alias = args[7] or nil
    local icon = args[8] or nil

    if target ~= nil then target = target:lower() end
	local environment_to_send = function()
		if self.hotbar_settings.active_environment == 'field' then return 'f' else return 'b' end
	end

    local new_action = action_manager:build(action_type, action, target, alias, icon)
	file_manager:insert_action(new_action, prio, player_subjob, environment_to_send(), row, slot)
end

function action_manager:update_file_path(player_name, player_job)
	file_manager:update_file_path(player_name, player_job)
end

function action_manager:add_actions(action_table)
    for key in pairs(action_table.environment) do 
        add_action(self,
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

function action_manager:toggle_environment()
    if self.hotbar_settings.active_environment == 'battle' then
        self.hotbar_settings.active_environment = 'field'
    else
        self.hotbar_settings.active_environment = 'battle'
    end
end

function action_manager:get_action(slot)
    return self.hotbar[self.hotbar_settings.active_environment]['hotbar_' .. self.hotbar_settings.active_hotbar]['slot_' .. slot]
end

-- change active hotbar
function action_manager:change_active_hotbar(new_hotbar)
    self.hotbar_settings.active_hotbar = new_hotbar

    if self.hotbar_settings.active_hotbar > self.hotbar_settings.max then
        self.hotbar_settings.active_hotbar = 1
    end
end

function action_manager:load(player)
	action_manager:init_action_tables()

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
        parse_binds(self.theme_options, player, root)

		action_manager:add_actions(actions)
        if (subjob_actions.environment ~= nil) then
			action_manager:add_actions(subjob_actions)
        end
        if (stance_actions.environment ~= nil) then
            action_manager:add_actions(stance_actions)
        end
		action_manager:add_actions(weaponskill_actions)
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

		action_manager:add_actions(general_actions)
    end
end

return action_manager
