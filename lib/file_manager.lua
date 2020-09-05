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

local file_manager = {}

local current_job_file_path = ""
local current_general_file_path = ""


local function fill_table(file)
	file_content = {}
	for line in file:lines() do
		table.insert (file_content, line)
	end
	return file_content
end

function file_manager:update_file_path(player_name, player_job)
	local basepath = windower.addon_path .. 'data/'..player_name..'/'
	local job_name = player_job
	current_job_file_path = basepath .. job_name .. '.lua'
	current_general_file_path = basepath .. "General.lua"
end

function file_manager:insert_action(action, prio, player_subjob, environment, row, slot)

	local row_to_find = string.format('%s %d %d', environment, row, slot)
	local found_row = false
	local fileContent = {}

	local file = io.open(current_job_file_path , 'r')

	local found_in_main = false
	local found_in_sub = false
	local found_main_job_start = false
	local found_main_job_end = false
	local found_sub_job_start = false
	local found_sub_job_end = false

	local subjob_start  = 0
	local subjob_end    = 0
	local mainjob_start = 0
	local mainjob_end   = 0
	local general_start = 0
	local general_end   = 0

	if (file ~= nil) then
		fileContent = fill_table(file)
		if (prio == 'm') then
			for key, val in pairs(fileContent) do
				log(fileContent[key])
				local i, j = string.find(val, 'xivhotbar_keybinds_job%[\'Base\'%]')
				if (i ~= nil and j ~= nil) then
					found_main_job_start = true
					mainjob_start = key + 1
				end
				local k, l = string.find(val, '^}')
				if (k ~= nil and l ~= nil and found_main_job_start == true) then
					mainjob_end = key -1
					found_main_job_end = true 
					break
				end
			end
			if (found_main_job_end == true) then
				for i = mainjob_start,mainjob_end do
					local k, j = string.find(fileContent[i], '\'')
					if (k ~= nil and j ~= nil) then

						local found_row = string.match(fileContent[i], environment ..' ' .. row .. ' ' .. slot)
						if (found_row ~= nil) then
							found_in_main = true
							break
						end
					end
				end
				if (found_in_main == false) then
					new_row = "\t{'" .. row_to_find .. "', '" .. action.type .. "', '" .. action.action .. "', '" .. action.target .. "', '" .. action.alias .. "'},"
					log(string.format("New row: %s" ,new_row))
					log(string.format("Mainjob_end: %d" , mainjob_end))
					table.insert(fileContent, mainjob_end+1, new_row)
					io.close(file)
					file = io.open(current_job_file_path, 'w')
					for index, value in ipairs(fileContent) do
						--log(value)
						file:write(value..'\n')
					end
					io.close(file)
				end
			end
		elseif (prio == 's') then
			for key, val in pairs(fileContent) do
				local i, j = string.find(val, 'xivhotbar_keybinds_job%[\'' .. player_subjob .. '\'%]')
				if (i ~= nil and j ~= nil) then
					found_sub_job_start = true
					subjob_start = key + 1
				end
				local k, l = string.find(val, '^}')
				if (k ~= nil and l ~= nil and found_sub_job_start == true) then
					subjob_end = key -1
					found_sub_job_end = true 
					break
				end
			end
			if (found_sub_job_end == true) then
				for i = subjob_start,subjob_end do
					local k, j = string.find(fileContent[i], '\'')
					if (k ~= nil and j ~= nil) then

						local found_row = string.match(fileContent[i], environment ..' ' .. row .. ' ' .. slot)
						if (found_row ~= nil) then
							found_in_sub = true
							break
						end
					end
				end
				if (found_in_sub == false) then
					new_row = "\t{'" .. row_to_find .. "', '" .. action.type .. "', '" .. action.action .. "', '" .. action.target .. "', '" .. action.alias .. "'},"
					log(string.format("New row: %s" ,new_row))
					log(string.format("subjob_end: %d" , subjob_end))
					table.insert(fileContent, subjob_end+1, new_row)
					io.close(file)
					file = io.open(current_job_file_path, 'w')
					for index, value in ipairs(fileContent) do
						--log(value)
						file:write(value..'\n')
					end
					io.close(file)
				end
			end
		end
	end
end


