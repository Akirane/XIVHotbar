--[[
        Copyright © 2017, SirEdeonX
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
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local database = {}

local abilities_file = file.new('/resources/abils.xml')
local spells_file = file.new('/resources/spells.xml')
local res = require('resources')
local debug = true

database.spells = {}
database.abilities = {}
database.weapon_skills = {}

-- import skills from xml files
function database:import()
    self:parse_abilities_lua()
    self:parse_ws_lua()
    self:parse_spells_lua()

    return true
end

function database:map_ws(ws_id) 
	-- H2H
	if ws_id > 0 and ws_id < 16 then return 0 
	-- Dagger
	elseif ws_id > 16 and ws_id < 32 then return 1 
	elseif ws_id == 224 then return 1
	-- Sword
	elseif ws_id > 32 and ws_id <= 47 then return 2 
	elseif ws_id > 224 and ws_id <= 255 then return 2
	-- Great Sword
	elseif ws_id > 48 and ws_id <= 61 then return 3
	-- Axe
	elseif ws_id > 64 and ws_id <= 77 then return 4
	-- Great Axe
	elseif ws_id > 79 and ws_id <= 93 then return 5
	-- Scythe
	elseif ws_id > 95 and ws_id <= 109 then return 6
	-- Polearm
	elseif ws_id > 112 and ws_id <= 125 then return 7
	-- Katana
	elseif ws_id > 127 and ws_id <= 141 then return 8
	-- Great katana
	elseif ws_id > 144 and ws_id <= 158 then return 9
	-- Club
	elseif ws_id > 158 and ws_id <= 176 then return 10
	-- Staff
	elseif ws_id > 176 and ws_id <= 191 then return 11
	--bow
	elseif ws_id > 191 and ws_id <= 203 then return 12
	elseif ws_id > 203 and ws_id <= 221 then return 13
	end
	
	return 0
end

-- parse abilities xml
function database:parse_ws_lua()
    local contents = res.weapon_skills

	for key, abil in pairs(contents) do
		new_weapon_skill             = {}
		new_weapon_skill.id          = tostring(contents[key].id)
		new_weapon_skill.icon        = string.format("%02d", database:map_ws(contents[key].id))
		new_weapon_skill.name        = contents[key].en
		new_weapon_skill.tpcost      = tostring(1000)
		new_weapon_skill.cast        = tostring(0)
		new_weapon_skill.recast      = new_weapon_skill.cast
		new_weapon_skill.element     = tostring(contents[key].element)
		new_weapon_skill.skillChainA = contents[key].skillchain_a
		new_weapon_skill.skillChainB = contents[key].skillchain_b
		new_weapon_skill.skillChainC = contents[key].skillchain_c
		self.weapon_skills[(new_weapon_skill.name):lower()] = new_weapon_skill
	end

end

-- parse abilities xml
function database:parse_abilities()
    local contents = xml.read(abilities_file)

    for key, abil in ipairs(contents.children) do
        local new_abil = {}

        for key, attr in ipairs(abil.children) do
            if attr.name == 'id' then
                new_abil.id = attr.value
            elseif attr.name == 'index' then
                new_abil.icon = attr.value
            elseif attr.name == 'english' then
                new_abil.name = attr.value
            elseif attr.name == 'mpcost' then
                new_abil.mpcost = attr.value
            elseif attr.name == 'tpcost' then
                new_abil.tpcost = attr.value
            elseif attr.name == 'casttime' then
                new_abil.cast = attr.value
            elseif attr.name == 'recast' then
                new_abil.recast = attr.value
            elseif attr.name == 'element' then
                new_abil.element = attr.value
            elseif attr.name == 'wsA' then
                new_abil.skillChainA = attr.value
            elseif attr.name == 'wsB' then
                new_abil.skillChainB = attr.value
            elseif attr.name == 'wsC' then
                new_abil.skillChainC = attr.value
            end
        end

        self.abilities[(new_abil.name):lower()] = new_abil
    end
end

function database:parse_abilities_lua()
    local contents = res.job_abilities

    for key, abil in pairs(contents) do
        local new_abil = {}
		new_abil.id = tostring(contents[key].recast_id)
		new_abil.icon = new_abil.id
		new_abil.name = contents[key].en
		new_abil.mpcost = tostring(contents[key].mp_cost)
		new_abil.tpcost = tostring(contents[key].tp_cost)
		new_abil.cast = tostring(0)
		new_abil.recast = tostring(0)
		new_abil.element = tostring(contents[key].element)
        self.abilities[(new_abil.name):lower()] = new_abil
    end
end

-- parse spells lua 
function database:parse_spells_lua()
    local contents = res.spells

    for key, spell in pairs(contents) do
        local new_spell = {}
		new_spell.id = tostring(contents[key].id)
		new_spell.icon = new_spell.id
		new_spell.name = contents[key].en
		new_spell.mpcost = tostring(contents[key].mp_cost)
		new_spell.cast = contents[key].cast_time
		new_spell.element = contents[key].element
		new_spell.recast = contents[key].recast
        self.spells[(new_spell.name):lower()] = new_spell
    end
end
function database:parse_spells()
    local contents = xml.read(spells_file)

    for key, spell in ipairs(contents.children) do
        local new_spell = {}

        for key, attr in ipairs(spell.children) do
            if attr.name == 'id' then
                new_spell.id = attr.value
            elseif attr.name == 'index' then
                new_spell.icon = attr.value
            elseif attr.name == 'english' then
                new_spell.name = attr.value
            elseif attr.name == 'mpcost' then
                new_spell.mpcost = attr.value
            elseif attr.name == 'casttime' then
                new_spell.cast = attr.value
            elseif attr.name == 'element' then
                new_spell.element = attr.value
            elseif attr.name == 'recast' then
                new_spell.recast = attr.value
            end
        end
        self.spells[(new_spell.name):lower()] = new_spell
    end
end

return database
