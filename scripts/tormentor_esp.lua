require("libraries/__init__")

local TormentorESP = class("TormentorESP")

function TormentorESP:initialize()
	self.path = {"Magma", "Info Screen", "Tormentor"}

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	UILib:SetTabIcon(self.path, "panorama/images/spellicons/miniboss_reflect_png.vtex_c")

	self.hp_panel_width = (155-5)/2 -- (155 - roshan hp size, 5 - space between bars)
	self.hp_panel_height = 16

	self.hp_font = CRenderer:LoadFont("Consolas", 14, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.MEDIUM)

	self.reflect_particles = {}
	self.reflect_positions = {}

	self.listeners = {}
end

function TormentorESP:DrawHPBar(x, y, color, fill, health)
	CRenderer:SetDrawColor(50, 50, 50, 100)
	CRenderer:DrawFilledRectCentered(x, y, self.hp_panel_width, self.hp_panel_height)
	CRenderer:SetDrawColor(0, 0, 0, 255)
	CRenderer:DrawOutlineRectCentered(x, y, self.hp_panel_width, self.hp_panel_height)
	CRenderer:SetDrawColor(color[1], color[2], color[3], 255)
	CRenderer:DrawFilledRect(x-self.hp_panel_width/2+4/2, y-self.hp_panel_height/2+4/2, math.min(self.hp_panel_width-4, math.max(0, math.floor((self.hp_panel_width-4)*fill/100))), self.hp_panel_height-4)
	CRenderer:SetDrawColor(0, 0, 0, 255)
	CRenderer:DrawTextCentered(self.hp_font, x+1, y, tostring(health))
	CRenderer:SetDrawColor(255, 255, 255, 255)
	CRenderer:DrawTextCentered(self.hp_font, x, y-1, tostring(health))
end

function TormentorESP:OnDraw()
	if not self.enable:Get() then return end
	local now = CGameRules:GetGameTime()
	local localteam = CPlayer:GetLocalTeam()
	for entindex, info in pairs(table.copy(self.reflect_positions)) do
		if now-info["time"] < 5 then
			local npc = CNPC:new(CEntity:Get(entindex).ent)
			if npc:GetTeamNum() ~= localteam and not npc:IsVisible() then
				local x, y, visible = CRenderer:WorldToScreen(info["position"])
				if visible then
					CRenderer:SetDrawColor(255, 255, 255, 255)
					CRenderer:DrawImageCentered(CRenderer:GetOrLoadImage(GetHeroIconPath(npc:GetUnitName())), x, y, 32, 32)
				end
			end
		else
			self.reflect_particles[entindex] = nil
		end
	end
	local radiant_pos = {CConfig:ReadInt("magma_tormentor_esp", "panel_radiant_x", math.floor(1920/2-self.hp_panel_width/2)), CConfig:ReadInt("magma_tormentor_esp", "panel_radiant_y", math.floor(75+2+self.hp_panel_height/2))}
	local dire_pos = {CConfig:ReadInt("magma_tormentor_esp", "panel_dire_x", math.floor(1920/2+self.hp_panel_width/2+10)), CConfig:ReadInt("magma_tormentor_esp", "panel_dire_y", math.floor(75+2+self.hp_panel_height/2))}
	self:DrawHPBar(radiant_pos[1], radiant_pos[2], {5, 200, 255}, 14, "18090")
	self:DrawHPBar(dire_pos[1], dire_pos[2], {255, 200, 5}, 70, "17700")
end

function TormentorESP:OnEntityHurt(event)
	local attacker = CNPC:new(event["source"])
	local victim = CNPC:new(event["target"])
	if victim:GetUnitName() == "npc_dota_miniboss" then
	end
end

function TormentorESP:OnParticleCreate(particle)
	-- DeepPrintTable(particle)
	-- spawn particles/neutral_fx/miniboss_shield_dire.vpcf
	if table.contains({"miniboss_damage_reflect_radiant", "miniboss_damage_reflect_dire"}, particle["name"]) then
		self.reflect_particles[particle["index"]] = true
	end
end

function TormentorESP:OnParticleUpdateEntity(particle)
	local reflect_info = self.reflect_particles[particle["index"]]
	if reflect_info ~= nil then
		if particle["controlPoint"] == 1 then
			self.reflect_positions[particle["entIdx"]] = {position=particle["position"], time=CGameRules:GetGameTime()}
			self.reflect_particles[particle["index"]] = nil
		end
	end
end

return BaseScriptAPI(TormentorESP)