require("libraries/__init__")

local TormentorESP = class("TormentorESP")

function TormentorESP:initialize()
	self.path = {"Magma", "Info Screen", "Tormentor"}

	self.hp_panel_width = (155-5)/2 -- (155 - roshan hp size, 5 - space between bars)
	self.hp_panel_height = 16
	self.barrier_base = 2500
	self.barrier_per_death = 200
	self.barrier_regen_base = 100
	self.barrier_regen_per_death = 100
	self.tormentor_respawn = 10*60
	self.tormentor_first_respawn = 20*60

	self.hp_font = CRenderer:LoadFont("Consolas", 14, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.MEDIUM)

	self.tormentor_teams = {
		[2] = {color={5, 190, 255}, position=Vector(-8128, -1216, 256), default_offset_x=-self.hp_panel_width/2, default_offset_y=self.hp_panel_height/2},
		[3] = {color={255, 130, 5}, position=Vector(8128, 1024, 256), default_offset_x=self.hp_panel_width/2+10, default_offset_y=self.hp_panel_height/2},
	}

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.move_key = UILib:CreateKeybind({self.path, "Panel"}, "Move key", Enum.ButtonCode.KEY_LCONTROL)
	self.move_key:SetIcon("~/MenuIcons/drag_def.png")
	self.reset_panel_positions = UILib:CreateButton({self.path, "Panel"}, "Reset positions", function()
		local screen_width, screen_height = CRenderer:GetScreenSize()
		for team, info in pairs(self.tormentor_teams) do
			CConfig:WriteInt("magma_tormentor_esp", tostring("panel_"..team.."_x"), math.floor(screen_width/2+info["default_offset_x"]))
			CConfig:WriteInt("magma_tormentor_esp", tostring("panel_"..team.."_y"), math.floor(85+2+info["default_offset_y"]))
		end
	end)

	UILib:SetTabIcon({self.path, "Panel"}, "~/MenuIcons/panel_def.png")

	self.reset_info = UILib:CreateButton(self.path, "Reset data", function()
		self:ResetAndSaveData()
		self.tormentors = {}
		self:ParseData()
	end)
	self.reset_info:SetTip("[WARNING]\nRESETS DATA FROM CURRENT MATCH\nUSE ONLY IN CASE IF SOMETHING BROKEN")

	UILib:SetTabIcon(self.path, "panorama/images/spellicons/miniboss_reflect_png.vtex_c")

	self.reflect_particles = {}
	self.reflect_positions = {}
	self.tormentors = {}
	self.tormentors_damage = {}
	self.tormentors_attackers = {}
	self.tormentors_deaths_count = {}
	self.tormentors_last_death = {}
	self.tormentors_exceptions = {}

	self:ParseData()

	self.listeners = {}

	self.mouse_previous_position = nil
end

function TormentorESP:DrawHPBar(x, y, color, border_color, fill, text)
	text = tostring(text)
	CRenderer:SetDrawColor(50, 50, 50, 100)
	CRenderer:DrawFilledRectCentered(x, y, self.hp_panel_width, self.hp_panel_height)
	CRenderer:SetDrawColor(border_color[1], border_color[2], border_color[3], 255)
	CRenderer:DrawOutlineRectCentered(x, y, self.hp_panel_width, self.hp_panel_height)
	CRenderer:SetDrawColor(color[1], color[2], color[3], 255)
	CRenderer:DrawFilledRect(x-self.hp_panel_width/2+4/2, y-self.hp_panel_height/2+4/2, math.min(self.hp_panel_width-4, math.max(0, math.floor((self.hp_panel_width-4)*fill/100))), self.hp_panel_height-4)
	if #text > 0 then
		CRenderer:SetDrawColor(0, 0, 0, 255)
		CRenderer:DrawTextCentered(self.hp_font, x+1, y, text)
		CRenderer:SetDrawColor(255, 255, 255, 255)
		CRenderer:DrawTextCentered(self.hp_font, x, y-1, text)
	end
end

