--[[
        Copyright © 2020, Akirane
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
