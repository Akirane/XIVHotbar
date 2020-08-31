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
            * Neither the name of hotbar nor the
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

local hover_icon = {}
local database = require('database')  -- TODO: IMPORT FROM RES

local ui = {}

local buffs = {}

local text_setup = {
    flags = {
        draggable = false
    }
}

local environment_text_setup = {
    flags = {
        draggable = false,
    }
}

local inventory_count_setup = {
    flags = {
        draggable = false
    }
}
local sack_count_setup = {
    flags = {
        draggable = false
    }
}

local right_text_setup = {
    flags = {
        right = true,
        draggable = false
    }
}

local playerinv = {}
local is_silenced = false
local is_amnesiad = false
local is_neutralized = false
local can_ws = false
local current_mp = 0

local keyboard = require('keyboard_mapper')
-- ui metrics
ui.hotbar_width = 0
ui.hotbar = require('variables')
ui.hotbar_spacing = 0
ui.slot_spacing = 0
ui.pos_x = 0
ui.pos_y = 0

ui.image_height = 40
ui.image_width = 40

local images_setup = {
    draggable = false,
    size = {
        width  = ui.image_width,
        height = ui.image_height 
    },
    texture = {
        fit = false 
    },
    visible = false
}

-- ui variables
-- ui.battle_notice = images.new(table.copy(images_setup, true))
ui.battle_notice = images.new()
ui.feedback_icon = nil
ui.hotbars = {}

-- ui theme options
ui.theme = {}

-- ui control
ui.feedback = {}
ui.feedback.is_active = false
ui.feedback.current_opacity = 0
ui.feedback.max_opacity = 0
ui.feedback.speed = 0

ui.disabled_slots = {}
ui.disabled_slots.actions = {}
ui.disabled_slots.no_vitals = {}
ui.disabled_slots.on_cooldown = {}

ui.is_setup = false
----------------------------------
-- Text/Image related functions --
----------------------------------

function setup_image(image, path)
    image:path(path)
    image:repeat_xy(1, 1)
    image:draggable(false)
    image:fit(false)
    image:alpha(255)
    image:size(ui.image_width, ui.image_height)
    image:show()
end

function setup_slot(image, path)
    image:path(path)
    image:repeat_xy(1, 1)
    image:draggable(false)
    image:fit(false)
    image:alpha(255)
    image:size(ui.image_width, ui.image_height)
    image:show()
end

function setup_text(text, theme_options)
    text:bg_alpha(0)
    text:bg_visible(false)
    text:font(theme_options.font)
    text:size(theme_options.font_size)
    text:color(theme_options.font_color_red, theme_options.font_color_green, theme_options.font_color_blue)
    text:stroke_transparency(theme_options.font_stroke_alpha)
    text:stroke_color(theme_options.font_stroke_color_red, theme_options.font_stroke_color_green, theme_options.font_stroke_color_blue)
    text:stroke_width(theme_options.font_stroke_width)
    text:show()
end

-- get x position for a given hotbar and slot
function ui:get_slot_x(h, i)
	local x
	if (self.theme.offsets[tostring(h)] ~= nil) then
		if (self.theme.offsets[tostring(h)].Vertical == true) then
			if (i < math.floor(self.theme.columns / 2)+1) then
				x = self.theme.offsets[tostring(h)].OffsetX 	
			else
				x = self.theme.offsets[tostring(h)].OffsetX + (ui.image_width + self.slot_spacing) 	
			end
		else
			x =  self.pos_x + self.theme.offsets[tostring(h)].OffsetX + ((ui.image_width + self.slot_spacing) * (i - 1))
		end
	else
		x =  self.pos_x + ((ui.image_width + self.slot_spacing) * (i - 1))
	end
	return x
end

-- get y position for a given hotbar and slot
function ui:get_slot_y(h, i)
	local y
	if (self.theme.offsets[tostring(h)] ~= nil) then
		if (self.theme.offsets[tostring(h)].Vertical == true) then
			if (i < math.floor(self.theme.columns / 2)+1) then
				y =  self.theme.offsets[tostring(h)].OffsetY + ((ui.image_width + self.slot_spacing) * (i - 1))
			else
				y =  self.theme.offsets[tostring(h)].OffsetY + ((ui.image_width + self.slot_spacing) * (i - math.floor(self.theme.columns / 2) - 1))
			end
		else
			y = self.theme.offsets[tostring(h)].OffsetY 	
		end
	else
		y = self.pos_y - (((h - 1) * (self.hotbar_spacing-3)))
	end
    return y 
end

ui.disabled_icons = {}

