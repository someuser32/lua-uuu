require("libraries/__init__")

local ShowMeMoreDestinations = class("ShowMeMoreDestinations")

function ShowMeMoreDestinations:initialize()
	self.path = {"Magma", "Info Screen", "Show Me More"}

	self.alerts_info = {
		["hoodwink_bushwhack"] = {
			color = {75, 255, 0},
		},
		["brewmaster_cinder_brew"] = {
			color = {255, 175, 50},
		},
		["techies_sticky_bomb"] = {
			color = {255, 215, 50},
		},
	}

	self.particles_info = {
		["hoodwink_bushwhack_projectile"] = {
			alert = "hoodwink_bushwhack",
			start_position = "0-xyz",
			position = "1-xyz",
			radius = function(owner)
				local ability = owner:GetAbility("hoodwink_bushwhack")
				if ability and ability:GetLevel() > 0 then
					return ability:GetLevelSpecialValueFor("trap_radius")
				end
				return 265
			end,
			speed = "2-x",
		},
		["brewmaster_cinder_brew_cast"] = {
			alert = "brewmaster_cinder_brew",
			start_position = "0-xyz",
			position = "1-xyz",
			radius = "2-x",
			speed = 1600,
		},
	}

	self.enable = UILib:CreateCheckbox(self.path, "Show Spells Destination", false)
	self.enable:SetIcon("~/MenuIcons/line_dashed.png")

	self.drawings = {}
	self.range_finder_drawings = {}
	self.sticky_bomb_duration = 1.2

	self.listeners = {}
end

function ShowMeMoreDestinations:OnUpdate()
	if not self.enable:Get() then return end
	local tick = self:GetTick()
	if tick % 6 == 0 then
		for _, hero in pairs(CHero:GetEnemies()) do
			local sharpshooter_modifier = hero:GetModifier("modifier_hoodwink_sharpshooter_windup")
			local entindex = hero:GetIndex()
			if sharpshooter_modifier then
				if self.range_finder_drawings[entindex.."_sharpshooter"] == nil then
					local ability = sharpshooter_modifier:GetAbility()
					self.range_finder_drawings[entindex.."_sharpshooter"] = {
						fx=CParticleManager:Create("particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_range_finder.vpcf", Enum.ParticleAttachment.PATTACH_ABSORIGIN_FOLLOW, hero),
						modifier_name=sharpshooter_modifier:GetName(),
						range=ability:GetLevelSpecialValueFor("arrow_range"),
						owner=hero,
					}
				end
			end
		end
	end
	for _, drawing in pairs(table.copy(self.range_finder_drawings)) do
		if drawing["owner"]:IsEntity() and drawing["owner"]:HasModifier(drawing["modifier_name"]) then
			CParticleManager:SetControlPoint(drawing["fx"], 1, drawing["owner"]:GetAbsOrigin() + drawing["owner"]:GetRotation():GetForward() * drawing["range"])
		else
			CParticleManager:Destroy(drawing["fx"])
			self.range_finder_drawings[_] = nil
		end
	end
end

function ShowMeMoreDestinations:OnDraw()
	if not self.enable:Get() then return end
	local now = CGameRules:GetGameTime()
	for _, drawing in pairs(table.copy(self.drawings)) do
		if drawing[1] < now then
			self.drawings[_] = nil
		else
			local x, y, visible = CRenderer:WorldToScreen(drawing[4])
			if visible then
				if drawing[3] == "circle_outlined" then
					CRenderer:SetDrawColor(table.unpack(table.combine(drawing[7], 255)))
					CRenderer:DrawOutlineCircle(x, y, drawing[6], drawing[6] * 2)
				end
			end
		end
	end
end

