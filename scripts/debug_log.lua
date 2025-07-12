local CUSTOM_FILEPATH = "" -- WARNING: DO NOT EDIT IF YOU DO NOT KNOW WHAT ARE YOU DOING. Lua cannot create directories, so you must manually create EACH directory

local menu = Menu.Create("General", "Debug", "Debug Log Helper")

local menu_main = menu:Create("Main")

local menu_script = menu_main:Create("Main", Enum.GroupSide.FullWidth)

local enable = menu_script:Switch("Enable", false, "\u{f00c}")

local auto_save_endgame = menu_script:Switch("Auto Save After Match", false, "\u{f0c7}")

local log_name = menu_script:Label("debug.log")

local save = menu_script:Button("Save", function()
	SaveDebugLog()
end)

enable:SetCallback(function(widget)
	local enabled = widget:Get()

	auto_save_endgame:Disabled(not enabled)
	log_name:Disabled(not enabled)
	save:Disabled(not enabled)
end, true)

local state_to_text = {
	[Enum.GameState.DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD] = "pre draft",
	[Enum.GameState.DOTA_GAMERULES_STATE_HERO_SELECTION] = "draft",
	[Enum.GameState.DOTA_GAMERULES_STATE_STRATEGY_TIME] = "post draft",
	[Enum.GameState.DOTA_GAMERULES_STATE_PRE_GAME] = "pre game",
	[Enum.GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS] = "in game",
	[Enum.GameState.DOTA_GAMERULES_STATE_POST_GAME] = "post game",
	[Enum.GameState.DOTA_GAMERULES_STATE_DISCONNECT] = "disconnect",
	[Enum.GameState.DOTA_GAMERULES_STATE_TEAM_SHOWCASE] = "showcase",
	[Enum.GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP] = "custom game setup",
	[Enum.GameState.DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD] = "map load",
}

---@return string
function GetDebugLogName()
	local name = "debug"

	local state = GameRules.GetGameState()

	if state > Enum.GameState.DOTA_GAMERULES_STATE_INIT then
		local player = Players.GetLocal()
		local player_team_data = Player.GetTeamData(player)

		local hero_info = Engine.GetHeroNameByID(player_team_data.selected_hero_id)
		if hero_info ~= nil then
			local hero = Heroes.GetLocal()
			if hero ~= nil then
				hero_info = GameLocalizer.FindNPC(hero_info) .. " " .. tostring(player_team_data.selected_hero_variant & 0xFFFFFFFF) .. " lvl " .. tostring(NPC.GetCurrentLevel(hero))
			else
				hero_info = GameLocalizer.FindNPC(hero_info)
			end
		else
			hero_info = "no hero"
		end

		name = name .. " - [" .. hero_info .. "]"

		if state == Enum.GameState.DOTA_GAMERULES_STATE_PRE_GAME or state == Enum.GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			local dota_time = math.abs(GameRules.GetDOTATime(false, true))
			local dota_time_minutes = math.floor(dota_time / 60)
			local dota_time_seconds = dota_time % 60 < 10 and "0" .. tostring(math.floor(dota_time % 60)) or tostring(math.floor(dota_time % 60))
			local dota_time_formatted = tostring(dota_time_minutes) .. "." .. tostring(dota_time_seconds)
			name = name .. " " .. (state_to_text[state] or "?") .. " " .. dota_time_formatted
		else
			name = name .. " " .. (state_to_text[state] or "?")
		end

		local match_id = GameRules.GetMatchID()

		if match_id ~= 0 then
			name = name .. " [" .. tostring(match_id) .. "]"
		else
			name = name .. " [" .. Engine.GetLevelNameShort() .. "]"
		end
	else
		name = name .. " - " .. "menu"
	end

	name = name .. ".log"

	return name
end

---@param filename string?
---@return boolean
function SaveDebugLog(filename)
	filename = filename or GetDebugLogName()
	log_name:Name(filename)

	filename = Engine.GetCheatDirectory() .. CUSTOM_FILEPATH .. filename

	local debug_file = assert(io.open("./debug.log", "r"))
	local debug_content = debug_file:read("*a")
	debug_file:close()

	local new_debug_file = io.open(filename, "w")
	if new_debug_file ~= nil then
		new_debug_file:write(debug_content)
		new_debug_file:close()
	else
		Log.Write("[debug_log.lua | Debug Log Helper] failed to copy debug!")
		return false
	end

	return true
end

local tick = 0

return {
	OnUpdateEx = function()
		if enable:Get() then
			if tick % 30 == 0 then
				local new_debug_filename = GetDebugLogName()
				log_name:Name(new_debug_filename)
			end

			tick = tick + 1
			if tick >= 100 then
				tick = 0
			end
		end
	end,

	OnGameRulesStateChange = function(data)
		if enable:Get() then
			if auto_save_endgame:Get() then
				if data.new_state == Enum.GameState.DOTA_GAMERULES_STATE_POST_GAME then
					SaveDebugLog()
				end
			end
		end
	end,
}