function ui:setup_disabled_icons()
    for h=1, ui.hotbar.rows,1 do
        self.disabled_icons[#ui.disabled_icons+1] = {}
        for i=1, ui.hotbar.columns, 1 do
            self.disabled_icons[h][#ui.disabled_icons[h]+1] = 0
        end
    end
end

--------------
-- Setup UI --
--------------

function ui:change_image(environment, hotbar, slot)
end

function ui:setup(theme_options)
    database:import()

    self.theme = theme_options
    self.hotbar.columns = self.theme.columns
    self.hotbar.rows    = self.theme.rows
	self.image_width = math.floor(self.image_width * self.theme.slot_icon_scale)
	self.image_height = math.floor(self.image_height * self.theme.slot_icon_scale)
	hover_icon = images.new(table.copy(images_setup, true))
    setup_image(hover_icon, windower.addon_path..'/images/other/square.png')
	hover_icon:hide()
	hover_icon:size(self.image_width+2, self.image_height+2)
    self:setup_metrics(self.theme)
    self:setup_disabled_icons()
    self:load(self.theme)

    self.is_setup = true
end

function ui:init_hotbar(theme_options, number)
    local hotbar            = {}
    hotbar.slot_background  = {}
    hotbar.slot_icon        = {}
    hotbar.slot_recast      = {}
    hotbar.slot_frame       = {}
    hotbar.slot_text        = {}
    hotbar.slot_cost        = {}
    hotbar.slot_recast_text = {}
    hotbar.slot_key         = {}
	hotbar.number           = texts.new(table.copy(text_setup), true)
	setup_text(hotbar.number, theme_options)
	hotbar.number:text(tostring(number))
	if (theme_options.offsets[tostring(number)].Vertical == true) then
		hotbar.number:pos(ui:get_slot_x(number, 0)+30, ui:get_slot_y(number, 0)+25)
	else
		hotbar.number:pos(ui:get_slot_x(number, 0)+30, ui:get_slot_y(number, 0))
	end
	hotbar.number:size(theme_options.font_size + 5)
	hotbar.number:font('agave Nerd Font')
	return hotbar
end

function ui:init_slot(hotbar, row, column, theme_options)

    local slot_pos_x = self:get_slot_x(row, column)
    local slot_pos_y = self:get_slot_y(row, column)
    local right_slot_pos_x = slot_pos_x - windower.get_windower_settings().x_res + 16

    hotbar.slot_background[column] = images.new(table.copy(images_setup, true))
    hotbar.slot_icon[column] = images.new(table.copy(images_setup, true))
    hotbar.slot_recast[column] = images.new(table.copy(images_setup, true))
    hotbar.slot_frame[column] = images.new(table.copy(images_setup, true))
--    hotbar.slot_element[column] = images.new(table.copy(images_setup, true))

    hotbar.slot_text[column] = texts.new(table.copy(text_setup), true)
    hotbar.slot_cost[column] = texts.new(table.copy(text_setup), true)
    hotbar.slot_recast_text[column] = texts.new(table.copy(text_setup), true)
    hotbar.slot_key[column] = texts.new(table.copy(text_setup), true)

    setup_image(hotbar.slot_background[column], windower.addon_path..'/themes/' .. (theme_options.slot_theme:lower()) .. '/slot.png')
    setup_image(hotbar.slot_icon[column], windower.addon_path..'/images/other/blank.png')
    setup_image(hotbar.slot_frame[column], windower.addon_path..'/themes/' .. (theme_options.frame_theme:lower()) .. '/frame.png')

    setup_text(hotbar.slot_text[column], theme_options)
    setup_text(hotbar.slot_cost[column], theme_options)
    setup_text(hotbar.slot_recast_text[column], theme_options)
    setup_text(hotbar.slot_key[column], theme_options)

    hotbar.slot_background[column]:alpha(theme_options.slot_opacity)
    hotbar.slot_background[column]:pos(slot_pos_x, slot_pos_y)
    hotbar.slot_recast[column]:pos(slot_pos_x, slot_pos_y)

	hotbar.slot_recast[column]:alpha(5)
    hotbar.slot_icon[column]:pos(slot_pos_x, slot_pos_y)
    hotbar.slot_frame[column]:pos(slot_pos_x, slot_pos_y)

    hotbar.slot_text[column]:pos(slot_pos_x, slot_pos_y + ui.image_height -12)

    hotbar.slot_cost[column]:stroke_transparency(220)
    hotbar.slot_cost[column]:pos(slot_pos_x - 1, slot_pos_y - 4)
    hotbar.slot_cost[column]:size(theme_options.font_size)
    hotbar.slot_cost[column]:hide()

    hotbar.slot_key[column]:alpha(255)
    hotbar.slot_key[column]:stroke_width(2)
    hotbar.slot_key[column]:pos(slot_pos_x - 1, slot_pos_y - 4)
    hotbar.slot_key[column]:size(theme_options.font_size)
    hotbar.slot_key[column]:alpha(255)

    hotbar.slot_recast_text[column]:pos(slot_pos_x - 1, slot_pos_y - 4)
    hotbar.slot_recast_text[column]:alpha(255)
    hotbar.slot_recast_text[column]:color(100, 200, 255)
    hotbar.slot_recast_text[column]:size(theme_options.font_size)
    hotbar.slot_recast_text[column]:hide()

    if keyboard.hotbar_rows[row] == nil or keyboard.hotbar_rows[row][column] == nil then 
        hotbar.slot_key[column]:text("")
    else
        hotbar.slot_key[column]:text(convert_string(keyboard.hotbar_rows[row][column]))
    end
end

function ui:setup_feedback(theme_options)
    self.feedback_icon = images.new(table.copy(images_setup, true))
    setup_image(self.feedback_icon, windower.addon_path .. '/images/other/feedback.png')
    self.feedback.max_opacity = theme_options.feedback_max_opacity
    self.feedback.speed = theme_options.feedback_speed
    self.feedback.current_opacity = self.feedback.max_opacity
    self.feedback_icon:hide()
end

-- load the images and text
function ui:load(theme_options)
    -- create ui elements for hotbars
    for h=1,theme_options.hotbar_number,1 do
        self.hotbars[h] = ui:init_hotbar(theme_options, h)
        for i=1, theme_options.columns,1 do
            ui:init_slot(self.hotbars[h], h, i, theme_options)
        end
    end

    -- load feedback icon last so it stays above everything else
    ui:setup_feedback(theme_options)
end

function convert_string(text)
    msg = ''
    for i = 1, #text do
        local v = text:sub(i,i)
        if v == '^' then
          msg = msg .. 'C-'
        elseif v == '%' then 
          msg = msg .. ''
        elseif v == '!' then
          msg = msg .. 'A-'
        elseif v == '@' then
          msg = msg .. 'Win-'
        elseif v == '~' then
          msg = msg .. 'S-'
        else
          msg = msg .. string.upper(v)
        end
    end
    return msg 
end

--[[ Update buffs 

      Checks against the following debuffs:
      1. Sleep/Stun: If one of these are found, interrupt the for loop 
        2   = Sleep
        10  = Stun
        19  = Sleep
        28  = Terror
        193 = Lullaby
      2. Silence/Amnesia: If both are active, interrupt the for loop

]]--
function update_buffs(id, data)
    if id == 0x063 then
        if data:byte(0x05) == 0x09 then
            local silenced = false
            local amnesiad = false
            local neutralized = false
            for i= 1,32 do 
                local buff_id = data:unpack('H', i*2+7)
                if (buff_id == 2 or buff_id == 10 or buff_id == 19 or buff_id == 28 or buff_id == 193) then neutralized = true end
                if (neutralized) then break end
                if (buff_id == 6) then silenced = true end
                if (buff_id == 16) then amnesiad = true end
                if (silenced and amnesiad) then break end
            end
            is_neutralized = neutralized
            is_silenced = silenced
            is_amnesiad = amnesiad
        end
    end
end


function ui:update_inventory_count()
    if (self.is_setup == true) then
        if (self.theme.hide_inventory_count == false) then
            self.playerinv = windower.ffxi.get_items()
            ui:get_inventory_count(self.inventory_count, self.playerinv.inventory)
        end
    end
end

function ui:get_inventory_count(text_box, bag)
    text_box:text(bag.count..'/'..bag.max)
    if (bag.max - bag.count < 4) then
        text_box:color(240, 0, 0)
    else
        text_box:color(self.theme.red, self.theme.green, self.theme.blue)
    end
end

function ui:setup_environment_numbers()
    if self.theme.hide_battle_notice == false then
        self.active_environment['field']:text('  1  ')
        self.active_environment['battle']:text('  2  ')
    else
        self.active_environment['field']:text('')
        self.active_environment['battle']:text('')
    end
	local env_pos_x = ui:get_slot_x(self.theme.environment.hook_onto_bar, self.theme.columns+1) - 10
	local env_pos_y = ui:get_slot_y(self.theme.environment.hook_onto_bar, 0)
    self.active_environment['field']:pos(env_pos_x, env_pos_y)
    self.active_environment['field']:size(self.theme.font_size + 13)
    self.active_environment['field']:show()
    self.active_environment['field']:italic(false)
    self.active_environment['battle']:pos(env_pos_x, env_pos_y + self.theme.font_size + 41)
    self.active_environment['battle']:italic(false)
    self.active_environment['battle']:size(self.theme.font_size + 13)
    self.active_environment['battle']:show()

    self.inventory_count = texts.new(inventory_count_setup)
    setup_text(self.inventory_count, self.theme) 
    self.active_inv_pos_y = self.pos_y + ui.image_height/2 +5

    if (self.theme.hide_inventory_count == false) then
        self.inventory_count:pos(env_pos_x + 10, env_pos_y + self.theme.font_size + 91)
        self.inventory_count:size(self.theme.font_size+1)
        ui:get_inventory_count(self.inventory_count, self.playerinv.inventory)
        self.inventory_count:show()
    end
end

-- setup positions and dimensions for ui
function ui:setup_metrics(theme_options)
    self.playerinv = windower.ffxi.get_items()
    self.active_environment = {}
    self.active_environment['field'] = {}
    self.active_environment['battle'] = {}
    self.active_environment['field'] = texts.new(table.copy(environment_text_setup), true)
    self.active_environment['battle'] = texts.new(table.copy(environment_text_setup), true)
    setup_text(self.active_environment['field'], theme_options) 
    setup_text(self.active_environment['battle'], theme_options) 

    self.hotbar_width = ((40*self.hotbar.columns) + theme_options.slot_spacing * (self.hotbar.columns-1))
    self.scaled_pos_x = windower.get_windower_settings().ui_x_res
    self.scaled_pos_y = windower.get_windower_settings().ui_y_res
    self.pos_x = 0 --math.floor(self.scaled_pos_x/2.0) + theme_options.offset_x 
    self.pos_y = 0 --self.scaled_pos_y + theme_options.offset_y

    self.slot_spacing = theme_options.slot_spacing 

    if theme_options.hide_action_names == true then
        theme_options.hotbar_spacing = theme_options.hotbar_spacing - 10
        self.pos_y = self.pos_y + 10
    end

    self.hotbar_spacing = theme_options.hotbar_spacing 
    ui:setup_environment_numbers()
end

function ui:swap_icons(swap_table)
	local source_row  = swap_table.source.row
	local source_slot = swap_table.source.slot
	local dest_row    = swap_table.dest.row
	local dest_slot   = swap_table.dest.slot
	local tempPathSource = self.hotbars[source_row].slot_icon[source_slot]:path()
	local tempTextSource = self.hotbars[source_row].slot_text[source_slot]:text()
	local tempPathDest   = self.hotbars[dest_row].slot_icon[dest_slot]:path()
	local tempTextDest   = self.hotbars[dest_row].slot_text[dest_slot]:text()

	self.hotbars[dest_row].slot_text[dest_slot]:text(tempTextSource)
	self.hotbars[dest_row].slot_icon[dest_slot]:path(tempPathSource)
	self.hotbars[source_row].slot_text[source_slot]:text(tempTextDest)
	self.hotbars[source_row].slot_icon[source_slot]:path(tempPathDest)
end

-- hide all ui components
function ui:hide()
    self.battle_notice:hide()
    self.feedback_icon:hide()
    if (self.active_environment ~= nil) then
        self.active_environment['battle']:hide()
        self.active_environment['field']:hide()
    end
    self.inventory_count:hide()

    for h=1,self.theme.hotbar_number,1 do

		self.hotbars[h].number:hide()
        for i=1, ui.hotbar.columns, 1 do
            self.hotbars[h].slot_background[i]:hide()
            self.hotbars[h].slot_icon[i]:hide()
            self.hotbars[h].slot_frame[i]:hide()
            self.hotbars[h].slot_recast[i]:hide()
            self.hotbars[h].slot_text[i]:hide()
            self.hotbars[h].slot_cost[i]:hide()
            self.hotbars[h].slot_recast_text[i]:hide()
            self.hotbars[h].slot_key[i]:hide()
        end
    end
end

-- show ui components
function ui:show(player_hotbar, environment)
    if (self.active_environment ~= nil) then
        self.active_environment['battle']:show()
        self.active_environment['field']:show()
    end
    self.inventory_count:show()
    if self.theme.hide_battle_notice == false and environment == 'battle' then self.battle_notice:show() end

    for h=1,self.theme.rows,1 do
        for i=1, self.theme.columns, 1 do
            local slot = i
			local pos_x, pos_y = self.hotbars[h].slot_icon[i]:pos()
			if (pos_x == 0 and pos_y == 0) then
				print("h: " .. h .. ", i: " .. i)
			end
			pos_x, pos_y = self.hotbars[h].slot_recast[i]:pos()
			if (pos_x == 0 and pos_y == 0) then
				print("h: " .. h .. ", i: " .. i)
			end

            local action = player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]

            if self.theme.hide_empty_slots == false then self.hotbars[h].slot_background[i]:show() end
            self.hotbars[h].slot_icon[i]:show()
            if action ~= nil then self.hotbars[h].slot_frame[i]:show() end
			self.hotbars[h].number:show()
            if self.theme.hide_recast_animation == false then self.hotbars[h].slot_recast[i]:show() end
            if self.theme.hide_action_names == false then self.hotbars[h].slot_text[i]:show() end
            if self.theme.hide_recast_text == false then self.hotbars[h].slot_recast_text[i]:show() end
            if self.theme.hide_empty_slots == false then self.hotbars[h].slot_key[i]:show() end
        end
    end
end

----------------
-- Actions UI --
----------------

-- load player hotbar
function ui:load_player_hotbar(player_hotbar, player_vitals, environment)
    if environment == 'battle' and self.theme.hide_battle_notice == false then
        self.active_environment['field']:color(255, 255, 255)
        self.active_environment['battle']:color(100, 100, 100)
    else
        self.active_environment['field']:color(100, 100, 100)
        self.active_environment['battle']:color(255, 255, 255)
    end

    -- reset disabled slots
    self.disabled_slots.actions = {}
    self.disabled_slots.no_vitals = {}
    self.disabled_slots.on_cooldown = {}

    for h=1,self.theme.hotbar_number,1 do
        for i=1, self.theme.columns, 1 do
			self:load_action(h, i, player_hotbar[environment]['hotbar_' .. h]['slot_' .. i], player_vitals)
        end
    end
end

-- load action into a hotbar slot
function ui:load_action(hotbar, slot, action, player_vitals)

    local is_disabled = false

    self:clear_slot(hotbar, slot)

    -- if slot is empty, leave it cleared
    if action == nil then
        if self.theme.hide_empty_slots == true then
            self.hotbars[hotbar].slot_background[slot]:hide()
            self.hotbars[hotbar].slot_key[slot]:hide()
        else
            self.hotbars[hotbar].slot_background[slot]:show()
            self.hotbars[hotbar].slot_key[slot]:show()
        end

        return
    end

    -- if slot has a skill (ma, ja or ws)
    if action.type == 'ma' or action.type == 'ja' then
        -- self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot) + 4, self:get_slot_y(hotbar, slot) + 4) -- temporary fix for 32 x 32 icons
        self.hotbars[hotbar].slot_icon[slot]:fit(false) 
        local skill = nil
        local slot_image = nil

        -- if its magic, look for it in spells
        if action.type == 'ma' and database.spells[(action.action):lower()] ~= nil then
            skill = database.spells[(action.action):lower()]
            self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/spells/' .. (string.format("%05d", skill.icon)) .. '.png')
        elseif (action.type == 'ja' or action.type == 'ws') and database.abilities[(action.action):lower()] ~= nil then
            skill = database.abilities[(action.action):lower()]
            if action.type == 'ja' then
                    self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/abilities/' .. string.format("%05d", skill.icon) .. '.png')
            else
                skill.tpcost = '1000'
            end
        end

        self.hotbars[hotbar].slot_background[slot]:alpha(200)
        self.hotbars[hotbar].slot_icon[slot]:show()

        if skill ~= nil then
            -- display mp cost
            if skill.mpcost ~= nil and skill.mpcost ~= 0 then
                self.hotbars[hotbar].slot_cost[slot]:color(self.theme.mp_cost_color_red, self.theme.mp_cost_color_green, self.theme.mp_cost_color_blue)
                self.hotbars[hotbar].slot_cost[slot]:text(tostring(skill.mpcost))

                if player_vitals.mp < tonumber(skill.mpcost) then
                    self.disabled_slots.no_vitals[action.action] = true
                    is_disabled = true
                end
            -- display tp cost
            elseif skill.tpcost ~= nil and skill.tpcost ~= '0' then
                self.hotbars[hotbar].slot_cost[slot]:color(self.theme.tp_cost_color_red, self.theme.tp_cost_color_green, self.theme.tp_cost_color_blue)
                self.hotbars[hotbar].slot_cost[slot]:text(' ')

                if player_vitals.tp < tonumber(skill.tpcost) then
                    self.disabled_slots.no_vitals[action.action] = true
                    is_disabled = true
                end
            end
        end
    elseif action.type == 'ws' then
        ws = database.weapon_skills[(action.action):lower()]
        --windower.add_to_chat(7, "WS: "..ws.name..", ID: "..ws.id.." Icon: "..ws.icon)
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
        self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/weapons/' .. string.format("%02d", ws.icon) .. '.jpg')
        self.hotbars[hotbar].slot_icon[slot]:show()
    
    -- if action is an item
    elseif action.type == 'item' then
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
        self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/custom/item.png')
        self.hotbars[hotbar].slot_icon[slot]:show()
    -- If action is a gearswap type
    elseif action.type == 'gs' then
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
        self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/custom/gear.png')
        self.hotbars[hotbar].slot_icon[slot]:show()
    -- If no custom icon is defined, just put on a gear.
    else
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
        self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/custom/cog.png')
        self.hotbars[hotbar].slot_icon[slot]:show()
    end

    -- if action is custom
    if action.icon ~= nil then
        self.hotbars[hotbar].slot_background[slot]:alpha(200)
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
        self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/custom/' .. action.icon .. '.png')
        self.hotbars[hotbar].slot_icon[slot]:show()
    end

    -- check if action is on cooldown
    if self.disabled_slots.on_cooldown[action.action] ~= nil then is_disabled = true end

    self.hotbars[hotbar].slot_frame[slot]:show()
    self.hotbars[hotbar].slot_text[slot]:text(action.alias)

    -- hide elements according to settings
    if self.theme.hide_action_names == true then self.hotbars[hotbar].slot_text[slot]:hide() else self.hotbars[hotbar].slot_text[slot]:show() end

    -- if slot is disabled, disable it
    if is_disabled == true then
        self:toggle_slot(hotbar, slot, false)
        self.disabled_slots.actions[action.action] = true
    end