function ShowMeMoreDestinations:OnParticle(particle)
	if not self.enable:Get() then return end
	local particle_info = self.particles_info[particle["name"]] or self.particles_info[particle["shortname"]]
	if particle_info ~= nil then
		local owner = particle["entity_for_modifiers"]
		if owner == nil then
			for _, enemy in pairs(CHero:GetEnemies()) do
				local ability = enemy:GetAbilityOrItemByName(particle_info["ability"])
				if ability ~= nil then
					owner = enemy
					break
				end
			end
		end
		if owner == nil and particle["entity"] ~= nil then
			owner = particle["entity"]
		end
		if owner == nil or owner:GetTeamNum() == CPlayer:GetLocalTeam() then return end
		local data = {}
		for _, key in pairs({"start_position", "speed", "position", "radius"}) do
			if type(particle_info[key]) == "string" then
				local controlPoint, coordinates = table.unpack(string.split(particle_info[key], "-"))
				local control_points = particle["control_points"][tonumber(controlPoint)]
				if control_points ~= nil then
					local coordinates_table = string.split(coordinates, "")
					if #coordinates_table == 1 then
						data[key] = control_points[#control_points]["position"][coordinates_table[1]]
					else
						local vec = {}
						for _, coord in pairs(coordinates_table) do
							vec[coord] = control_points[#control_points]["position"][coord]
						end
						data[key] = Vector(vec["x"] or 0, vec["y"] or 0, vec["z"] or 0)
					end
				end
			elseif type(particle_info[key]) == "function" then
				data[key] = particle_info[key](owner)
			elseif type(particle_info[key]) == "number" then
				data[key] = particle_info[key]
			end
		end
		if data["start_position"] ~= nil and data["speed"] ~= nil and data["position"] ~= nil and data["radius"] ~= nil then
			local duration = (data["position"] - data["start_position"]):Length2D() / data["speed"]
			self:DrawAlert(particle_info["alert"], data["position"], data["radius"], duration)
		end
	end
end

function ShowMeMoreDestinations:OnEntityCreate(entity)
	if not self.enable:Get() then return end
	local ent = CEntity:new(entity)
	if ent:IsNPC() then
		local npc = CNPC:new(entity)
		Timers:CreateTimer(0.01, function()
			if npc:GetTeamNum() == CPlayer:GetLocalTeam() then return end
			if npc:GetUnitName() == "npc_dota_techies_mines" then
				local old_pos = npc:GetAbsOrigin()
				local old_time = CGameRules:GetGameTime()
				local old_speed = 0
				local start_time = CGameRules:GetGameTime()
				local start_pos = npc:GetAbsOrigin()
				Timers:CreateTimer(0.01, function()
					if not npc:IsEntity() or not npc:IsAlive() then
						return
					end
					local now = CGameRules:GetGameTime()
					local elapsed_time = now - old_time
					local new_pos = npc:GetAbsOrigin()
					local distance = (new_pos-old_pos):Length2D()
					local speed = distance / elapsed_time
					if old_speed > 0 and speed > 0 then
						local direction = (new_pos-old_pos)
						direction.z = 0
						direction = direction:Normalized()
						if math.abs(old_speed-speed) < 2 then
							local life_time = now-start_time
							local predict_pos = new_pos + direction * (speed * (self.sticky_bomb_duration-life_time) - (new_pos-start_pos):Length2D() + distance)
							local end_pos = CWorld:GetGroundPosition(predict_pos)
							self:DrawAlert("techies_sticky_bomb", end_pos, 300, self.sticky_bomb_duration-0.01-life_time-0.01)
							return nil
						end
					end
					old_pos = new_pos
					old_time = now
					old_speed = speed
					return 0.01
				end, self)
			end
		end, self)
	end
end

---@param alert string
---@param position Vector
---@param radius number
---@param duration number
---@return nil
function ShowMeMoreDestinations:DrawAlert(alert, position, radius, duration)
	if not self.enable:Get() then return end
	local alert_info = self.alerts_info[alert]
	if alert == "hoodwink_bushwhack" then
		local trees = table.combine(CTree:FindInRadius(position, radius+32, true), CTempTree:FindInRadius(position, radius+32))
		for _, tree in pairs(trees) do
			table.insert(self.drawings, {CGameRules:GetGameTime() + duration + 0.1, alert, "circle_outlined", tree:GetAbsOrigin(), radius, 10, {15, 255, 15}})
		end
	end
	return CParticleManager:DrawAlert(position, radius, duration + 0.1, alert_info["color"] or {255, 255, 255}, true)
end

return BaseScriptAPI(ShowMeMoreDestinations)