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
local ranges = {[0]=255,[2]=3.40,[3]=4.47,[4]=5.76,[5]=6.89,[6]=7.80,[7]=8.40,[8]=10.40,[9]=12.40,[10]=14.50,[11]=16.40,[12]=20.40,[13]=23.4}

database.ma = {}
database.ja = {}
database.ws = {}

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

local ability_descriptions = require('priv_res/ability_descriptions')	
local spell_descriptions = require('priv_res/spell_descriptions')	

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
        new_weapon_skill.desc        = ability_descriptions[contents[key].id].en
		new_weapon_skill.name        = contents[key].en
		new_weapon_skill.tpcost      = tostring(1000)
		new_weapon_skill.cast        = tostring(0)
		new_weapon_skill.recast      = new_weapon_skill.cast
		new_weapon_skill.element     = tostring(contents[key].element)
		new_weapon_skill.range       = ranges[contents[key].range]

		local function change_sc_string(sc_info)
			if sc_info == "" then return nil else return sc_info end
		end

		new_weapon_skill.sc_a        = change_sc_string(contents[key].skillchain_a)
		new_weapon_skill.sc_b        = change_sc_string(contents[key].skillchain_b)
		new_weapon_skill.sc_c        = change_sc_string(contents[key].skillchain_c)

		self.ws[(new_weapon_skill.name):lower()] = new_weapon_skill
	end

end

local colors = {}            -- Color codes by Sammeh
colors.Light =         '\\cs(255,255,255)'
colors.Dark =          '\\cs(120,120,180)'
colors.Ice =           '\\cs(0,255,255)'
colors.Water =         '\\cs(100,100,255)'
colors.Earth =         '\\cs(221,161,62)'
colors.Wind =          '\\cs(102,255,102)'
colors.Fire =          '\\cs(255,0,0)'
colors.Lightning =     '\\cs(255,0,255)'
colors.Gravitation =   '\\cs(102,51,0)'
colors.Fragmentation = '\\cs(250,156,247)'
colors.Fusion =        '\\cs(255,102,102)'
colors.Distortion =    '\\cs(51,153,255)'
colors.Darkness =      colors.Dark
colors.Umbra =         colors.Dark
colors.Compression =   colors.Dark
colors.Radiance =      colors.Light
colors.Transfixion =   colors.Light
colors.Induration =    colors.Ice
colors.Reverberation = colors.Water
colors.Scission =      colors.Earth
colors.Detonation =    colors.Wind
colors.Liquefaction =  colors.Fire
colors.Impaction =     colors.Lightning
colors[6] = colors.Light     --   '\\cs(255,255,255)'
colors[7] = colors.Dark     --   '\\cs(120,120,180)'
colors[1] = colors.Ice     --   '\\cs(0,255,255)'
colors[5] = colors.Water     --   '\\cs(100,100,255)'
colors[3] = colors.Earth     --   '\\cs(153,76,0)'
colors[2] = colors.Wind     --   '\\cs(102,255,102)'
colors[0] = colors.Fire     --   '\\cs(255,0,0)'
colors[4] = colors.Lightning     --   '\\cs(255,0,255)'

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
		new_abil.range   = ranges[contents[key].range]
        new_abil.desc    = ability_descriptions[contents[key].id + 512].en
		new_abil.cast    = tostring(0)
		new_abil.recast  = tostring(0)
		new_abil.element = tostring(contents[key].element)

        self.ja[(new_abil.name):lower()] = new_abil
    end
end


function database:get_element_color_name(element_name)
	return colors[element_name]
end

function database:get_element_color(element_id)
	return colors[element_id]
end

function database:get_element_name(element_id)
	return res.elements[element_id].en
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
		new_spell.range   = ranges[contents[key].range]
        new_spell.desc    = spell_descriptions[contents[key].id].en

        self.ma[(new_spell.name):lower()] = new_spell
    end
end

return database
