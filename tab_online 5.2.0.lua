--Minetest
--Copyright (C) 2014 sapier
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU Lesser General Public License as published by
--the Free Software Foundation; either version 2.1 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Lesser General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--------------------------------------------------------------------------------

--[[
Start of external source code

Author: TalkLounge
Mail: talklounge@yahoo.de
]]

local javaPath = "java" --Your path to java.exe. Example: C:/ProgramData/Oracle/Java/javapath/java.exe
local passwordKey = "pwd" --Your encryption password

local serverdata = {}
local database = {}
local checkboxes = {name = true, desc = true, player = false, mod = false}

local function crypt(text, key, decrypt)
	local len = 0
	for i = 1, string.len(key) do
		len = len + string.byte(string.sub(key, i, i))
	end
	len = math.ceil(math.sqrt(math.floor(len / string.len(key))))
	if len < 3 then
		len = len + 3
	end
	local retext = ""
	if not decrypt then
		local function ranbynum(num)
			local strnum = tostring(num)
			if string.len(strnum) == 3 then
				return strnum
			elseif string.len(strnum) == 2 then
				return math.random(3, 9) .. strnum
			else
				return math.random(3, 9) .. 0 .. strnum
			end
		end
		local function ran(len)
			local str = ""
			for i = 1, len do
				str = str .. math.random(0, 9)
			end
			return str
		end
		local pos = len - 2
		for i = 1, string.len(text) do
			retext = retext .. ran(pos - 1) .. ranbynum(string.byte(string.sub(text, i, i))) .. ran(len - pos - 2)
			if pos + 2 == len then
				pos = 1
			else
				pos = pos + 1
			end
		end
		return retext
	else
		local function charbyran(char)
			local nums = {tonumber(string.sub(char, 1, 1)), tonumber(string.sub(char, 2, 2)), tonumber(string.sub(char, 3, 3))}
			if nums[1] >= 3 and nums[2] == 0 then
				return string.char(nums[3])
			elseif nums[1] >= 3 then
				return string.char(nums[2] .. nums[3])
			else
				return string.char(nums[1] .. nums[2] .. nums[3])
			end
		end
		local pos = len - 2
		for i = 1, string.len(text) / len do
			retext = retext .. charbyran(string.sub(string.sub(text, i * len - len + 1, i * len), pos, pos + 2))
			if pos + 2 == len then
				pos = 1
			else
				pos = pos + 1
			end
		end
		return retext
	end
end

local function load_database()
  local file = io.open(core.get_mainmenu_path() .."/password.txt", "r")
  if not file then
		return
  end
	database = core.deserialize(file:read("*a"))
	file:close()
end

local function save_database()
  local file = io.open(core.get_mainmenu_path() .."/password.txt", "w")
  file:write(core.serialize(database))
  file:close()
end

local function load_serverdata()
	local file = io.popen(javaPath ..' -jar "'.. core.get_mainmenu_path() ..'/Serverlist.jar"')
	local data = file:read("*a")
	file:close()
	serverdata = core.parse_json(data)["list"]
end

local function toboolean(str)
	return (str == "true" and true or false)
end

--[[
End of external source code
]]

