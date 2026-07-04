-- create directory manually if you want to save in different location and do not forget to leave trailing slash
local DIRECTORY = ""

local GAME_STATE_NAMES = {
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
local function get_filename()
	local custom_name

	local game_state = GameRules.GetGameState()

	if game_state > Enum.GameState.DOTA_GAMERULES_STATE_INIT then
		local local_player = Players.GetLocal()
		local player_team_data = Entity.IsPlayer(local_player) and Player.GetTeamData(local_player) or nil

		local hero_name = player_team_data ~= nil and Engine.GetHeroNameByID(player_team_data.selected_hero_id) or nil

		local hero_details

		if hero_name ~= nil then
			local hero_name_localized = GameLocalizer.FindNPC(hero_name)

			local local_hero = Heroes.GetLocal()

			if local_hero and Heroes.Contains(local_hero) then
				hero_details = string.format("[%s lvl %d]", hero_name_localized, NPC.GetCurrentLevel(local_hero))
			else
				hero_details = string.format("[%s]", hero_name_localized)
			end
		else
			hero_details = "[no hero]"
		end

		local game_state_name = GAME_STATE_NAMES[game_state] or "?"

		local game_state_details

		if game_state == Enum.GameState.DOTA_GAMERULES_STATE_PRE_GAME or game_state == Enum.GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			local dota_time = math.abs(GameRules.GetDOTATime(false, true))

			game_state_details = string.format("%s %02d.%02d", game_state_name, math.floor(dota_time / 60), math.floor(dota_time % 60))
		else
			game_state_details = string.format("%s %s", game_state_name, os.date("%y-%m-%d-%H-%M-%S"))
		end

		local match_id = GameRules.GetMatchID()

		local match_details = match_id ~= 0 and tostring(match_id) or Engine.GetLevelNameShort()

		custom_name = string.format("%s %s [%s]", hero_details, game_state_details, match_details)
	else
		custom_name = string.format("menu %s", os.date("%y-%m-%d-%H-%M-%S"))
	end

	return string.format("debug - %s.log", custom_name)
end

---@return nil
local function save()
	local debug_file = io.open("./debug.log", "r")
	if debug_file == nil then
		Notification({
			id = "userscript_debug_log_error",
			duration = 5,
			timer = 5,
			primary_text = "Failed to save debug",
			primary_image = "\u{f317}",
			secondary_text = "cannot read original debug.log",
			active = false,
		})

		return
	end

	local debug_content = debug_file:read("*a")
	debug_file:close()

	local filename = get_filename()

	local file_path = Engine.GetCheatDirectory() .. DIRECTORY .. filename

	local new_debug_file = io.open(file_path, "w")
	if new_debug_file == nil then
		Notification({
			id = "userscript_debug_log_error",
			duration = 5,
			timer = 5,
			primary_text = "Failed to save debug",
			primary_image = "\u{f317}",
			secondary_text = "cannot save file",
			active = false,
		})

		return
	end

	new_debug_file:write(debug_content)
	new_debug_file:close()

	Notification({
		id = "userscript_debug_log_success_" .. tostring(os.clock()),
		duration = 7,
		timer = 7,
		primary_text = "Debug saved",
		primary_image = "\u{f31c}",
		secondary_text = filename,
		active = true,
	})
end

local ui = {}

ui.menu = Menu.Create("General", "Debug", "Debug Log Helper")
ui.menu:Icon("\u{f15c}")

ui.menu_main = ui.menu:Create("Main")

ui.menu_script = ui.menu_main:Create("General")

ui.enable = ui.menu_script:Switch("Enable", false, "\u{f00c}")

ui.auto_save_endgame = ui.menu_script:Switch("Auto Save After Match", false, "\u{e5a2}")

ui.save_bind = ui.menu_script:Bind("Save Bind", Enum.ButtonCode.KEY_NONE, "\u{e1c1}")

ui.save = ui.menu_script:Button("Save", function()
	save()
end)

ui.enable:SetCallback(function(widget)
	local enabled = widget:Get()

	ui.auto_save_endgame:Disabled(not enabled)
	ui.save_bind:Disabled(not enabled)
	ui.save:Disabled(not enabled)
end, true)

return {
	OnUpdateEx = function()
		if ui.save_bind:IsPressed() then
			save()
		end
	end,

	---@param data OnGameRulesStateChangeData
	OnGameRulesStateChange = function(data)
		if ui.enable:Get() then
			if ui.auto_save_endgame:Get() then
				if data.new_state == Enum.GameState.DOTA_GAMERULES_STATE_POST_GAME then
					save()
				end
			end
		end
	end,
}
