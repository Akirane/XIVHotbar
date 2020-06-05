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

local keyboard = {}

-- Legends:
-- %: Keybinding is only registered when the chat window is *not* open
-- ^: CTRL
-- !: Alt
-- ~: Shift
-- For example: "%~1" means "Shift+1" when chat window is not active.

keyboard.parsed_keybinds = {}

-- TODO Delete old binds
function keyboard:save_current_keybinds()
	local file_location = windower.addon_path .. "data/old_keybinds.txt"
	local file = io.open(file_location, "w"):close()
    file = io.open(file_location, "a")
	for row_key,row_value in pairs(keyboard.hotbar_rows) do
		file:write(table.concat(row_value, ",") .. "\n")
	end
	file:close()
end

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
			--col_value = "%" .. col_value
			row_value[col_key] = col_value
			--print(col_value)
		end
		keyboard.hotbar_rows[row_key] = row_value
	end
	keyboard:save_current_keybinds()
end



keyboard.hotbar_rows = {
	-- Hotbar Row #1
	{
	    '1',          -- Hotbar Row #1 Col #1
	    '2',          -- Hotbar Row #1 Col #2
	    '3',          -- Hotbar Row #1 Col #3
	    'ALT + Q',    -- Hotbar Row #1 Col #4
	    '5',          -- Hotbar Row #1 Col #5
	    '6',          -- Hotbar Row #1 Col #6
	    '7',          -- Hotbar Row #1 Col #7
	    '8',          -- Hotbar Row #1 Col #8
	    '9',          -- Hotbar Row #1 Col #9
	    'O'           -- Hotbar Row #1 Col #0
	},
	-- Hotbar Row #2
	{
		'ALT + Y',    -- Hotbar Row #2 Col #1
		'E',          -- Hotbar Row #2 Col #2
		'ALT + E',    -- Hotbar Row #2 Col #3
		'Q',          -- Hotbar Row #2 Col #4
		'ALT + K',    -- Hotbar Row #2 Col #5
		'T',          -- Hotbar Row #2 Col #6
		'ALT + U',    -- Hotbar Row #2 Col #7
		'CTRL + O',   -- Hotbar Row #2 Col #8
		'ALT + M',    -- Hotbar Row #2 Col #9
		'CTRL + M'    -- Hotbar Row #2 Col #0
	},
	-- Hotbar Row #3
	{
	    'CTRL + 1',   -- Hotbar Row #3 Col #1
	    'CTRL + 2',   -- Hotbar Row #3 Col #2
	    'CTRL + 3',   -- Hotbar Row #3 Col #3
	    'CTRL + 4',   -- Hotbar Row #3 Col #4
	    'CTRL + 5',   -- Hotbar Row #3 Col #5
	    'CTRL + 6',   -- Hotbar Row #3 Col #6
	    'CTRL + 7',   -- Hotbar Row #3 Col #7
	    'CTRL + 8',   -- Hotbar Row #3 Col #8
	    'CTRL + 9',   -- Hotbar Row #3 Col #9
	    'CTRL + 0'    -- Hotbar Row #3 Col #0
	},
	-- Hotbar Row #4
	{
	    'Shift + 1', -- Hotbar Row #4 Col #1
	    'Shift + 2', -- Hotbar Row #4 Col #2
	    'Shift + 3', -- Hotbar Row #4 Col #3
	    'Shift + 4', -- Hotbar Row #4 Col #4
	    'Shift + Q', -- Hotbar Row #4 Col #5
	    'Shift + E', -- Hotbar Row #4 Col #6
	    'Shift + R', -- Hotbar Row #4 Col #7
	    'Shift + T', -- Hotbar Row #4 Col #8
	    'Shift + C', -- Hotbar Row #4 Col #9
	    'Shift + F'  -- Hotbar Row #4 Col #0
	},
	-- Hotbar Row #5
	{
	    'ALT + 1',    -- Hotbar Row #5 Col #1
	    'ALT + 2',    -- Hotbar Row #5 Col #2
	    'ALT + 3',    -- Hotbar Row #5 Col #3
	    'ALT + 4',    -- Hotbar Row #5 Col #4
	    'ALT + 5',    -- Hotbar Row #5 Col #5
	    'ALT + 6',    -- Hotbar Row #5 Col #6
	    'ALT + 7',    -- Hotbar Row #5 Col #7
	    'ALT + 8',    -- Hotbar Row #5 Col #8
	    'ALT + 9',    -- Hotbar Row #5 Col #9
	    'ALT + 0'     -- Hotbar Row #5 Col #0
	}
}

keyboard.less_great = -1
keyboard.esc = 1
keyboard.key_1 = 2
keyboard.key_2 = 3
keyboard.key_3 = 4
keyboard.key_4 = 5
keyboard.key_5 = 6
keyboard.key_6 = 7
keyboard.key_7 = 8
keyboard.key_8 = 9
keyboard.key_9 = 10
keyboard.key_0 = 11
keyboard.underscore = 12

keyboard.q = 16
keyboard.w = 17
keyboard.e = 18
keyboard.r = 19

keyboard.o = 24

keyboard.c = 46

keyboard.enter = 28
keyboard.ctrl = 29

keyboard.shift = 42
keyboard.backslash = 43
keyboard.comma = 51
keyboard.period = 52
keyboard.alt = 56

keyboard.up = 200
keyboard.down = 208
keyboard.left = 203
keyboard.right = 205
-- End of unused content



return keyboard