local function get_formspec(tabview, name, tabdata)
	-- Update the cached supported proto info,
	-- it may have changed after a change by the settings menu.
	common_update_cached_supp_proto()
	local fav_selected
	if menudata.search_result then
		fav_selected = menudata.search_result[tabdata.fav_selected]
	else
		fav_selected = menudata.favorites[tabdata.fav_selected]
	end

	if not tabdata.search_for then
		tabdata.search_for = ""
	end

	local retval =
		-- Search
		--Start of edited source code by TalkLounge
		"field[0.15,0.35;3.6,0.27;te_search;;".. core.formspec_escape(tabdata.search_for) .."]"..
    "checkbox[3.6,-0.5;cb_name;Name;".. tostring(checkboxes.name) .."]" ..
    "checkbox[3.6,-0.1;cb_desc;Desc;".. tostring(checkboxes.desc) .."]" ..
    "checkbox[4.6,-0.5;cb_player;Player;".. tostring(checkboxes.player) .."]" ..
    "checkbox[4.6,-0.1;cb_mod;Mods;".. tostring(checkboxes.mod) .."]" ..
		--End of edited source code by TalkLounge
		"button[5.62,-0.25;1.5,1;btn_mp_search;" .. fgettext("Search") .. "]" ..
		"image_button[6.97,-.165;.83,.83;" .. core.formspec_escape(defaulttexturedir .. "refresh.png")
			.. ";btn_mp_refresh;]" ..

		-- Address / Port
		"label[7.75,-0.25;" .. fgettext("Address / Port") .. "]" ..
		"field[8,0.65;3.25,0.5;te_address;;" ..
			core.formspec_escape(core.settings:get("address")) .. "]" ..
		"field[11.1,0.65;1.4,0.5;te_port;;" ..
			core.formspec_escape(core.settings:get("remote_port")) .. "]" ..

		-- Name / Password
		"label[7.75,0.95;" .. fgettext("Name / Password") .. "]" ..
		"field[8,1.85;2.9,0.5;te_name;;" ..
			core.formspec_escape(core.settings:get("name")) .. "]" ..
		"pwdfield[10.73,1.85;1.77,0.5;te_pwd;]" ..

		-- Description Background
		"box[7.73,2.25;4.25,2.6;#999999]"..

		-- Connect
		"button[9.88,4.9;2.3,1;btn_mp_connect;" .. fgettext("Connect") .. "]"

	if tabdata.fav_selected and fav_selected then
		if gamedata.fav then
			retval = retval .. "button[7.73,4.9;2.3,1;btn_delete_favorite;" ..
				fgettext("Del. Favorite") .. "]"
		end
		if fav_selected.description then
			retval = retval .. "textarea[8.1,2.3;4.23,2.9;;;" ..
				core.formspec_escape((gamedata.serverdescription or ""), true) .. "]"
		end
	end

	--favourites
	retval = retval .. "tablecolumns[" ..
		image_column(fgettext("Favorite"), "favorite") .. ";" ..
		image_column(fgettext("Ping")) .. ",padding=0.25;" ..
		"color,span=3;" ..
		"text,align=right;" ..                -- clients
		"text,align=center,padding=0.25;" ..  -- "/"
		"text,align=right,padding=0.25;" ..   -- clients_max
		image_column(fgettext("Creative mode"), "creative") .. ",padding=1;" ..
		image_column(fgettext("Damage enabled"), "damage") .. ",padding=0.25;" ..
		--~ PvP = Player versus Player
		image_column(fgettext("PvP enabled"), "pvp") .. ",padding=0.25;" ..
		"color,span=1;" ..
		"text,padding=1]" ..
		"table[-0.15,0.6;7.75,5.15;favourites;"

	if menudata.search_result then
		for i = 1, #menudata.search_result do
			local favs = core.get_favorites("local")
			local server = menudata.search_result[i]

			for fav_id = 1, #favs do
				if server.address == favs[fav_id].address and
						server.port == favs[fav_id].port then
					server.is_favorite = true
				end
			end

			if i ~= 1 then
				retval = retval .. ","
			end

			retval = retval .. render_serverlist_row(server, server.is_favorite)
		end
	elseif #menudata.favorites > 0 then
		local favs = core.get_favorites("local")
		if #favs > 0 then
			for i = 1, #favs do
			for j = 1, #menudata.favorites do
				if menudata.favorites[j].address == favs[i].address and
						menudata.favorites[j].port == favs[i].port then
					table.insert(menudata.favorites, i, table.remove(menudata.favorites, j))
				end
			end
				if favs[i].address ~= menudata.favorites[i].address then
					table.insert(menudata.favorites, i, favs[i])
				end
			end
		end
		retval = retval .. render_serverlist_row(menudata.favorites[1], (#favs > 0))
		for i = 2, #menudata.favorites do
			retval = retval .. "," .. render_serverlist_row(menudata.favorites[i], (i <= #favs))
		end
	end

	if tabdata.fav_selected then
		retval = retval .. ";" .. tabdata.fav_selected .. "]"
	else
		retval = retval .. ";0]"
	end

	return retval
end

--------------------------------------------------------------------------------
local function main_button_handler(tabview, fields, name, tabdata)
	--Start of added source code by TalkLounge
	if fields.cb_name then
		checkboxes.name = toboolean(fields.cb_name)
	end
	if fields.cb_desc then
		checkboxes.desc = toboolean(fields.cb_desc)
	end
	if fields.cb_player then
		checkboxes.player = toboolean(fields.cb_player)
	end
	if fields.cb_mod then
		checkboxes.mod = toboolean(fields.cb_mod)
	end
	--End of added source code by TalkLounge
	local serverlist = menudata.search_result or menudata.favorites

	if fields.te_name then
		gamedata.playername = fields.te_name
		core.settings:set("name", fields.te_name)
	end

	if fields.favourites then
		local event = core.explode_table_event(fields.favourites)
		local fav = serverlist[event.row]

		if event.type == "DCL" then
			if event.row <= #serverlist then
				--Start of commented out source code by TalkLounge
				--[[if menudata.favorites_is_public and
						not is_server_protocol_compat_or_error(
							fav.proto_min, fav.proto_max) then
					return true
				end]]
				--End of commented out source code by TalkLounge

				gamedata.address    = fav.address
				gamedata.port       = fav.port
				gamedata.playername = fields.te_name
				gamedata.selected_world = 0

				if fields.te_pwd then
					gamedata.password = fields.te_pwd
				end

				gamedata.servername        = fav.name
				gamedata.serverdescription = fav.description

				if gamedata.address and gamedata.port then
					core.settings:set("address", gamedata.address)
					core.settings:set("remote_port", gamedata.port)
					--Start of edited source code by TalkLounge
          if #serverdata == 0 then
						load_serverdata()
          end
          for key, value in pairs(serverdata) do
            if gamedata.servername == value.name then
							local clients_list = {}
							for key, value in ipairs(value.clients_list) do
								table.insert(clients_list, string.trim(value))
							end
              gamedata.serverdescription = "Players on ".. value.name ..":\n".. table.concat(clients_list, ", ")
            end
          end
					--End of edited source code by TalkLounge
				end
			end
			return true
		end

		if event.type == "CHG" then
			if event.row <= #serverlist then
				gamedata.fav = false
				local favs = core.get_favorites("local")
				local address = fav.address
				local port    = fav.port
				gamedata.serverdescription = fav.description

				for i = 1, #favs do
					if fav.address == favs[i].address and
							fav.port == favs[i].port then
						gamedata.fav = true
					end
				end

				if address and port then
					core.settings:set("address", address)
					core.settings:set("remote_port", port)
				end
				tabdata.fav_selected = event.row
			end
			return true
		end
	end

	if fields.key_up or fields.key_down then
		local fav_idx = core.get_table_index("favourites")
		local fav = serverlist[fav_idx]

		if fav_idx then
			if fields.key_up and fav_idx > 1 then
				fav_idx = fav_idx - 1
			elseif fields.key_down and fav_idx < #menudata.favorites then
				fav_idx = fav_idx + 1
			end
		else
			fav_idx = 1
		end

		if not menudata.favorites or not fav then
			tabdata.fav_selected = 0
			return true
		end

		local address = fav.address
		local port    = fav.port
		gamedata.serverdescription = fav.description
		if address and port then
			core.settings:set("address", address)
			core.settings:set("remote_port", port)
		end

		tabdata.fav_selected = fav_idx
		return true
	end

	if fields.btn_delete_favorite then
		local current_favourite = core.get_table_index("favourites")
		if not current_favourite then return end

		core.delete_favorite(current_favourite)
		asyncOnlineFavourites()
		tabdata.fav_selected = nil

		core.settings:set("address", "")
		core.settings:set("remote_port", "30000")
		return true
	end

	if fields.btn_mp_search or fields.key_enter_field == "te_search" then
		--Start of added source code by TalkLounge
		if (checkboxes.player or checkboxes.mod) and #serverdata == 0 then
      load_serverdata()
    end
		--End of added source code by TalkLounge
		tabdata.fav_selected = 1
		local input = fields.te_search:lower()
		tabdata.search_for = fields.te_search

		if #menudata.favorites < 2 then
			return true
		end

		menudata.search_result = {}

		-- setup the keyword list
		local keywords = {}
		for word in input:gmatch("%S+") do
			word = word:gsub("(%W)", "%%%1")
			table.insert(keywords, word)
		end

		if #keywords == 0 then
			menudata.search_result = nil
			return true
		end

		-- Search the serverlist
		local search_result = {}
		for i = 1, #menudata.favorites do
			local server = menudata.favorites[i]
			local found = 0
			for k = 1, #keywords do
				local keyword = keywords[k]
				--Start of edited source code by TalkLounge
				if server.name and checkboxes.name then
					local sername = server.name:lower()
					local _, count = sername:gsub(keyword, keyword)
					found = found + count * 8
				end

				if server.description and checkboxes.desc then
					local desc = server.description:lower()
					local _, count = desc:gsub(keyword, keyword)
					found = found + count * 4
				end
        
				if checkboxes.player then
          for key, value in pairs(serverdata) do
            if server.name == value.name then
              for _, player in pairs(value.clients_list) do
                if player:lower():find(keyword:lower()) then
                  found = found + 2
                end
              end
            end
          end
				end
				
        if checkboxes.mod then
					for key, value in pairs(serverdata) do
						if server.name == value.name and value.mods then
							for _, mod in pairs(value.mods) do
								if mod:lower() == keyword:lower() then
									found = found + 1
								end
							end
						end
					end
				end
			end
			--End of edited source code by TalkLounge
			if found > 0 then
				local points = (#menudata.favorites - i) / 5 + found
				server.points = points
				table.insert(search_result, server)
			end
		end
		if #search_result > 0 then
			table.sort(search_result, function(a, b)
				return a.points > b.points
			end)
			menudata.search_result = search_result
			local first_server = search_result[1]
			core.settings:set("address",     first_server.address)
			core.settings:set("remote_port", first_server.port)
			gamedata.serverdescription = first_server.description
		end
		return true
	end

	if fields.btn_mp_refresh then
		--Start of added source code by TalkLounge
		load_serverdata()
		--End of added source code by TalkLounge
		asyncOnlineFavourites()
		return true
	end

	if (fields.btn_mp_connect or fields.key_enter)
			and fields.te_address ~= "" and fields.te_port then
		gamedata.playername = fields.te_name
		gamedata.password   = fields.te_pwd
		gamedata.address    = fields.te_address
		gamedata.port       = fields.te_port
		gamedata.selected_world = 0
		--Start of added source code by TalkLounge
		if #database == 0 then
			load_database()
		end
		local found = false
		for key, value in pairs(database) do
			if value.address == fields.te_address and value.port == fields.te_port and value.name == fields.te_name then
				found = key
				break
			end
		end
		if string.len(fields.te_pwd) > 0 then
			if not found then
				table.insert(database, {address = fields.te_address, port = fields.te_port, name = fields.te_name, password = crypt(fields.te_pwd, passwordKey)})
				save_database()
			elseif database[found].password ~= crypt(fields.te_pwd, passwordKey) then
				database[found].password = crypt(fields.te_pwd, passwordKey)
				save_database()
			end
		elseif found then
			gamedata.password = crypt(database[found].password, passwordKey, true)
		end
		--End of added source code by TalkLounge
		local fav_idx = core.get_table_index("favourites")
		local fav = serverlist[fav_idx]

		if fav_idx and fav_idx <= #serverlist and
				fav.address == fields.te_address and
				fav.port    == fields.te_port then

			gamedata.servername        = fav.name
			gamedata.serverdescription = fav.description

			if menudata.favorites_is_public and
					not is_server_protocol_compat_or_error(
						fav.proto_min, fav.proto_max) then
				return true
			end
		else
			gamedata.servername        = ""
			gamedata.serverdescription = ""
		end

		core.settings:set("address",     fields.te_address)
		core.settings:set("remote_port", fields.te_port)

		core.start()
		return true
	end
	return false
end

local function on_change(type, old_tab, new_tab)
	if type == "LEAVE" then return end
	asyncOnlineFavourites()
end

--------------------------------------------------------------------------------
return {
	name = "online",
	caption = fgettext("Join Game"),
	cbf_formspec = get_formspec,
	cbf_button_handler = main_button_handler,
	on_change = on_change
}
