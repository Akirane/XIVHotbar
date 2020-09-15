local text_formatter = {}
local white = '\\cs(255,255,255)'


local function split_string (input_str)
	local t={}
	for str in string.gmatch(input_str, "([^ ]+)") do
		table.insert(t, str)
	end
	return t
end


local function format_description(desc)
	temp_str = ""
	formatted_desc = ""
	teststr = split_string(desc)
	for k,v in pairs(teststr) do 
		if (string.len(temp_str) > 30) then
			formatted_desc = formatted_desc .. " ".. temp_str .. "\n"
			temp_str = ""
		end
		temp_str = temp_str .. " " .. v
	end
	formatted_desc = formatted_desc .. " " .. temp_str .. "\n"
	return formatted_desc
end


function text_formatter.format_ws_info(database, action, action_target)
	local string_return = ""
	
	if database.ws[(action):lower()] ~= nil then
		local ws = database.ws[(action):lower()]
		local ws_info = {}
		ws_info[1] = string.format("\\cs(255,255,0)[%s]\\cr    \\cs(200,200,255)Target:<%s>\\cr\n", ws.name, action_target) 

		local function generate_string(ws_string)
			local return_string = ""
			if (ws_string ~= nil) then 
				return_string = string.format("%s%s%s", database:get_element_color_name(ws_string), ws_string, white)
			else
				return_string = nil
			end
			return return_string
		end
		sc_info = {}
		sc_info.sc_a = generate_string(ws.sc_a) 
		sc_info.sc_b = generate_string(ws.sc_b) 
		sc_info.sc_c = generate_string(ws.sc_c) 

		ws_info[2] = format_description(ws.desc)
		temp_ws_str = table.concat(sc_info, ", ")
		if (temp_ws_str ~= "") then
			ws_info[3] = "SC: " .. table.concat(sc_info, ", ")
		else
			ws_info[3] = "SC: None"
		end
		if (ws.range == 255) then
			ws_info[4] = "Range: \\cs(200,200,255)Self\\cr "
		else
			ws_info[4] = string.format("Range: \\cs(200,200,255)%.1fy\\cr", ws.range)
		end
		string_return = table.concat(ws_info, "\n")
	end
	return string_return
end


function text_formatter.format_ability_info(database, action, action_target)
	local string_return = ""
	
	if database.ja[(action):lower()] ~= nil then
		local ability = database.ja[(action):lower()]
		local ability_info = {}
		ability_info[1] = string.format("\\cs(255,255,0)[%s]\\cr    Target:\\cs(200,200,255)<%s>\\cr\n", ability.name, action_target) 
		ability_info[2] = format_description(ability.desc)
		if (ability.range == 255) then
			ability_info[3] = "Range: \\cs(200,200,255)Self\\cr "
		else
			ability_info[3] = string.format("Range: \\cs(200,200,255)%.1fy\\cr", ability.range)
		end
		string_return = table.concat(ability_info, " \n")
	end
	return string_return
end


function text_formatter.format_spell_info(database, action, action_target)
	local string_return = ""
	
	if database.ma[(action):lower()] ~= nil then
		local spell = database.ma[(action):lower()]
		local spell_info = {}
		spell_info[1] = string.format("\\cs(255,255,0)[%s]\\cr   Target:\\cs(200,200,255)<%s>\\cr\n", database.ma[(action):lower()].name, action_target) 
		spell_target_cost = {}
		if (spell.range == 255) then
			spell_target_cost[1] = "Range: \\cs(200,200,255)Self\\cr "
		else
			spell_target_cost[1] = string.format("Range: \\cs(200,200,255)%.1fy\\cr", spell.range)
		end
		spell_info[2] = format_description(spell.desc)
		if (database.ma[(action):lower()].mpcost ~= 0) then
			spell_target_cost[2] = string.format("MP Cost: \\cs(0,255,0)%sMP\\cr", database.ma[(action):lower()].mpcost) 
		end
		spell_info[3] = table.concat(spell_target_cost, "    ")
		string_return = table.concat(spell_info, "\n")
	end
	return string_return
end


return text_formatter