end

-- clear slot
function ui:clear_slot(hotbar, slot)
    self.hotbars[hotbar].slot_background[slot]:alpha(self.theme.slot_opacity)
    self.hotbars[hotbar].slot_frame[slot]:hide()
    self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/other/blank.png')
    self.hotbars[hotbar].slot_icon[slot]:hide()
    self.hotbars[hotbar].slot_icon[slot]:alpha(255)
    self.hotbars[hotbar].slot_icon[slot]:color(255, 255, 255)
    self.hotbars[hotbar].slot_text[slot]:text('')
    self.hotbars[hotbar].slot_cost[slot]:alpha(255)
    self.hotbars[hotbar].slot_cost[slot]:text('')
end

--------------------
-- Disabled Slots --
--------------------

function ui:update_mp(new_mp)
	current_mp = new_mp
end

function ui:update_tp(current_tp)
	if (current_tp < 1000) then can_ws = false else can_ws = true end
end

-- check player vitals
function ui:check_vitals(player_hotbar, player_vitals, environment)
end

function ui:disable_slot(hotbar_index, index, action)

    -- disable slot if it's not disabled
    if self.disabled_slots.actions[action.action] == nil then
        self.disabled_slots.actions[action.action] = true
        self:toggle_slot(hotbar_index, index, false)
    end
