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
			radius = function(owner, info)
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
		-- ["beastmaster_wildaxe"] = {
		-- 	alert = "beastmaster_wild_axes",
		-- 	start_position = "1-xyz",
		-- 	position = "2-xyz",
		-- 	radius = function(owner, info)
		-- 		local ability = owner:GetAbility("beastmaster_wild_axes")
		-- 		if ability and ability:GetLevel() > 0 then
		-- 			return ability:GetLevelSpecialValueFor("radius")
		-- 		end
		-- 		return 175
		-- 	end,
		-- 	speed = function(owner, info)
		-- 		if info["position"] ~= nil
		-- 		return 1200
		-- 	end,
		-- }
	}

	self.enable = UILib:CreateCheckbox(self.path, "Show Spells Destination", false)
	self.enable:SetIcon("~/MenuIcons/line_dashed.png")

	self.particles = {}
	self.drawings = {}
	self.range_finder_drawings = {}
	self.sticky_bomb_duration = 1.2

	self.listeners = {}
end

function ShowMeMoreDestinations:OnUpdate()
	if not self.enable:Get() then return end
	local tick = self:GetTick()
	-- if tick % 5 == 0 then
	-- 	for _, hero in pairs(CHero:GetEnemies()) do
	-- 		local sharpshooter_modifier = hero:GetModifier("modifier_hoodwink_sharpshooter_windup")
	-- 		local entindex = hero:GetIndex()
	-- 		if sharpshooter_modifier then
	-- 			if self.range_finder_drawings[entindex.."_sharpshooter"] == nil then
	-- 				self.range_finder_drawings[entindex.."_sharpshooter"] = {
	-- 					fx=CParticleManager:Create("particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_range_finder.vpcf", Enum.ParticleAttachment.PATTACH_ABSORIGIN_FOLLOW, hero),
	-- 					modifier=sharpshooter_modifier,
	-- 					owner=hero,
	-- 				}
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- for _, drawing in pairs(table.copy(self.range_finder_drawings)) do
	-- 	if drawing["modifier"] ~= nil then
	-- 		if drawing["modifier"]:IsValid() and drawing["owner"]:HasModifier(drawing["modifier"]:GetName()) then
	-- 			CParticleManager:SetControlPoint(drawing["fx"], 1, drawing["owner"]:GetAbsOrigin() + drawing["owner"]:GetRotation():GetForward() * drawing["modifier"]:GetAbility():GetLevelSpecialValueFor("arrow_range"))
	-- 		else
	-- 			CParticleManager:Destroy(drawing["fx"])
	-- 			self.range_finder_drawings[_] = nil
	-- 		end
	-- 	end
	-- end
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

function ShowMeMoreDestinations:OnParticleCreate(particle)
	-- print("----------------\ncreate")
	-- DeepPrintTable(particle)
	local particle_info = self.particles_info[particle["fullName"]] or self.particles_info[particle["name"]]
	if particle_info == nil then return end
	local owner = nil
	if particle["entityForModifiers"] ~= nil then
		owner = CNPC:new(particle["entityForModifiers"])
	end
	if owner == nil and particle_info["ability"] ~= nil then
		for _, enemy in pairs(CHero:GetEnemies()) do
			local ability = enemy:GetAbilityOrItemByName(particle_info["ability"])
			if ability ~= nil then
				owner = enemy
				break
			end
		end
	end
	if owner == nil and particle["entity_id"] ~= nil and particle["entity_id"] ~= -1 then
		owner = CNPC:new(particle["entity_id"])
	end
	if owner == nil or owner:GetTeamNum() == CPlayer:GetLocalTeam() then return end
	self.particles[particle["index"]] = {
		start=CGameRules:GetGameTime(),
		name=particle["name"],
		fullname=particle["fullName"],
		owner=owner,
	}
end