local function find_in_file_remove(file_path, action, row, slot, environment)

	log("Removing!")
	local testAc = action.action:lower()
	local row_to_find = string.format('%s %d %d', environment, row, slot)
	local found_row = false
	local fileContent = {}
	local file = io.open(file_path , 'r')

	if (file ~= nil) then
		for line in file:lines() do
			table.insert (fileContent, line)
		end
		for key, val in pairs(fileContent) do
			if (val:contains(row_to_find)) then
				if (val:lower():contains(testAc)) then
					found_row = true
					if (debug == true) then
						print("[file_manager:find_in_file_remove] val:lower():contains(testAc) succeeded")
						print(val)
					end
					fileContent[key] = '0'
					break
				elseif (val:contains("'gs'")) then
					local stripped_row = val:lower()
					i, j = string.find(stripped_row, '%[.*%]')
					k, l = string.find(testAc, '%[.*%]')
					local sub_row = string.sub(stripped_row, i+3, j-3)
					local sub_ac = string.sub(testAc, k+2, l-2)
					if sub_row == sub_ac then
						if (debug == true) then
							print("[file_manager:find_in_file_remove] sub_row == sub_ac succeeded")
							print(val)
						end
						found_row = true
						fileContent[key] = '0'
						break
					end
				end
			end
		end
		if(found_row == true) then
			file = io.open(file_path, 'w')
			for index, value in ipairs(fileContent) do
				if (value ~= '0') then
					file:write(value..'\n')
				end
			end
			io.close(file)
		end
	end
	return found_row
end

local function find_in_file(file_location, action, d_row, d_slot, s_row, s_slot, environment)

	local testAc = action.action:lower()
	local row_to_find = string.format('%s %d %d', environment, s_row, s_slot)
	local new_row = string.format('%s %d %d', environment, d_row, d_slot)
	local found_row = false
	local fileContent = {}
	local file = io.open(file_location , 'r')

	if (file ~= nil) then
		for line in file:lines() do
			table.insert (fileContent, line)
		end
		for key, val in pairs(fileContent) do
			if (val:contains(row_to_find)) then
				if (debug == true) then
					print("Found the row")
				end
				if (val:lower():contains(testAc)) then
					found_row = true
					val = string.gsub(val, "%w %d %d+", new_row)
					if (debug == true) then
						print("val:lower():contains(testAc) succeeded")
						print(val)
					end
					fileContent[key] = val
					break
				elseif string.find(val, "'%f[%a]gs%f[%A]'") and string.find(val, 'equip') then
					local stripped_row = val:lower()
					print("This is a gearswap row.")
					print(val)
					i, j = string.find(stripped_row, '%[.*%]')
					k, l = string.find(testAc, '%[.*%]')
					local sub_row = string.sub(stripped_row, i+3, j-3)
					local sub_ac = string.sub(testAc, k+2, l-2)
					if sub_row == sub_ac then
						found_row = true
						val = string.gsub(val, "%w %d %d+", new_row)
						if (debug == true) then
							print("sub_row == sub_ac succeeded")
							print(val)
						end
						fileContent[key] = val
						break
					end
				end
			end
		end
		if(found_row == true) then
			file = io.open(file_location, 'w')
			for index, value in ipairs(fileContent) do
				file:write(value..'\n')
			end
			io.close(file)
		end
	end
	return found_row
end

function file_manager:write_changes(action, d_row, d_slot, s_row, s_slot, environment)

	if (debug == true) then
		print("file_manager:write_changes was called")
	end

	local found_row = find_in_file(current_job_file_path, action, d_row, d_slot, s_row, s_slot, environment)

	if (found_row == false) then
		find_in_file(current_general_file_path, action, d_row, d_slot, s_row, s_slot, environment)
	end
end

function file_manager:write_remove(action, row, slot, environment)
	if (debug == true) then
		print("file_manager:write_remove was called")
	end

	local found_row = find_in_file_remove(current_job_file_path, action, row, slot, environment)

	if (found_row == false) then
		find_in_file_remove(current_general_file_path, action, row, slot, environment)
	end
end

function file_manager:write_changes(action, d_row, d_slot, s_row, s_slot, environment)

	if (debug == true) then
		print("file_manager:write_changes was called")
	end

	local found_row = find_in_file(current_job_file_path, action, d_row, d_slot, s_row, s_slot, environment)

	if (found_row == false) then
		find_in_file(current_general_file_path, action, d_row, d_slot, s_row, s_slot, environment)
	end
end

return file_manager