end

-- check action recasts
function ui:check_recasts(player_hotbar, player_vitals, environment, distance)
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local spell_recasts = windower.ffxi.get_spell_recasts()
    for h=1, self.theme.rows, 1 do
        for i=1, self.theme.columns, 1 do
            local is_action = false
            local is_disabled = false
            local slot = i
            --if slot == 10 then slot = 0 end
            local action = player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]
            if (action ~= nil) then 
                is_action = true 
            end

            if (is_neutralized == true) then 
                is_disabled = true
            elseif (is_action == true) then
				if (action.type == 'ma' and current_mp < database.spells[(action.action):lower()].mpcost) then
					is_silenced = true 
				else 
					is_silenced = false 
				end
                if (is_silenced == true and action.type == 'ma') then 
                    is_disabled = true 
                elseif (is_amnesiad == true and (action.type == 'ja' or action.type == 'ws')) then 
                    is_disabled = true 
				elseif (action.type == 'ws' and can_ws == false) then
					is_disabled = true
                end
            end

            if (is_action == true and is_disabled == true) then 
                self:disable_slot(h, i, action)
            elseif action == nil  then
				if (self.theme.hide_empty_slots == true) then
					self:hide_recast(h, i)
				else
					self:clear_recast(h, i)
				end
			elseif (action.type ~= 'ma' and action.type ~= 'ja' and action.type ~= 'ws') then
                self:clear_recast(h, i)

            -- if skill is in cooldown
            else
                local skill = nil
                local action_recasts = nil
                local in_cooldown = false
                local is_in_seconds = false

                -- if its magic, look for it in spells
                if action.type == 'ma' and database.spells[(action.action):lower()] ~= nil then
                    skill = database.spells[(action.action):lower()]
                    action_recasts = spell_recasts
                    is_in_seconds = false
                elseif action.type == 'ja' and database.abilities[(action.action):lower()] ~= nil then
                    skill = database.abilities[(action.action):lower()]
                    action_recasts = ability_recasts
                    is_in_seconds = true
                end

                -- check if skill is in cooldown
                if skill ~= nil and action_recasts[tonumber(skill.icon)] ~= nil and action_recasts[tonumber(skill.icon)] > 0 then
                    -- register first cooldown to calculate percentage
                    if self.disabled_slots.on_cooldown[action.action] == nil then
                        self.disabled_slots.on_cooldown[action.action] = action_recasts[tonumber(skill.icon)]

                        -- setup recast elements
                        self.hotbars[h].slot_recast[i]:path(windower.addon_path..'/images/other/black-square.png')
                    end

                    in_cooldown = true
                end


                if in_cooldown == true then
                    -- disable slot if it's not disabled
                    if self.disabled_slots.actions[action.action] == nil then
                        self.disabled_slots.actions[action.action] = true
                        self:toggle_slot(h, i, false)
                        self.disabled_icons[h][i] = 1
                    else
                        self.disabled_icons[h][i] = 1
                    end

                    -- show recast animation
                    local recast_time = calc_recast_time(action_recasts[tonumber(skill.icon)], is_in_seconds)

                    in_cooldown = true

                    self.hotbars[h].slot_recast[i]:show()
                    self.hotbars[h].slot_recast_text[i]:text(recast_time)
                    self.hotbars[h].slot_recast_text[i]:show()
                    self.hotbars[h].slot_key[i]:hide()
                else
                    self.disabled_icons[h][i] = 0
                    self:clear_recast(h, i)

                    if self.disabled_slots.on_cooldown[action.action] == true then
                        self.disabled_slots.on_cooldown[action.action] = nil
                    end

                    -- if it's not disabled by vitals nor cooldown, enable slot
                    if self.disabled_slots.actions[action.action] == true and self.disabled_slots.no_vitals[action.action] == nil then
                        self.disabled_slots.actions[action.action] = nil
                        self:toggle_slot(h, i, true)
                    end
                end
            end
        end
    end