function ShowMeMoreDestinations:OnParticleUpdate(particle)
	-- print("----------------\nupdate")
	-- DeepPrintTable(particle)
	local create_info = self.particles[particle["index"]]
	if create_info == nil then return end
	local particle_info = self.particles_info[create_info["fullName"]] or self.particles_info[create_info["name"]]
	for _, key in pairs({"start_position", "speed", "position", "radius"}) do
		if type(particle_info[key]) == "string" then
			local controlPoint, coordinates = table.unpack(string.split(particle_info[key], "-"))
			if particle["controlPoint"] == tonumber(controlPoint) then
				local coordinates_table = string.split(coordinates, "")
				if #coordinates_table == 1 then
					self.particles[particle["index"]][key] = particle["position"][coordinates_table[1]]
				else
					local vec = {}
					for _, coord in pairs(coordinates_table) do
						vec[coord] = particle["position"][coord]
					end
					self.particles[particle["index"]][key] = Vector(vec["x"] or 0, vec["y"] or 0, vec["z"] or 0)
				end
			end
		elseif type(particle_info[key]) == "function" then
			self.particles[particle["index"]][key] = particle_info[key](create_info["owner"], self.particles[particle["index"]])
		elseif type(particle_info[key]) == "number" then
			self.particles[particle["index"]][key] = particle_info[key]
		end
	end
	create_info = self.particles[particle["index"]]
	if create_info["start_position"] ~= nil and create_info["speed"] ~= nil and create_info["position"] ~= nil and create_info["radius"] ~= nil then
		local duration = (create_info["position"] - create_info["start_position"]):Length2D() / create_info["speed"]
		self:DrawAlert(particle_info["alert"], create_info["position"], create_info["radius"], duration)
		self.particles["index"] = nil
	end
end

function ShowMeMoreDestinations:OnParticleUpdateEntity(particle)
	-- print("----------------\nupdate ent")
	-- DeepPrintTable(particle)
	local create_info = self.particles[particle["index"]]
	if create_info == nil then return end
	local particle_info = self.particles_info[create_info["fullName"]] or self.particles_info[create_info["name"]]
	for _, key in pairs({"start_position", "speed", "position", "radius"}) do
		if type(particle_info[key]) == "string" then
			local controlPoint, coordinates = table.unpack(string.split(particle_info[key], "-"))
			if particle["controlPoint"] == tonumber(controlPoint) then
				local coordinates_table = string.split(coordinates, "")
				if #coordinates_table == 1 then
					self.particles[particle["index"]][key] = particle["position"][coordinates_table[1]]
				else
					local vec = {}
					for _, coord in pairs(coordinates_table) do
						vec[coord] = particle["position"][coord]
					end
					self.particles[particle["index"]][key] = Vector(vec["x"] or 0, vec["y"] or 0, vec["z"] or 0)
				end
			end
		elseif type(particle_info[key]) == "function" then
			self.particles[particle["index"]][key] = particle_info[key](create_info["owner"], self.particles[particle["index"]])
		elseif type(particle_info[key]) == "number" then
			self.particles[particle["index"]][key] = particle_info[key]
		end
	end
	create_info = self.particles[particle["index"]]
	if create_info["start_position"] ~= nil and create_info["speed"] ~= nil and create_info["position"] ~= nil and create_info["radius"] ~= nil then
		local duration = (create_info["position"] - create_info["start_position"]):Length2D() / create_info["speed"]
		self:DrawAlert(particle_info["alert"], create_info["position"], create_info["radius"], duration)
		self.particles["index"] = nil
	end
end

function ShowMeMoreDestinations:OnEntityCreate(entity)
	local ent = CEntity:new(entity)
	if ent:IsNPC() then
		local npc = CNPC:new(entity)
		Timers:CreateTimer(0.01, function()
			if npc:GetUnitName() == "npc_dota_techies_mines" then
				self.sticky_mine = npc
				self.last_pos = npc:GetAbsOrigin()
				self.last_z = math.floor(self.last_pos:GetZ())
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
					local elapsed_time = (now - old_time)
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

function ShowMeMoreDestinations:OnLinearProjectileCreate(projectile)
	-- print("----------------\nprojectile")
	-- DeepPrintTable(projectile)
end

function ShowMeMoreDestinations:DrawAlert(alert, position, radius, duration)
	if not self.enable:Get() then return end
	local alert_info = self.alerts_info[alert]
	if alert == "hoodwink_bushwhack" then
		local trees = table.combine(CTree:FindInRadius(position, radius, true), CTempTree:FindInRadius(position, radius))
		for _, tree in pairs(trees) do
			table.insert(self.drawings, {CGameRules:GetGameTime() + duration + 0.1, alert, "circle_outlined", tree:GetAbsOrigin(), radius, 16, {15, 255, 15}})
		end
	end
	return CParticleManager:DrawAlert(position, radius, duration + 0.1, alert_info["color"] or {255, 255, 255}, true)
end

return BaseScriptAPI(ShowMeMoreDestinations)