function TormentorESP:DrawHPBarWithDrag(x, y, color, border_color, fill, text, team, should_move, cursor_position)
	if should_move then
		local bounds_min, bounds_max = {x-self.hp_panel_width/2, y-self.hp_panel_height/2}, {x+self.hp_panel_width/2, y+self.hp_panel_height/2}
		if ((cursor_position[1] > bounds_min[1] and cursor_position[1] < bounds_max[1]) and (cursor_position[2] > bounds_min[2] and cursor_position[2] < bounds_max[2])) or (self.mouse_previous_position ~= nil and self.mouse_previous_position[2] == team) then
			if self.mouse_previous_position ~= nil then
				local dt = {cursor_position[1] - self.mouse_previous_position[1][1], cursor_position[2] - self.mouse_previous_position[1][2]}
				local screen_width, screen_height = CRenderer:GetScreenSize()
				CConfig:WriteInt("magma_tormentor_esp", tostring("panel_"..team.."_x"), math.floor(math.min(math.max(x+dt[1], self.hp_panel_width/2), screen_width-self.hp_panel_width/2)))
				CConfig:WriteInt("magma_tormentor_esp", tostring("panel_"..team.."_y"), math.floor(math.min(math.max(y+dt[2], self.hp_panel_height/2), screen_height-self.hp_panel_height/2)))
			end
			self.mouse_previous_position = {cursor_position, team}
		end
	else
		self.mouse_previous_position = nil
	end
	self:DrawHPBar(x, y, color, border_color, fill, text)
end

function TormentorESP:OnUpdate()
	local tick = self:GetTick()
	local dt = self:DTUpdate()
	local now = CGameRules:GetGameTime()
	if tick % 15 == 0 then
		local found = false
		for _, tormentor in pairs(CNPC:GetAll()) do
			if tormentor:GetClassName() == "C_DOTA_Unit_Miniboss" and tormentor:IsAlive() then
				local entindex = tormentor:GetIndex()
				if not table.contains(self.tormentors_exceptions, entindex) and self.tormentors[self:GetTeam(tormentor)] ~= entindex then
					self.tormentors[self:GetTeam(tormentor)] = entindex
					found = true
				end
			end
		end
		if found then
			self:SaveData()
		end
	end
	for entindex, damage in pairs(table.copy(self.tormentors_damage)) do
		local tormentor = CNPC:new(CEntity:Get(entindex).ent)
		if tormentor:IsEntity() then
			local barrier_info = self:GetTormentorBarrierInfo(tormentor)
			self.tormentors_damage[entindex] = math.max(0, damage-barrier_info["regen"]*dt)
		else
			self.tormentors_damage[entindex] = nil
		end
	end
	if tick % 3 == 0 then
		for tormentor_index, attackers in pairs(table.copy(self.tormentors_attackers)) do
			for attacker_index, time in pairs(attackers) do
				if now-time > 5 then
					self.tormentors_attackers[tormentor_index][attacker_index] = nil
				end
			end
		end
		for team, tormentor_index in pairs(table.copy(self.tormentors)) do
			local tormentor = CEntity:Get(tormentor_index)
			if tormentor and tormentor:IsEntity() and not tormentor:IsAlive() then
				self.tormentors[team] = nil
			end
		end
	end
end