end

ui.hover_icon = {
    row = nil,
    col = nil,
    prev_row = nil,
    prev_col = nil
}

function ui:check_hover()

    local disabled_opacity = self.theme.disabled_slot_opacity
    local enabled_opacity  = 200
    local row              = ui.hover_icon.row
    local col              = ui.hover_icon.col
    local prev_col         = ui.hover_icon.col
    local prev_row         = ui.hover_icon.row

    if (row ~= nil and col ~= nil) then
        if (self.disabled_icons[row][col] == 0) then
            self.hotbars[row].slot_icon[col]:alpha(disabled_opacity)
            prev_row, prev_col = row, col
        end
    elseif(prev_row ~= nil and prev_col ~= nil) then
        if (self.disabled_icons[prev_row][prev_col] == 1) then
            opacity = disabled_opacity
        else
            opacity = enabled_opacity
        end
        self.hotbars[prev_row].slot_icon[prev_col]:alpha(opacity)
        prev_col = nil
        prev_row = nil
    end

    ui.prev_col       = prev_col
    ui.prev_row       = prev_row
    ui.hover_icon.row = row
    ui.hover_icon.col = col
end

-- clear recast from a slot
function ui:clear_recast(hotbar, slot)
    self.hotbars[hotbar].slot_recast[slot]:hide()
    self.hotbars[hotbar].slot_key[slot]:show()
    self.hotbars[hotbar].slot_recast_text[slot]:text('')
    self:toggle_slot(hotbar, slot, true)
