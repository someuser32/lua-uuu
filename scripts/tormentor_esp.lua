require("libraries/__init__")

local TormentorESP = class("TormentorESP")

function TormentorESP:initialize()
	self.path = {"Magma", "Info Screen", "Tormentor"}

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	UILib:SetTabIcon(self.path, "panorama/images/spellicons/miniboss_reflect_png.vtex_c")

	self.hp_panel_width = (155-5)/2 -- (155 - roshan hp size, 5 - space between bars)
	self.hp_panel_height = 16
	self.barrier_base = 2500
	self.barrier_per_death = 200
	self.barrier_regen_base = 100
	self.barrier_regen_per_death = 100
	self.tormentor_respawn = 10*60
	self.tormentor_first_respawn = 20*60

	self.hp_font = CRenderer:LoadFont("Consolas", 14, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.MEDIUM)

	self.reflect_particles = {}
	self.reflect_positions = {}
	self.tormentors = {}
	self.tormentors_damage = {}
	self.tormentors_attackers = {}
	self.tormentors_deaths_count = {}
	self.tormentors_last_death = {}

	self.tormentor_teams = {
		[2] = {color={5, 190, 255}, position=Vector(-8128, -1216, 256), default_offset_x=-self.hp_panel_width/2, default_offset_y=self.hp_panel_height/2},
		[3] = {color={255, 130, 5}, position=Vector(8128, 1024, 256), default_offset_x=self.hp_panel_width/2+10, default_offset_y=self.hp_panel_height/2},
	}

	self:ParseData()

	self.listeners = {}
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

function TormentorESP:OnUpdate()
	local tick = self:GetTick()
	local dt = self:DTUpdate()
	local now = CGameRules:GetGameTime()
	if tick % 15 == 0 then
		local found = false
		for _, tormentor in pairs(CNPC:GetAll()) do
			if tormentor:GetClassName() == "C_DOTA_Unit_Miniboss" then
				self.tormentors[self:GetTeam(tormentor)] = tormentor:GetIndex()
				found = true
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
		local ingame = CGameRules:GetIngameTime()
		for team, info in pairs(table.copy(self.tormentor_teams)) do
			local entindex = self.tormentors[team]
			local tormentor = CNPC:FromIndex(entindex)
			if tormentor or entindex then
				local pos = {CConfig:ReadInt("magma_tormentor_esp", tostring("panel_"..team.."_x"), math.floor(1920/2+info["default_offset_x"])), CConfig:ReadInt("magma_tormentor_esp", tostring("panel_"..team.."_y"), math.floor(85+2+info["default_offset_y"]))}
				local attackers = table.keys(self.tormentors_attackers[entindex] or {})
				local enemy_attackers = {}
				for _, attacker_entindex in pairs(attackers) do
					local attacker = CNPC:FromIndex(attacker_entindex)
					if attacker and attacker:GetTeamNum() ~= localteam then
						table.insert(enemy_attackers, attacker)
					end
				end
				self:DrawHPBar(pos[1], pos[2], info["color"], #attackers <= 0 and {0, 0, 0} or {255, 35, 35}, 100, #attackers <= 0 and "ALIVE" or "ATTACK")
				local w, h = 16, 16
				for _, attacker in pairs(enemy_attackers) do
					CRenderer:SetDrawColor(255, 255, 255, 255)
					CRenderer:DrawImage(CRenderer:GetOrLoadImage(GetHeroIconPath(attacker:GetUnitName())), pos[1]-self.hp_panel_width/2 + w*(_-1), pos[2]+self.hp_panel_height/2 + 4, w, h)
				end
			else
				local pos = {CConfig:ReadInt("magma_tormentor_esp", tostring("panel_"..team.."_x"), math.floor(1920/2+info["default_offset_x"])), CConfig:ReadInt("magma_tormentor_esp", tostring("panel_"..team.."_y"), math.floor(85+2+info["default_offset_y"]))}
				local last_death = self.tormentors_last_death[tostring(team)]
				if last_death ~= nil then
					local next_respawn = math.ceil(last_death+self.tormentor_respawn)
					self:DrawHPBar(pos[1], pos[2], info["color"], {0, 0, 0}, (ingame-last_death)/(next_respawn-last_death)*100, ToClockMin(next_respawn))
				elseif ingame < self.tormentor_first_respawn then
					self:DrawHPBar(pos[1], pos[2], info["color"], {0, 0, 0}, ingame/self.tormentor_first_respawn*100, ToClockMin(self.tormentor_first_respawn))
				else
					self:DrawHPBar(pos[1], pos[2], info["color"], {0, 0, 0}, 100, "?")
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