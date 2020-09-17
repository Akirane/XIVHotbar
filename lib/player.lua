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

local action_manager = require('lib/action_manager')
local player = {}

--job_functions = {}

player.name = ''
player.main_job = ''
player.sub_job = ''
player.server = ''

player.vitals = {}
player.vitals.mp = 0
player.vitals.tp = 0
player.id = 0
player.current_weapon = 0

local debug = false


function player:get_current_weapontype()
	return current_weaponskill
end

function player:get_hotbar_info()
	local hotbar = action_manager.hotbar 
	local active_environment = action_manager.hotbar_settings.active_environment
	local vitals = player.vitals
	return hotbar, active_environment, vitals
end

-- initialize player
function player:initialize(windower_player, server, theme_options)
    self.name      = windower_player.name
    self.main_job  = windower_player.main_job
    self.sub_job   = windower_player.sub_job
    self.server    = server
    self.buffs     = windower_player.buffs
    self.id        = windower_player.id
    self.vitals.mp = windower_player.vitals.mp
    self.vitals.tp = windower_player.vitals.tp
	action_manager:initialize(theme_options)
	action_manager:update_file_path(player.name, player.main_job)
end

function player:remove_action(remove_table)
	action_manager:remove_action(self, remove_table)
end

-- update player jobs
function player:update_job(main, sub)
    self.main_job = main
    self.sub_job = sub
	action_manager:update_file_path(player.name, player.main_job)
end

-- load hotbar for current player and job combination
function player:load_hotbar()
    action_manager:reset_hotbar()
	action_manager:load(self)
end

function player:swap_actions(swap_table)
	action_manager:swap_actions(player, swap_table)
end

function player:load_weaponskill_actions(skill_type)
	player.current_weapon = skill_type
end

function player:load_job_ability_actions(buff_id)
	action_manager:update_stance(buff_id)
	action_manager:load(self)
end

-- toggle bar environment
function player:toggle_environment()
	action_manager:toggle_environment()
end

-- set bar environment to battle
function player:set_battle_environment(in_battle)
    local environment = 'field'
    if in_battle then environment = 'battle' end

    action_manager.hotbar_settings.active_environment = environment
end

-- change active hotbar
function player:change_active_hotbar(new_hotbar)
	action_manager:change_active_hotbar(new_hotbar)
end

function player:insert_action(args)
	action_manager:insert_action(player.sub_job, args)
end

function player:determine_summoner_id(pet_name)
	for buff_id, buff_name in pairs(buff_table) do
		if buff_name == pet_name then
			return buff_id
		end
	end
	return 0
end

function player:get_active_hotbar()
	return action_manager.hotbar_settings.active_hotbar
end


-- execute action from given slot
function player:execute_action(slot)
	action = action_manager:get_action(slot)

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

return player