end

-- clear recast from a slot
function ui:hide_recast(hotbar, slot)
    self.hotbars[hotbar].slot_recast[slot]:hide()
    self.hotbars[hotbar].slot_key[slot]:hide()
    self.hotbars[hotbar].slot_recast_text[slot]:text('')
    self:toggle_slot(hotbar, slot, true)
end

-- calculate recast time
function calc_recast_time(time, in_seconds)

    local recast = time / 60
    local minutes = math.floor(recast)

    if in_seconds then
        if recast >= 10 then
            recast = string.format("%dm", recast)
        elseif recast >= 1 then
            local minutes_in_seconds = minutes*60
            local seconds = time - minutes_in_seconds
            if recast >= 10 then 
                recast = string.format("%dm", minutes)
            else
                recast = string.format(" %dm%ds", minutes, seconds)
            end
        else
            recast = string.format("%ds", recast * 60)
        end
    else
        if recast >= 60 then
            local minutes = recast/60
            recast = string.format("%dm", minutes)
        elseif recast >= 1 then 
            recast = string.format("%ds", math.round(recast * 10)*0.1)
        else
            recast = string.format("%.1fs", math.round(recast * 10)*0.1)
        end
    end

    return recast
end


-- disable slot
function ui:toggle_slot(hotbar, slot, is_enabled, out_of_range)
    local opacity = self.theme.disabled_slot_opacity

    if is_enabled == true then
        opacity = 255
    end

