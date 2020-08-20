local move_boxes = {}

local box_config = {
	count = 0,
	boxes = {},
	sub_config = {}
}

local icon_height = 40
local icon_width = 40
local vert_cols = 2

local images_setup = {
    draggable = false,
    size = {
        width  = 10,
        height = 100 
    },
	pos = {
		x = 100,
		y = 100
	},
    texture = {
        fit = false 
    },
    visible = true,
}

local private_boxes = {
	pos = {
		x = 0,
		y = 0
	},
	size = {
		x = 0,
		y = 0
	}
}


local function compute_size(box, sub_conf, theme_options, is_vertical)

	if (is_vertical == true) then
		local t_width  = 2 * (icon_width + theme_options.slot_spacing) - theme_options.slot_spacing
		local t_height = (icon_height + theme_options.slot_spacing) * ( theme_options.columns / 2) - theme_options.slot_spacing
		sub_conf.width = t_width
		sub_conf.height = t_height
		box:size(t_width, t_height)
	else
		local t_height = (icon_width + theme_options.slot_spacing) - theme_options.slot_spacing
		local t_width  = (icon_height + theme_options.slot_spacing) * theme_options.columns  - theme_options.slot_spacing
		sub_conf.width = t_width
		sub_conf.height = t_height
		box:size(t_width, t_height)
	end
end


function move_boxes:init(theme_options)
	box_config.count = theme_options.rows
	for i=1,box_config.count do
		box_config.boxes[i] = images.new(table.copy(images_setup, true))
		local offset = theme_options.offsets[tostring(i)]
		box_config.sub_config[i] = {}
		compute_size(box_config.boxes[i], box_config.sub_config[i], theme_options, offset.Vertical)
		box_config.boxes[i]:pos(offset.OffsetX, offset.OffsetY)

		local x, y = box_config.boxes[i]:pos()
		box_config.sub_config[i].pos_x = x
		box_config.sub_config[i].pos_y = y
		box_config.boxes[i]:path(windower.addon_path..'/images/other/move.png')
		box_config.boxes[i]:alpha(128)
	end
end


function move_boxes:enable()
	for i=1,box_config.count do
		box_config.boxes[i]:show()
	end
end


function move_boxes:disable()
	for i=1,box_config.count do
		box_config.boxes[i]:hide()
	end
end

move_boxes.moved_box_info = {
	pos_x = 0,
	pos_y = 0,
	box_index = 0,
	is_active = false
}

--local box_clicked = 0

function move_boxes:get_pos(row)
	return box_config.boxes[row]:pos()
end

function move_boxes:get_move_box_info()
	return self.moved_box_info
end

local function determine_box(x, y)
	box_clicked = nil
	for i=1,box_config.count,1 do
		local pos_x, pos_y = box_config.boxes[i]:pos()
		local width, height = box_config.boxes[i]:size()
		local off_x = width  + pos_x
		local off_y = height  + pos_y
		if  ((pos_x <= x and x <= off_x) or (pos_x >= x and x >= off_x))
		and ((pos_y <= y and y <= off_y) or (pos_y >= y and y >= off_y)) 
		then
			box_clicked = i
			--box_config.boxes[i]:draggable(true)
			break
		end
	end
	return box_clicked
end

function move_boxes:move_hotbars(type, x, y, delta, blocked)

	local offset = 10
	return_value = nil
	if type == 1 then -- Mouse left click
		box_clicked = determine_box(x, y)
		if (box_clicked ~= nil) then
			self.moved_box_info.box_index = box_clicked
			local pos_x, pos_y = box_config.boxes[self.moved_box_info.box_index]:pos()
			self.moved_box_info.pos_y = pos_y 
			self.moved_box_info.pos_x = pos_x
			self.moved_box_info.is_active = true
			return true
		end
	elseif type == 2 then -- Mouse left release
		if(self.moved_box_info.is_active == true and box_clicked ~= nil) then
			self.moved_box_info.box_index = 0
			self.moved_box_info.is_active = false
			return true
		end
		return false
	elseif type == 0 then -- Mouse move
		if (self.moved_box_info.is_active == true) then
			local pos_x, pos_y = box_config.boxes[self.moved_box_info.box_index]:pos()
			local new_x, new_y = 0, 0
			if (math.abs(x-pos_x) >= offset) then
				new_x = pos_x-(pos_x%10)+((math.floor((x-pos_x)/offset)*offset))
			else
				new_x = pos_x
			end
			if (math.abs(y-pos_y) >= offset) then
				new_y = pos_y-(pos_y%10)+(math.floor((y-pos_y)/offset)*offset)
			else
				new_y = pos_y
			end
			--local pos_x, pos_y = box_config.boxes[self.moved_box_info.box_index]
			box_config.boxes[self.moved_box_info.box_index]:pos_x(new_x)
			box_config.boxes[self.moved_box_info.box_index]:pos_y(new_y)
			self.moved_box_info.pos_y = new_y 
			self.moved_box_info.pos_x = new_x
			return false
		end
	end
end


return move_boxes
