icon = {}
icon.theme = {}
icon.width = 40
icon.height = 40

function icon:init(theme_options)
	self.theme = theme_options
	self.width = math.floor(self.width * self.theme.slot_icon_scale)
	self.height = math.floor(self.height * self.theme.slot_icon_scale)
end

function icon:get_width()
	return self.width
end

function icon:get_height()
	return self.height
end

-- get x position for a given hotbar and slot
function icon:get_slot_x(h, i)
	local x
	if (self.theme.offsets[tostring(h)] ~= nil) then
		if (self.theme.offsets[tostring(h)].Vertical == true) then
			if (i < math.floor(self.theme.columns / 2)+1) then
				x = self.theme.offsets[tostring(h)].OffsetX 	
			else
				x = self.theme.offsets[tostring(h)].OffsetX + (self.width + self.theme.slot_spacing) 	
			end
		else
			x =  self.theme.offsets[tostring(h)].OffsetX + ((self.width + self.theme.slot_spacing) * (i - 1))
		end
	else
		x =  ((self.width + self.slot_spacing) * (i - 1))
	end
	return x
end

-- get y position for a given hotbar and slot
function icon:get_slot_y(h, i)
	local y
	if (self.theme.offsets[tostring(h)] ~= nil) then
		if (self.theme.offsets[tostring(h)].Vertical == true) then
			if (i < math.floor(self.theme.columns / 2)+1) then
				y =  self.theme.offsets[tostring(h)].OffsetY + ((self.width + self.theme.slot_spacing) * (i - 1))
			else
				y =  self.theme.offsets[tostring(h)].OffsetY + ((self.width + self.theme.slot_spacing) * (i - math.floor(self.theme.columns / 2) - 1))
			end
		else
			y = self.theme.offsets[tostring(h)].OffsetY 	
		end
	else
		y = - (((h - 1) * (self.theme.hotbar_spacing-3)))
	end
    return y 
end
return icon