--    self.hotbars[hotbar].slot_element[slot]:alpha(opacity)
    self.hotbars[hotbar].slot_cost[slot]:alpha(opacity)
    self.hotbars[hotbar].slot_icon[slot]:alpha(opacity)
end


-----------------
-- Feedback UI --
-----------------

-- trigger feedback visuals in given hotbar and slot
function ui:trigger_feedback(hotbar, slot)
    --if slot == 0 then slot = 10 end

    self.feedback_icon:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
    self.feedback.is_active = true
end

-- show feedback
function ui:show_feedback()
    if self.feedback.current_opacity ~= 0 then
        self.feedback.current_opacity = self.feedback.current_opacity - self.feedback.speed
        self.feedback_icon:alpha(self.feedback.current_opacity)
        self.feedback_icon:show()
        if self.feedback.current_opacity < 0 then
            self.feedback_icon:hide()
            self.feedback.current_opacity = self.feedback.max_opacity
            self.feedback.is_active= false
        end
    end
end

-- Returns true if the coordinates are over a button
-- Credit: maverickdfz
-- https://github.com/maverickdfz/FFXIAddons/blob/master/xivhotbar/ui.lua
function ui:hovered(x, y)

    local hotbar = nil
    local slot   = nil
    local found  = false

	local pos_x
    local pos_y
	local debug_msg
	local off_x
	local off_y
	local found = false
	pos_x = self.active_environment['field']:pos_x()
	pos_y = self.active_environment['field']:pos_y() - 60
	off_x = pos_x + 60
	off_y = pos_y + 100
	if  ((pos_x <= x and x <= off_x) or (pos_x >= x and x >= off_x)) 
	and ((pos_y <= y and y <= off_y) or (pos_y >= y and y >= off_y)) 
	then
		hotbar, slot, found = nil, 100, true
	end
	if found == false then
		for h=1,#self.hotbars,1 do
			for i=1,self.theme.columns,1 do
				pos_x = self:get_slot_x(h, i)
				pos_y = self:get_slot_y(h, i)
				off_x = pos_x + self.image_width
				off_y = pos_y + self.image_height

				if  ((pos_x <= x and x <= off_x) or (pos_x >= x and x >= off_x))
				and ((pos_y <= y and y <= off_y) or (pos_y >= y and y >= off_y)) 
				then
					hotbar, slot, found = h, i, true
					break
				end
			end

			if (found == true) then
				break
			end
		end
	end

    return hotbar, slot
