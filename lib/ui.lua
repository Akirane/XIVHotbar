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

local database = require('priv_res/database')  -- TODO: IMPORT FROM RES
local formatter = require('lib/text_formatter')
local keyboard = require('lib/keyboard_mapper')

local ui = {}

local buffs = {}

local text_setup = {
    flags = {
        draggable = false
    }
}

ui.hover_icon = {
    row = nil,
    col = nil,
    prev_row = nil,
    prev_col = nil
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


-- ui metrics
ui.hotbar_width = 0
ui.hotbar = { 
	initialized = false,
	ready = false,
	hide_hotbars = false,
	in_battle = false
}
ui.hotbar_spacing = 0
ui.slot_spacing = 0
ui.pos_x = 0
ui.pos_y = 0
ui.current_row = 0
ui.current_column = 0
ui.current_text_size = 0

ui.image_height = 40
ui.image_width = 40
ui.recasts = {}

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
ui.disabled_icons = {}

ui.default_image_paths = {
	['default'] = windower.addon_path .. '/images/icons/custom/cog.png',
	['gs'] = windower.addon_path .. '/images/icons/custom/gear.png',
	['item'] = windower.addon_path .. '/images/icons/custom/item.png',
}

-----------------------
-- Private functions --
-----------------------

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
local function update_buffs(id, data)
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

----------------------------------
-- Text/Image related functions --
----------------------------------


-- get x position for a given hotbar and slot
local function get_slot_x(ui, h, i)
	local x
	if (ui.theme.offsets[tostring(h)] ~= nil) then
		if (ui.theme.offsets[tostring(h)].Vertical == true) then
			if (i < math.floor(ui.theme.columns / 2)+1) then
				x = ui.theme.offsets[tostring(h)].OffsetX 	
			else
				x = ui.theme.offsets[tostring(h)].OffsetX + (ui.image_width + ui.slot_spacing) 	
			end
		else
			x =  ui.pos_x + ui.theme.offsets[tostring(h)].OffsetX + ((ui.image_width + ui.slot_spacing) * (i - 1))
		end
	else
		x =  ui.pos_x + ((ui.image_width + ui.slot_spacing) * (i - 1))
	end
	return x
end

-- get y position for a given hotbar and slot
local function get_slot_y(ui, h, i)
	local y
	if (ui.theme.offsets[tostring(h)] ~= nil) then
		if (ui.theme.offsets[tostring(h)].Vertical == true) then
			if (i < math.floor(ui.theme.columns / 2)+1) then
				y =  ui.theme.offsets[tostring(h)].OffsetY + ((ui.image_width + ui.slot_spacing) * (i - 1))
			else
				y =  ui.theme.offsets[tostring(h)].OffsetY + ((ui.image_width + ui.slot_spacing) * (i - math.floor(ui.theme.columns / 2) - 1))
			end
		else
			y = ui.theme.offsets[tostring(h)].OffsetY 	
		end
	else
		y = ui.pos_y - (((h - 1) * (ui.hotbar_spacing-3)))
	end
    return y 
end

-- calculate recast time
local function calc_recast_time(time, type)

	use_minutes = {['ja'] = true, ['ma'] = false}
    local recast = time / 60
    local minutes = math.floor(recast)

    if use_minutes[type] then
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


-- convert_string
local function convert_string(text)
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

local function setup_image(image, path)
    image:path(path)
    image:repeat_xy(1, 1)
    image:draggable(false)
    image:fit(false)
    image:alpha(255)
    image:size(ui.image_width, ui.image_height)
    image:show()
end

local function setup_feedback(ui)
    ui.feedback_icon = images.new(table.copy(images_setup, true))
    setup_image(ui.feedback_icon, windower.addon_path .. '/images/other/feedback.png')
    ui.feedback.max_opacity = ui.theme.feedback_max_opacity
    ui.feedback.speed = ui.theme.feedback_speed
    ui.feedback.current_opacity = ui.feedback.max_opacity
    ui.feedback_icon:hide()
end

local function setup_text(text, theme_options)
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

local function setup_action_info(text, theme_options)
    text:bg_alpha(255)
    text:bg_visible(true)
    text:size(theme_options.font_size + 5)
    text:color(theme_options.font_color_red, theme_options.font_color_green, theme_options.font_color_blue)
    text:stroke_transparency(theme_options.font_stroke_alpha)
    text:stroke_color(theme_options.font_stroke_color_red, theme_options.font_stroke_color_green, theme_options.font_stroke_color_blue)
    text:stroke_width(theme_options.font_stroke_width)
    text:show()
end

-- toggle slot
local function toggle_slot(ui, hotbar, slot, is_enabled)
    local opacity = ui.theme.disabled_slot_opacity

    if is_enabled == true then
        opacity = 255
    end

    ui.hotbars[hotbar].slot_cost[slot]:alpha(opacity)
    ui.hotbars[hotbar].slot_icons[slot]:alpha(opacity)
end

local function disable_slot(ui, hotbar_index, index, action)

    -- disable slot if it's not disabled
    if ui.disabled_slots.actions[action.action] == nil then
        ui.disabled_slots.actions[action.action] = true
        toggle_slot(ui, hotbar_index, index, false)
    end
end

-- clear slot
local function clear_slot(ui, hotbar, slot)
    ui.hotbars[hotbar].slot_backgrounds[slot]:alpha(ui.theme.slot_opacity)
    ui.hotbars[hotbar].slot_frames[slot]:hide()
    ui.hotbars[hotbar].slot_icons[slot]:path(windower.addon_path .. '/images/other/blank.png')
    ui.hotbars[hotbar].slot_icons[slot]:hide()
    ui.hotbars[hotbar].slot_icons[slot]:alpha(255)
    ui.hotbars[hotbar].slot_icons[slot]:color(255, 255, 255)
    ui.hotbars[hotbar].slot_texts[slot]:text('')
    ui.hotbars[hotbar].slot_cost[slot]:alpha(255)
    ui.hotbars[hotbar].slot_cost[slot]:text('')
end

-- clear recast from a slot
local function clear_recast(ui, r, s)
    ui.hotbars[r].slot_recasts[s]:hide()
    ui.hotbars[r].slot_keys[s]:show()
    ui.hotbars[r].slot_recast_texts[s]:text('')
    toggle_slot(ui, r, s, true)
end

-- clear recast from a slot
local function hide_recast(ui, r, s)
    ui.hotbars[r].slot_recasts[s]:hide()
    ui.hotbars[r].slot_keys[s]:hide()
    ui.hotbars[r].slot_recast_texts[s]:text('')
    toggle_slot(ui, r, s, true)
end

local function get_inventory_count(theme, text_box, bag)
    text_box:text(bag.count..'/'..bag.max)
    if (bag.max - bag.count < 4) then
        text_box:color(240, 0, 0)
    else
        text_box:color(theme.font_color_red, theme.font_color_green, theme.font_color_blue)
    end
end

local function setup_slot_icons(ui, img_path, row, slot)
	ui.hotbars[row].slot_icons[slot]:pos(get_slot_x(ui, row, slot), get_slot_y(ui, row, slot))
	ui.hotbars[row].slot_icons[slot]:path(windower.addon_path .. img_path)
	ui.hotbars[row].slot_icons[slot]:show()
end

local function setup_default_slot_icons(ui, type, row, slot)
	ui.hotbars[row].slot_icons[slot]:pos(get_slot_x(ui, row, slot), get_slot_y(ui, row, slot))
	ui.hotbars[row].slot_icons[slot]:path(ui.default_image_paths[type])
	ui.hotbars[row].slot_icons[slot]:show()
end

local function setup_disabled_icons(ui)
    for h=1, ui.theme.rows,1 do
        ui.disabled_icons[#ui.disabled_icons+1] = {}
        for i=1, ui.theme.columns, 1 do
            ui.disabled_icons[h][#ui.disabled_icons[h]+1] = 0
        end
    end
end

local function setup_environment_numbers(ui)
    if ui.theme.hide_battle_notice == false then
        ui.active_environment['field']:text('  1  ')
        ui.active_environment['battle']:text('  2  ')
    else
        ui.active_environment['field']:text('')
        ui.active_environment['battle']:text('')
    end
	local env_pos_x = get_slot_x(ui, ui.theme.environment.hook_onto_bar, ui.theme.columns+1) - 10
	local env_pos_y = get_slot_y(ui, ui.theme.environment.hook_onto_bar, 0)
    ui.active_environment['field']:pos(env_pos_x, env_pos_y)
    ui.active_environment['field']:size(ui.theme.font_size + 13)
    ui.active_environment['field']:show()
    ui.active_environment['field']:italic(false)
    ui.active_environment['battle']:pos(env_pos_x, env_pos_y + ui.theme.font_size + 41)
    ui.active_environment['battle']:italic(false)
    ui.active_environment['battle']:size(ui.theme.font_size + 13)
    ui.active_environment['battle']:show()

    ui.inventory_count = texts.new(inventory_count_setup)
    setup_text(ui.inventory_count, ui.theme) 
    ui.active_inv_pos_y = ui.pos_y + ui.image_height/2 +5

    if (ui.theme.hide_inventory_count == false) then
        ui.inventory_count:pos(env_pos_x + 10, env_pos_y + ui.theme.font_size + 91)
        ui.inventory_count:size(ui.theme.font_size+1)
        get_inventory_count(ui.theme, ui.inventory_count, ui.playerinv.inventory)
        ui.inventory_count:show()
    end
end

-- setup positions and dimensions for ui
function setup_metrics(ui)
    ui.playerinv = windower.ffxi.get_items()
    ui.active_environment = {}
    ui.active_environment['field'] = {}
    ui.active_environment['battle'] = {}
    ui.active_environment['field'] = texts.new(table.copy(environment_text_setup), true)
    ui.active_environment['battle'] = texts.new(table.copy(environment_text_setup), true)
    setup_text(ui.active_environment['field'], ui.theme) 
    setup_text(ui.active_environment['battle'], ui.theme) 

    ui.hotbar_width = ((40*ui.theme.columns) + ui.theme.slot_spacing * (ui.theme.columns-1))
    ui.scaled_pos_x = windower.get_windower_settings().ui_x_res
    ui.scaled_pos_y = windower.get_windower_settings().ui_y_res
    ui.pos_x = 0 
    ui.pos_y = 0 

    ui.slot_spacing = ui.theme.slot_spacing 

    if ui.theme.hide_action_names == true then
        ui.theme.hotbar_spacing = ui.theme.hotbar_spacing - 10
        ui.pos_y = ui.pos_y + 10
    end

    ui.hotbar_spacing = ui.theme.hotbar_spacing 
    setup_environment_numbers(ui)
end

local function setup_slot_cost(slot, pos_x, pos_y, font_size)
    slot:alpha(255)
    slot:pos(pos_x - 1, pos_y - 4)
    slot:size(font_size)
end

-- init slot
local function init_slot(ui, row, column, theme_options)

    local slot_pos_x = get_slot_x(ui, row, column)
    local slot_pos_y = get_slot_y(ui, row, column)
    local right_slot_pos_x = slot_pos_x - windower.get_windower_settings().x_res + 16

    ui.hotbars[row].slot_backgrounds[column]  = images.new(table.copy(images_setup, true))
    ui.hotbars[row].slot_icons[column]        = images.new(table.copy(images_setup, true))
    ui.hotbars[row].slot_recasts[column]      = images.new(table.copy(images_setup, true))
    ui.hotbars[row].slot_frames[column]       = images.new(table.copy(images_setup, true))

    ui.hotbars[row].slot_texts[column]        = texts.new(table.copy(text_setup), true)
    ui.hotbars[row].slot_cost[column]         = texts.new(table.copy(text_setup), true)
    ui.hotbars[row].slot_recast_texts[column] = texts.new(table.copy(text_setup), true)
    ui.hotbars[row].slot_keys[column]         = texts.new(table.copy(text_setup), true)

    setup_image(ui.hotbars[row].slot_backgrounds[column], windower.addon_path..'/themes/' .. (theme_options.slot_theme:lower()) .. '/slot.png')
    setup_image(ui.hotbars[row].slot_icons[column], windower.addon_path..'/images/other/blank.png')
    setup_image(ui.hotbars[row].slot_frames[column], windower.addon_path..'/themes/' .. (theme_options.frame_theme:lower()) .. '/frame.png')

    setup_text(ui.hotbars[row].slot_texts[column], theme_options)
    setup_text(ui.hotbars[row].slot_cost[column], theme_options)
    setup_text(ui.hotbars[row].slot_recast_texts[column], theme_options)
    setup_text(ui.hotbars[row].slot_keys[column], theme_options)

    ui.hotbars[row].slot_backgrounds[column]:alpha(theme_options.slot_opacity)
    ui.hotbars[row].slot_backgrounds[column]:pos(slot_pos_x, slot_pos_y)

    ui.hotbars[row].slot_recasts[column]:pos(slot_pos_x, slot_pos_y)
	ui.hotbars[row].slot_recasts[column]:alpha(5)

    ui.hotbars[row].slot_frames[column]:pos(slot_pos_x, slot_pos_y)
    ui.hotbars[row].slot_icons[column]:pos(slot_pos_x, slot_pos_y)

    ui.hotbars[row].slot_texts[column]:pos(slot_pos_x, slot_pos_y + ui.image_height -12)

	setup_slot_cost(ui.hotbars[row].slot_keys[column], slot_pos_x, slot_pos_y, theme_options.font_size)
    ui.hotbars[row].slot_keys[column]:stroke_width(2)
    ui.hotbars[row].slot_keys[column]:alpha(255)

	setup_slot_cost(ui.hotbars[row].slot_recast_texts[column], slot_pos_x, slot_pos_y, theme_options.font_size)
    ui.hotbars[row].slot_recast_texts[column]:hide()
    ui.hotbars[row].slot_recast_texts[column]:color(100, 200, 255)

    if keyboard.hotbar_rows[row] == nil or keyboard.hotbar_rows[row][column] == nil then 
        ui.hotbars[row].slot_keys[column]:text("")
    else
        ui.hotbars[row].slot_keys[column]:text(convert_string(keyboard.hotbar_rows[row][column]))
    end
end

local function init_hotbar(ui, theme_options, number)
    local hotbar             = {}
    hotbar.slot_backgrounds  = {}
    hotbar.slot_icons        = {}
    hotbar.slot_recasts      = {}
    hotbar.slot_frames       = {}
    hotbar.slot_texts        = {}
    hotbar.slot_cost         = {}
    hotbar.slot_recast_texts = {}
    hotbar.slot_keys         = {}
	hotbar.number           = texts.new(table.copy(text_setup), true)
	setup_text(hotbar.number, theme_options)
	hotbar.number:text(tostring(number))
	if (theme_options.offsets[tostring(number)].Vertical == true) then
		hotbar.number:pos(get_slot_x(ui ,number, 0)+30, get_slot_y(ui, number, 0)+25)
	else
		hotbar.number:pos(get_slot_x(ui, number, 0)+30, get_slot_y(ui, number, 0))
	end
	hotbar.number:size(theme_options.font_size + 5)
	return hotbar
end

-- load the images and text
local function load(ui)
    -- create ui elements for hotbars
    for h=1,ui.theme.hotbar_number,1 do
        ui.hotbars[h] = init_hotbar(ui, ui.theme, h)
        for i=1, ui.theme.columns,1 do
            init_slot(ui, h, i, ui.theme)
        end
    end
	ui.action_info = texts.new()
	setup_action_info(ui.action_info, ui.theme)

    -- load feedback icon last so it stays above everything else
    setup_feedback(ui)
end

-- load action into a hotbar slot
local function load_action(ui, row, slot, action, player_vitals)

	local action_map = { ['ma'] = 'spells', ['ja'] = 'abilities'}
    local is_disabled = false

    clear_slot(ui, row, slot)

    -- if slot is empty, leave it cleared
    if action == nil then
        if ui.theme.hide_empty_slots == true then
            ui.hotbars[row].slot_backgrounds[slot]:hide()
            ui.hotbars[row].slot_keys[slot]:hide()
        else
            ui.hotbars[row].slot_backgrounds[slot]:show()
            ui.hotbars[row].slot_keys[slot]:show()
        end
	else
		-- if slot has a skill (ma, ja or ws)
		if S{'ma','ja'}:contains(action.type) then
			ui.hotbars[row].slot_backgrounds[slot]:alpha(200)
			local skill = nil
			local slot_image = nil
			if database[action.type][(action.action):lower()] ~= nil then
				skill = database[action.type][(action.action):lower()]
				ui.hotbars[row].slot_icons[slot]:path(windower.addon_path .. '/images/icons/' .. (string.format("%s/%05d", action_map[action.type], skill.icon)) .. '.png')
				if skill.mpcost ~= nil and skill.mpcost ~= 0 then
					if player_vitals.mp < tonumber(skill.mpcost) then
						ui.disabled_slots.no_vitals[action.action] = true
						is_disabled = true
					end
				-- display tp cost
				elseif skill.tpcost ~= nil and skill.tpcost ~= '0' then
					if player_vitals.tp < tonumber(skill.tpcost) then
						ui.disabled_slots.no_vitals[action.action] = true
						is_disabled = true
					end
				end
			end
			ui.hotbars[row].slot_icons[slot]:show()
		elseif action.type == 'ws' then
			ws = database[action.type][(action.action):lower()]
			setup_slot_icons(ui, '/images/icons/weapons/' .. string.format("%02d", ws.icon) .. '.jpg', row, slot)
		-- if action is an item/gearswap
		elseif S{'item','gs'}:contains(action.type) then
			setup_default_slot_icons(ui, action.type, row, slot)
		-- If no custom icon is defined, just put on a cog.
		else
			setup_default_slot_icons(ui, 'default', row, slot)
		end

		-- if action is custom
		if action.icon ~= nil then
			setup_slot_icons(ui, '/images/icons/custom/' .. action.icon .. '.png', row, slot)
		end

		-- check if action is on cooldown
		if ui.disabled_slots.on_cooldown[action.action] ~= nil then is_disabled = true end

		ui.hotbars[row].slot_frames[slot]:show()
		ui.hotbars[row].slot_texts[slot]:text(action.alias)

		-- hide elements according to settings
		if ui.theme.hide_action_names == true then 
			ui.hotbars[row].slot_texts[slot]:hide() 
		else 
			ui.hotbars[row].slot_texts[slot]:show() 
		end

		-- if slot is disabled, disable it
		if is_disabled == true then
			toggle_slot(ui, row, slot, false)
			ui.disabled_slots.actions[action.action] = true
		end
	end
end

function ui:update_inventory_count()
    if (self.is_setup == true) then
        if (self.theme.hide_inventory_count == false) then
            self.playerinv = windower.ffxi.get_items()
            get_inventory_count(self.theme, self.inventory_count, self.playerinv.inventory)
        end
    end
end

----------------------
-- Public Functions --
----------------------
function ui:change_image(environment, hotbar, slot)
end

function ui:setup(theme_options)
    database:import()
    self.theme = theme_options
	self.image_width    = math.floor(self.image_width * self.theme.slot_icon_scale)
	self.image_height   = math.floor(self.image_height * self.theme.slot_icon_scale)
	self.hover_icon = images.new(table.copy(images_setup, true))
    setup_image(self.hover_icon, windower.addon_path..'/images/other/square.png')
	self.hover_icon:hide()
	self.hover_icon:size(self.image_width+2, self.image_height+2)
	self.hover_icon.row = 0
	self.hover_icon.column = 0
    setup_metrics(self)
    setup_disabled_icons(self)
    load(self)
    self.is_setup = true
end

function ui:swap_icons(swap_table)
	local source_row  = swap_table.source.row
	local source_slot = swap_table.source.slot
	local dest_row    = swap_table.dest.row
	local dest_slot   = swap_table.dest.slot
	local tempPathSource = self.hotbars[source_row].slot_icons[source_slot]:path()
	local tempTextSource = self.hotbars[source_row].slot_texts[source_slot]:text()
	local tempPathDest   = self.hotbars[dest_row].slot_icons[dest_slot]:path()
	local tempTextDest   = self.hotbars[dest_row].slot_texts[dest_slot]:text()

	self.hotbars[dest_row].slot_texts[dest_slot]:text(tempTextSource)
	self.hotbars[dest_row].slot_icons[dest_slot]:path(tempPathSource)
	self.hotbars[source_row].slot_texts[source_slot]:text(tempTextDest)
	self.hotbars[source_row].slot_icons[source_slot]:path(tempPathDest)
end

-- hide all ui components
function ui:hide()
    self.battle_notice:hide()
    self.feedback_icon:hide()
    self.inventory_count:hide()
    if (self.active_environment ~= nil) then
        self.active_environment['battle']:hide()
        self.active_environment['field']:hide()

    end
    for h=1,self.theme.hotbar_number,1 do
		self.hotbars[h].number:hide()
        for i=1, self.theme.columns, 1 do
            self.hotbars[h].slot_backgrounds[i]:hide()
            self.hotbars[h].slot_icons[i]:hide()
            self.hotbars[h].slot_frames[i]:hide()
            self.hotbars[h].slot_recasts[i]:hide()
            self.hotbars[h].slot_texts[i]:hide()
            self.hotbars[h].slot_cost[i]:hide()
            self.hotbars[h].slot_recast_texts[i]:hide()
            self.hotbars[h].slot_keys[i]:hide()
        end
    end
end

function ui:hide_hover()
	self.hover_icon:hide()
	self.action_info:hide()
end

-- show ui components
function ui:show(player_hotbar, environment)
    if (self.active_environment ~= nil) then
        self.active_environment['battle']:show()
        self.active_environment['field']:show()
    end

    self.inventory_count:show()

    for h=1,self.theme.rows,1 do
        for i=1, self.theme.columns, 1 do
            local slot = i
			pos_x, pos_y = self.hotbars[h].slot_recasts[i]:pos()

            local action = player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]

            self.hotbars[h].slot_icons[i]:show()
			self.hotbars[h].number:show()
            if action ~= nil then self.hotbars[h].slot_frames[i]:show() end
            if self.theme.hide_empty_slots == false then self.hotbars[h].slot_backgrounds[i]:show() end
            if self.theme.hide_recast_animation == false then self.hotbars[h].slot_recasts[i]:show() end
            if self.theme.hide_action_names == false then self.hotbars[h].slot_texts[i]:show() end
            if self.theme.hide_recast_text == false then self.hotbars[h].slot_recast_texts[i]:show() end
            if self.theme.hide_empty_slots == false then self.hotbars[h].slot_keys[i]:show() end
        end
    end
end

----------------
-- Actions UI --
----------------

-- load player hotbar
function ui:load_player_hotbar(player_hotbar, environment, player_vitals)
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
			load_action(self, h, i, player_hotbar[environment]['hotbar_' .. h]['slot_' .. i], player_vitals)
        end
    end
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

local function check_disable(database, action)
	local disabled = false
	if (is_neutralized == true) then 
		disabled = true
	elseif (action ~= nil) then
		if (action.type == 'ma' and database[action.type][(action.action):lower()] ~= nil) then
			if (database[action.type][(action.action):lower()].mp ~= nil and current_mp < database[action.type][(action.action):lower()].mp) then
				is_silenced = true 
			end
		else 
			is_silenced = false 
		end
		if (is_silenced == true and action.type == 'ma') then 
			disabled = true 
		elseif (is_amnesiad == true and (action.type == 'ja' or action.type == 'ws')) then 
			disabled = true 
		elseif (action.type == 'ws' and can_ws == false) then
			disabled = true
		end
	end
	return disabled
end

function ui:inner_check_recasts(player_hotbar, environment, player_vitals, row, slot)
	local action = player_hotbar[environment]['hotbar_' .. row]['slot_' .. slot]
	local is_disabled = check_disable(database, action)
	if (action ~= nil and is_disabled == true) then 
		disable_slot(self, row, slot, action)
	elseif action == nil  then
		if (self.theme.hide_empty_slots == true) then
			hide_recast(self, row, slot)
		else
			clear_recast(self, row, slot)
		end
	elseif (S{'ma','ja','ws'}:contains(action.type)) then
		local skill = nil
		local action_recasts = nil
		local in_cooldown = false
		local is_in_seconds = false

		-- if its magic, look for it in spells
		if (action.type == 'ja' or action.type == 'ma') and database[action.type][(action.action):lower()] ~= nil then
			skill = database[action.type][(action.action):lower()]
			action_recasts = self.recasts[action.type]
		end

		-- check if skill is in cooldown
		if skill ~= nil and action_recasts[tonumber(skill.icon)] ~= nil and action_recasts[tonumber(skill.icon)] > 0 then
			-- register first cooldown to calculate percentage
			if self.disabled_slots.on_cooldown[action.action] == nil then
				self.disabled_slots.on_cooldown[action.action] = action_recasts[tonumber(skill.icon)]

				-- setup recast elements
				self.hotbars[row].slot_recasts[slot]:path(windower.addon_path..'/images/other/black-square.png')
			end

			in_cooldown = true
		end

		if in_cooldown == true then
			-- disable slot if it's not disabled
			if self.disabled_slots.actions[action.action] == nil then
				self.disabled_slots.actions[action.action] = true
				toggle_slot(self, row, slot, false)
				self.disabled_icons[row][slot] = 1
			else
				self.disabled_icons[row][slot] = 1
			end

			-- show recast animation
			local recast_time = calc_recast_time(action_recasts[tonumber(skill.icon)], action.type)

			in_cooldown = true

			self.hotbars[row].slot_recasts[slot]:show()
			self.hotbars[row].slot_recast_texts[slot]:text(recast_time)
			self.hotbars[row].slot_recast_texts[slot]:show()
			self.hotbars[row].slot_keys[slot]:hide()
		else
			self.disabled_icons[row][slot] = 0
			clear_recast(self, row, slot)

			if self.disabled_slots.on_cooldown[action.action] == true then
				self.disabled_slots.on_cooldown[action.action] = nil
			end

			-- if it's not disabled by vitals nor cooldown, enable slot
			if self.disabled_slots.actions[action.action] == true and self.disabled_slots.no_vitals[action.action] == nil then
				self.disabled_slots.actions[action.action] = nil
				toggle_slot(self, row, slot, true)
			end
		end
	-- if skill is in cooldown
	else
		clear_recast(self, row, slot)
	end
end

-- check action recasts
function ui:check_recasts(player_hotbar, environment, player_vitals )
    ui.recasts['ja'] = windower.ffxi.get_ability_recasts()
    ui.recasts['ma'] = windower.ffxi.get_spell_recasts()
    for h=1, self.theme.rows, 1 do
        for i=1, self.theme.columns, 1 do
			self:inner_check_recasts(player_hotbar, environment, player_vitals, h, i)
        end
    end
end

function ui:check_hover()

    local disabled_opacity = self.theme.disabled_slot_opacity
    local enabled_opacity  = 200
    local row              = self.hover_icon.row
    local col              = self.hover_icon.col
    local prev_col         = self.hover_icon.col
    local prev_row         = self.hover_icon.row

    if (row ~= nil and col ~= nil) then
        if (self.disabled_icons[row][col] == 0) then
            self.hotbars[row].slot_icons[col]:alpha(disabled_opacity)
            prev_row, prev_col = row, col
        end
    elseif(prev_row ~= nil and prev_col ~= nil) then
        if (self.disabled_icons[prev_row][prev_col] == 1) then
            opacity = disabled_opacity
        else
            opacity = enabled_opacity
        end
        self.hotbars[prev_row].slot_icons[prev_col]:alpha(opacity)
        prev_col = nil
        prev_row = nil
    end

    self.prev_col       = prev_col
    self.prev_row       = prev_row
    self.hover_icon.row = row
    self.hover_icon.col = col
end

-----------------
-- Feedback UI --
-----------------

-- trigger feedback visuals in given hotbar and slot
function ui:trigger_feedback(row, slot)
    --if slot == 0 then slot = 10 end

    self.feedback_icon:pos(get_slot_x(self, row, slot), get_slot_y(self, row, slot))
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

    local row = nil
    local slot = nil
    local found = false

	local pos_x
    local pos_y
	local debug_msg
	local off_x
	local off_y
	local found = false
	pos_x = self.active_environment['battle']:pos_x()
	pos_y = self.active_environment['battle']:pos_y() - 60
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
				pos_x = get_slot_x(self, h, i)
				pos_y = get_slot_y(self, h, i)
				off_x = pos_x + self.image_width
				off_y = pos_y + self.image_height

				if  ((pos_x <= x and x <= off_x) or (pos_x >= x and x >= off_x))
				and ((pos_y <= y and y <= off_y) or (pos_y >= y and y >= off_y)) 
				then
					row, slot, found = h, i, true
					break
				end
			end

			if (found == true) then
				break
			end
		end
	end

    return row, slot
end

function ui:light_up_action(x, y, row, column, player_hotbar, environment, vitals)
	local icon_x = get_slot_x(self, row, column)
	local icon_y = get_slot_y(self, row, column)
	self.hover_icon:pos(icon_x-1, icon_y-1)
	self.hover_icon:alpha(255)
	self.hover_icon:show()
	local action = player_hotbar[environment]['hotbar_' .. row]['slot_' .. column]
	if (self.theme.show_description == true and action ~= nil) then
		if (S{'ma', 'ja', 'ws'}:contains(action.type)) then
			if (self.current_row ~= row or self.current_column ~= column) then
				local text_msg = ""
				local line_space = 6
				if (action.type == "ma") then
					text_msg = formatter.format_spell_info(database, action.action, action.target)
					self.action_info:text(text_msg)
				elseif (action.type == "ja") then
					text_msg = formatter.format_ability_info(database, action.action, action.target)
					self.action_info:text(text_msg)
				elseif (action.type == "ws") then
					text_msg = formatter.format_ws_info(database, action.action, action.target)
					self.action_info:text(text_msg)
				end
				local _, count = text_msg:gsub('\n', '\n') 
				count = count + 1
				self.current_text_size = ((self.action_info:size()+line_space)*count + line_space)
				self.action_info:alpha(255)
				self.action_info:pos(x+ui.image_width, y)
				self.current_row = row
				self.current_column = column
			end
				if ((ui.scaled_pos_y - y) < self.current_text_size) then
					self.action_info:pos(x+ui.image_width, y-self.current_text_size)
				else
					self.action_info:pos(x+ui.image_width, y)
				end
				self.action_info:show()
		else
			self.action_info:hide()
		end
	end
end

function ui:move_icons(moved_row_info)

	local off_x = moved_row_info.pos_x
	local off_y = moved_row_info.pos_y
	local r = moved_row_info.box_index
	self.theme.offsets[tostring(r)].OffsetX = off_x
	self.theme.offsets[tostring(r)].OffsetY = off_y
	for i=1,self.theme.columns,1 do
		local x = get_slot_x(self, r, i)
		local y = get_slot_y(self, r, i)
		self.hotbars[r].slot_icons[i]:pos(x, y)
		self.hotbars[r].slot_frames[i]:pos(x, y)
		self.hotbars[r].slot_recasts[i]:pos(x, y)
		self.hotbars[r].slot_backgrounds[i]:pos(x, y)
		self.hotbars[r].slot_recast_texts[i]:pos(x, y)
		self.hotbars[r].slot_texts[i]:pos(x, y + ui.image_height -12)
		self.hotbars[r].slot_keys[i]:pos(x, y)
	end
	if (self.theme.offsets[tostring(r)].Vertical == true) then
		self.hotbars[r].number:pos(get_slot_x(self, r, 0)+30, get_slot_y(self, r, 0)+25)
	else
		self.hotbars[r].number:pos(get_slot_x(self, r, 0)+30, get_slot_y(self, r, 0))
	end
	if (r == self.theme.environment.hook_onto_bar) then
		local env_pos_x = ui:get_slot_x(self, self.theme.environment.hook_onto_bar, self.theme.columns+1) - 10
		local env_pos_y = ui:get_slot_y(self, self.theme.environment.hook_onto_bar, 0)

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
