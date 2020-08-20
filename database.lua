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

local res      = require('resources')
local database = {}

database.spells        = {}
database.abilities     = {}
database.weapon_skills = {}

local wpn_img_ids = {
    ['H2H']          = 0,
    ['Dagger']       = 1,
    ['Sword']        = 2,
    ['Great Sword']  = 3,
    ['Axe']          = 4,
    ['Great Axe']    = 5,
    ['Scythe']       = 6,
    ['Polearm']      = 7,
    ['Katana']       = 8,
    ['Great Katana'] = 9,
    ['Club']         = 10,
    ['Staff']        = 11,
    ['Bow']          = 12,
    ['Marksmanship'] = 13
}

-- import skills from resources
function database:import()

    self:parse_abilities_lua()
    self:parse_ws_lua()
    self:parse_spells_lua()

    return true
end

--[[

    Map weapon skills
    Description: Each weapon skill has an image representing what type it is. 
    Returns an ID or nil.

]]--
function database:map_ws(ws_id) 

    image_id = 0
    if     ws_id >  0   and ws_id <  16  then image_id = wpn_img_ids['H2H']
    elseif ws_id >  16  and ws_id <  32  then image_id = wpn_img_ids['Dagger'] 
    elseif ws_id >  32  and ws_id <= 47  then image_id = wpn_img_ids['Sword'] 
    elseif ws_id >  48  and ws_id <= 61  then image_id = wpn_img_ids['Great Sword']
    elseif ws_id >  64  and ws_id <= 77  then image_id = wpn_img_ids['Axe']
    elseif ws_id >  79  and ws_id <= 93  then image_id = wpn_img_ids['Great Axe']
    elseif ws_id >  95  and ws_id <= 109 then image_id = wpn_img_ids['Scythe']
    elseif ws_id >  112 and ws_id <= 125 then image_id = wpn_img_ids['Polearm']
    elseif ws_id >  127 and ws_id <= 141 then image_id = wpn_img_ids['Katana']
    elseif ws_id >  144 and ws_id <= 158 then image_id = wpn_img_ids['Great Katana']
    elseif ws_id >  158 and ws_id <= 176 then image_id = wpn_img_ids['Club']
    elseif ws_id >  176 and ws_id <= 191 then image_id = wpn_img_ids['Staff']
    elseif ws_id >  191 and ws_id <= 203 then image_id = wpn_img_ids['Bow']
    elseif ws_id >  203 and ws_id <= 221 then image_id = wpn_img_ids['Marksmanship']
    elseif ws_id == 224                  then image_id = wpn_img_ids['Dagger']
    elseif ws_id >  224 and ws_id <= 255 then image_id = wpn_img_ids['Sword']
    end
	
	return image_id
end

--[[
    parse weaponskills (lua)
]]--  
function database:parse_ws_lua()

    local contents = res.weapon_skills

	for key, abil in pairs(contents) do

		local new_weapon_skill       = {}
		new_weapon_skill.id          = tostring(contents[key].id)
		new_weapon_skill.icon        = string.format("%02d", database:map_ws(contents[key].id))
		new_weapon_skill.name        = contents[key].en
		new_weapon_skill.tpcost      = tostring(1000)
		new_weapon_skill.cast        = tostring(0)
		new_weapon_skill.recast      = new_weapon_skill.cast
		new_weapon_skill.element     = tostring(contents[key].element)

		self.weapon_skills[(new_weapon_skill.name):lower()] = new_weapon_skill
	end

end

--[[
    Parse abilities (lua)
]]--  
function database:parse_abilities_lua()

    local contents = res.job_abilities

    for key, abil in pairs(contents) do

        local new_abil   = {}
		new_abil.id      = tostring(contents[key].recast_id)
		new_abil.icon    = new_abil.id
		new_abil.name    = contents[key].en
		new_abil.mpcost  = tonumber(contents[key].mp_cost)
		new_abil.tpcost  = tostring(contents[key].tp_cost)
		new_abil.cast    = tostring(0)
		new_abil.recast  = tostring(0)
		new_abil.element = tostring(contents[key].element)

        self.abilities[(new_abil.name):lower()] = new_abil
    end
end

--[[
    Parse spells (lua)
]]--  
function database:parse_spells_lua()
    local contents = res.spells

    for key, spell in pairs(contents) do

        local new_spell   = {}
        new_spell.id      = tostring(contents[key].id)
        new_spell.icon    = new_spell.id
        new_spell.name    = contents[key].en
        new_spell.mpcost  = contents[key].mp_cost
        new_spell.cast    = contents[key].cast_time
        new_spell.element = contents[key].element
        new_spell.recast  = contents[key].recast

        self.spells[(new_spell.name):lower()] = new_spell
    end
end

return database