end

function ui:light_up_action(row, column)
	local x = ui:get_slot_x(row, column)
	local y = ui:get_slot_y(row, column)
	hover_icon:pos(x-1, y-1)
	hover_icon:alpha(255)
	hover_icon:show()
end

function ui:hide_hover()
	hover_icon:hide()
end

function ui:move_icons(moved_row_info)

	local off_x = moved_row_info.pos_x
	local off_y = moved_row_info.pos_y
	local r = moved_row_info.box_index
	self.theme.offsets[tostring(r)].OffsetX = off_x
	self.theme.offsets[tostring(r)].OffsetY = off_y
	for i=1,self.theme.columns,1 do
		local x = ui:get_slot_x(r, i)
		local y = ui:get_slot_y(r, i)
		self.hotbars[r].slot_icon[i]:pos(x, y)
		self.hotbars[r].slot_frame[i]:pos(x, y)
		self.hotbars[r].slot_recast[i]:pos(x, y)
		self.hotbars[r].slot_background[i]:pos(x, y)
		self.hotbars[r].slot_recast_text[i]:pos(x, y)
		self.hotbars[r].slot_text[i]:pos(x, y + ui.image_height -12)
		self.hotbars[r].slot_key[i]:pos(x, y)
	end
	if (self.theme.offsets[tostring(r)].Vertical == true) then
		self.hotbars[r].number:pos(ui:get_slot_x(r, 0)+30, ui:get_slot_y(r, 0)+25)
	else
		self.hotbars[r].number:pos(ui:get_slot_x(r, 0)+30, ui:get_slot_y(r, 0))
	end
	if (r == self.theme.environment.hook_onto_bar) then
		local env_pos_x = ui:get_slot_x(self.theme.environment.hook_onto_bar, self.theme.columns+1) - 10
		local env_pos_y = ui:get_slot_y(self.theme.environment.hook_onto_bar, 0)

		self.active_environment['field']:pos(env_pos_x, env_pos_y)
		self.active_environment['battle']:pos(env_pos_x, env_pos_y + 50)
        self.inventory_count:pos(env_pos_x + 10, env_pos_y + 100)
	end
end

--[[ 
    Register events
]]--
windower.register_event('incoming chunk', update_buffs)


return ui