function TormentorESP:OnDraw()
	if not self.enable:Get() then return end
	local now = CGameRules:GetGameTime()
	local localteam = CPlayer:GetLocalTeam()
	for entindex, info in pairs(table.copy(self.reflect_positions)) do
		if now-info["time"] < 5 then
			local npc = CNPC:FromIndex(entindex)
			if npc:GetTeamNum() ~= localteam and not npc:IsVisible() then
				local unit_name = npc:GetUnitName()
				local x, y, visible = CRenderer:WorldToScreen(info["position"])
				if visible then
					CRenderer:SetDrawColor(255, 255, 255, 255)
					CRenderer:DrawImageCentered(CRenderer:GetOrLoadImage(GetHeroTopbarIconPathRounded(unit_name)), x, y, 32, 32)
				end
				CMiniMap:DrawHeroIcon(unit_name, info["position"], 255, 255, 255, 255, 300)
			end
		else
			self.reflect_particles[entindex] = nil
		end
	end
	if not CInput:IsKeyDown(Enum.ButtonCode.KEY_LALT) then
		local is_key_down = CInput:IsKeyDown(Enum.ButtonCode.KEY_MOUSE1)
		local is_move_key_down = self.move_key:IsActive()
		local cx, cy = CInput:GetCursorPos()
		local ingame = CGameRules:GetIngameTime()
		local screen_width, screen_height = CRenderer:GetScreenSize()
		for team, info in pairs(table.copy(self.tormentor_teams)) do
			local entindex = self.tormentors[team]
			local tormentor = CNPC:FromIndex(entindex)
			local pos = {CConfig:ReadInt("magma_tormentor_esp", tostring("panel_"..team.."_x"), math.floor(screen_width/2+info["default_offset_x"])), CConfig:ReadInt("magma_tormentor_esp", tostring("panel_"..team.."_y"), math.floor(85+2+info["default_offset_y"]))}
			if tormentor or entindex then
				local attackers = table.keys(self.tormentors_attackers[entindex] or {})
				local enemy_attackers = {}
				for _, attacker_entindex in pairs(attackers) do
					local attacker = CNPC:FromIndex(attacker_entindex)
					if attacker and attacker:GetTeamNum() ~= localteam then
						table.insert(enemy_attackers, attacker)
					end
				end
				self:DrawHPBarWithDrag(pos[1], pos[2], info["color"], #attackers <= 0 and {0, 0, 0} or {255, 35, 35}, 100, #attackers <= 0 and "ALIVE" or "ATTACK", team, is_move_key_down and is_key_down, {cx, cy})
				local w, h = 16, 16
				for _, attacker in pairs(enemy_attackers) do
					CRenderer:SetDrawColor(255, 255, 255, 255)
					CRenderer:DrawImage(CRenderer:GetOrLoadImage(GetHeroIconPath(attacker:GetUnitName())), pos[1]-self.hp_panel_width/2 + w*(_-1), pos[2]+self.hp_panel_height/2 + 4, w, h)
				end
			else
				local last_death = self.tormentors_last_death[tostring(team)]
				if last_death ~= nil then
					local next_respawn = math.ceil(last_death+self.tormentor_respawn)
					self:DrawHPBarWithDrag(pos[1], pos[2], info["color"], {0, 0, 0}, (ingame-last_death)/(next_respawn-last_death)*100, ToClockMin(next_respawn), team, is_move_key_down and is_key_down, {cx, cy})
				elseif ingame < self.tormentor_first_respawn then
					self:DrawHPBarWithDrag(pos[1], pos[2], info["color"], {0, 0, 0}, ingame/self.tormentor_first_respawn*100, ToClockMin(self.tormentor_first_respawn), team, is_move_key_down and is_key_down, {cx, cy})
				else
					self:DrawHPBarWithDrag(pos[1], pos[2], info["color"], {0, 0, 0}, 100, "?", team, is_move_key_down and is_key_down, {cx, cy})
				end
			end
		end
	end
end

function TormentorESP:OnEntityHurt(event)
	local attacker = CNPC:new(event["source"])
	local victim = CNPC:new(event["target"])
	local ability = CAbility:new(event["ability"])
	if victim:GetClassName() == "C_DOTA_Unit_Miniboss" then
		self.tormentors_damage[victim:GetIndex()] = (self.tormentors_damage[victim:GetIndex()] or 0) + event["damage"]
		if self.tormentors_attackers[victim:GetIndex()] == nil then
			self.tormentors_attackers[victim:GetIndex()] = {}
		end
		self.tormentors_attackers[victim:GetIndex()][attacker:GetIndex()] = CGameRules:GetGameTime()
	elseif attacker:GetClassName() == "C_DOTA_Unit_Miniboss" then
		if ability:GetName() == "miniboss_reflect" then
			if self.tormentors_attackers[attacker:GetIndex()] == nil then
				self.tormentors_attackers[attacker:GetIndex()] = {}
			end
			self.tormentors_attackers[attacker:GetIndex()][victim:GetIndex()] = CGameRules:GetGameTime()
		end
	end
end

function TormentorESP:OnEntityKilled(event)
	local victim = CNPC:new(event["target"])
	if victim:GetClassName() == "C_DOTA_Unit_Miniboss" or table.find(self.tormentors, victim:GetIndex()) ~= nil then
		local team = self:GetTeam(victim)
		self.tormentors_deaths_count[tostring(team)] = (self.tormentors_deaths_count[tostring(team)] or 0) + 1
		self.tormentors_last_death[tostring(team)] = math.floor(CGameRules:GetIngameTime())
		self.tormentors[team] = nil
		self.tormentors_damage[victim:GetIndex()] = nil
		table.insert(self.tormentors_exceptions, victim:GetIndex())
		self:SaveData()
	end
end

function TormentorESP:OnParticleCreate(particle)
	if table.contains({"miniboss_damage_reflect", "miniboss_damage_reflect_dire"}, particle["name"]) then
		self.reflect_particles[particle["index"]] = {particle["entity_for_modifiers_id"], particle["name"] == "miniboss_damage_reflect_dire"} -- for some reason, by default maphack dire is not shown
	end
	if table.contains({"miniboss_shield", "miniboss_shield_dire"}, particle["name"]) then
		self.tormentors[self:GetTeam(particle["name"])] = particle["entity_for_modifiers_id"]
		self:SaveData()
	end
	if table.contains({"miniboss_death", "miniboss_death_dire"}, particle["name"]) then
		local tormentor = CNPC:FromIndex(particle["entity_id"])
		local team = self:GetTeam(particle["name"])
		if self.tormentors[team] ~= nil then
			self.tormentors_deaths_count[tostring(team)] = (self.tormentors_deaths_count[tostring(team)] or 0) + 1
			self.tormentors_last_death[tostring(team)] = math.floor(CGameRules:GetIngameTime())
			self.tormentors[team] = nil
			self.tormentors_damage[particle["entity_id"]] = nil
			table.insert(self.tormentors_exceptions, particle["entity_id"])
			self:SaveData()
		end
	end
end

function TormentorESP:OnParticleUpdateEntity(particle)
	local reflect_info = self.reflect_particles[particle["index"]]
	if reflect_info ~= nil then
		if particle["controlPoint"] == 1 then
			if reflect_info[2] == true then
				self.reflect_positions[particle["entIdx"]] = {position=particle["position"], time=CGameRules:GetGameTime()}
			end
			self.reflect_particles[particle["index"]] = nil
			if self.tormentors_attackers[reflect_info[1]] == nil then
				self.tormentors_attackers[reflect_info[1]] = {}
			end
			self.tormentors_attackers[reflect_info[1]][particle["entIdx"]] = CGameRules:GetGameTime()
		end
	end
end

function TormentorESP:GetTeam(tormentor)
	if type(tormentor) == "string" then
		local particles = {
			["miniboss_shield"] = 2,
			["miniboss_shield_dire"] = 3,
			["miniboss_damage_reflect"] = 2,
			["miniboss_damage_reflect_dire"] = 3,
			["miniboss_death"] = 2,
			["miniboss_death_dire"] = 3,
		}
		return particles[tormentor] or (string.find(tormentor, "dire") ~= nil and 3 or 2)
	end
	local team = table.find(self.tormentors, type(tormentor) == "number" and tormentor or tormentor:GetIndex())
	if team ~= nil then
		return team
	end
	local tormentors = table.values(table.map(self.tormentor_teams, function(team, info) return {team, (info["position"]-tormentor:GetAbsOrigin()):Length2D()} end))
	table.sort(tormentors, function(a, b) return a[2] < b[2] end)
	return tormentors[1][1]
end

function TormentorESP:ParseData()
	local matchid = CGameRules:GetMatchID()
	local now = math.floor(CGameRules:GetGameTime())
	if CConfig:ReadInt("magma_tormentor_esp", "matchid", -1) ~= matchid or CConfig:ReadInt("magma_tormentor_esp", "time", -1) > now then
		CConfig:WriteInt("magma_tormentor_esp", "matchid", matchid)
		CConfig:WriteInt("magma_tormentor_esp", "time", now)
		CConfig:WriteString("magma_tormentor_esp", "tormentors_entindexes", "{}")
		CConfig:WriteString("magma_tormentor_esp", "tormentors_deaths_count", "{}")
		CConfig:WriteString("magma_tormentor_esp", "tormentors_last_death", "{}")
		self.tormentors_deaths_count = {}
		self.tormentors_last_death = {}
	else
		for team, entindex in pairs(json:decode(CConfig:ReadString("magma_tormentor_esp", "tormentors_entindexes", "{}"))) do
			self.tormentors[tonumber(team)] = entindex
		end
		self.tormentors_deaths_count = json:decode(CConfig:ReadString("magma_tormentor_esp", "tormentors_deaths_count", "{}"))
		self.tormentors_last_death = json:decode(CConfig:ReadString("magma_tormentor_esp", "tormentors_last_death", "{}"))
	end
end

function TormentorESP:SaveData()
	CConfig:WriteInt("magma_tormentor_esp", "matchid", CGameRules:GetMatchID())
	CConfig:WriteInt("magma_tormentor_esp", "time", math.floor(CGameRules:GetGameTime()))
	local tormentors_entindexes = {}
	for team, tormentor in pairs(self.tormentors) do
		tormentors_entindexes[tostring(team)] = tormentor
	end
	CConfig:WriteString("magma_tormentor_esp", "tormentors_entindexes", json:encode(tormentors_entindexes))
	CConfig:WriteString("magma_tormentor_esp", "tormentors_deaths_count", json:encode(self.tormentors_deaths_count))
	CConfig:WriteString("magma_tormentor_esp", "tormentors_last_death", json:encode(self.tormentors_last_death))
end

function TormentorESP:ResetAndSaveData()
	CConfig:WriteInt("magma_tormentor_esp", "matchid", CGameRules:GetMatchID())
	CConfig:WriteInt("magma_tormentor_esp", "time", math.floor(CGameRules:GetGameTime()))
	CConfig:WriteString("magma_tormentor_esp", "tormentors_entindexes", "{}")
	CConfig:WriteString("magma_tormentor_esp", "tormentors_deaths_count", "{}")
	CConfig:WriteString("magma_tormentor_esp", "tormentors_last_death", "{}")
end

function TormentorESP:GetTormentorBarrierInfo(tormentor)
	local ability = tormentor:GetAbility("miniboss_unyielding_shield")
	local barrier_base = ability ~= nil and ability:GetLevelSpecialValueFor("damage_absorb") or self.barrier_base
	local barrier_per_death = ability ~= nil and ability:GetLevelSpecialValueFor("absorb_bonus_per_death") or self.barrier_per_death
	local barrier_regen_base = ability ~= nil and ability:GetLevelSpecialValueFor("regen_per_second") or self.barrier_regen_base
	local barrier_regen_per_death = ability ~= nil and ability:GetLevelSpecialValueFor("regen_bonus_per_death") or self.barrier_regen_per_death
	local deaths = self.tormentors_deaths_count[tostring(self:GetTeam(tormentor))] or 0
	return {barrier=math.floor(barrier_base+barrier_per_death*deaths), regen=math.floor(barrier_regen_base+barrier_per_death*deaths)}
end

function TormentorESP:GetTormentorTeamBarrierInfo(team)
	local deaths = self.tormentors_deaths_count[tostring(team)] or 0
	return {barrier=math.floor(self.barrier_base+self.barrier_per_death*deaths), regen=math.floor(self.barrier_regen_base+self.barrier_regen_per_death*deaths)}
end

function TormentorESP:GetTormentorBarrier(tormentor)
	local barrier_info = self:GetTormentorBarrierInfo(tormentor)
	return {math.floor(barrier_info["barrier"]-(self.tormentors_damage[tormentor:GetIndex()] or 0)), math.floor(barrier_info["barrier"])}
end

return BaseScriptAPI(TormentorESP)