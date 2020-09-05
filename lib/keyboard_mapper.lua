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

local keyboard = {}

keyboard.hotbar_rows = require('../data/keybinds')
keyboard.parsed_keybinds = {}

--[[ 
	Parse Keybinds: 

	Description:
		Converts the keybinds in data/keybinds.lua into an input which can be used for
		binding keys with Windower.
	Legends:
		1. %: Keybinding is only registered when the chat window is *not* open
		2. ^: CTRL
		3. !: Alt
		4. ~: Shift
		For example: "%~1" means "Shift+1" when chat window is not active.
--]]
--


function keyboard:parse_keybinds()
	for row_key,row_value in pairs(keyboard.hotbar_rows) do
		for col_key,col_value in pairs(row_value) do
			col_value = string.lower(col_value)
			col_value = string.gsub(col_value, " ", "")
			col_list = string.split(col_value, "+")
			if table.getn(col_list) ~= 1 then
				for string_value in ipairs(col_list) do
					--print("string_value: " ..col_list[string_value])
					if (col_list[string_value] ~= "number") then
						if(col_list[string_value]:contains("ctrl")) then
							col_list[string_value] = "^"
						elseif(col_list[string_value]:contains("shift")) then
							col_list[string_value] = "%~"
						elseif(col_list[string_value]:contains("alt")) then
							col_list[string_value] = "!"
						end
					end
				end
				col_value = table.concat((col_list), "")
			else
				if type(col_list[1]) == "number" then
					col_value = "%" ..tostring(col_list[1])
				else 
					col_value = "%" .. col_value
				end
			end
			row_value[col_key] = col_value
		end
		keyboard.hotbar_rows[row_key] = row_value
	end
end

-- bind keys --
function keyboard:bind_keys(rows, columns)
    for r = 1, rows do 
        for s = 1, columns do
            if (self.hotbar_rows[r] ~= nil and self.hotbar_rows[r][s] ~= nil) then 
    			windower.send_command('bind '..keyboard.hotbar_rows[r][s]..' htb execute '..r..' '..s)
            end
        end
    end
end

function keyboard:unbind_keys(rows, columns)
    for r = 1, rows do 
        for s = 1, columns do
            if (keyboard.hotbar_rows[r] ~= nil and keyboard.hotbar_rows[r][s] ~= nil) then 
    			windower.send_command('unbind '..keyboard.hotbar_rows[r][s])
            end
        end
    end
end

return keyboard
