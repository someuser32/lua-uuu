require("xlib/__init__")

local ShowMeMoreDestinations = {}

function ShowMeMoreDestinations:Init()
	self.enable = Menu.Find("Info Screen", "Main", "Show Me More", "Main", "Maphack", "Enable") --[[@as CMenuSwitch]]

	self.menu_gear = Menu.Find("Info Screen", "Main", "Show Me More", "Main", "Maphack", "Ability Info", "Ability Info") --[[@as CMenuGearAttachment]]
	self.show_destination = self.menu_gear:Switch("Show Spells Destination (xScripts)", false)
	self.show_destination:Icon("\u{e3d4}")

	self.alerts_info = {
		["hoodwink_bushwhack"] = {
			color = Color(75, 255, 0),
		},
		["brewmaster_cinder_brew"] = {
			color = Color(255, 175, 50),
		},
		["techies_sticky_bomb"] = {
			color = Color(255, 215, 50),
		},
	}

	self.particles_info = {
		["hoodwink_bushwhack_projectile"] = {
			alert = "hoodwink_bushwhack",
			start_position = "0-xyz",
			position = "1-xyz",
			radius = function(owner)
				local ability = NPC.GetAbility(owner, "hoodwink_bushwhack")
				if ability and Ability.GetLevel(ability) > 0 then
					return Ability.GetLevelSpecialValueFor(ability, "trap_radius")
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

	self.drawings = {}
	self.range_finder_drawings = {}
	self.sticky_bomb_duration = 1.2

	self.listeners = {}
end

function ShowMeMoreDestinations:IsCallbackEnabled(callback_name)
	return self.enable:Get() and self.show_destination:Get()
end

function ShowMeMoreDestinations:OnUpdate()
	if not self.enable:Get() or not self.show_destination:Get() then return end
	local tick = Tick()
	if tick % 6 == 0 then
		local localteam = Player.GetLocalTeam()
		for _, hero in pairs(Heroes.GetAll()) do
			if Entity.GetTeamNum(hero) ~= localteam then
				local sharpshooter_modifier = NPC.GetModifier(hero, "modifier_hoodwink_sharpshooter_windup")
				local entindex = Entity.GetIndex(hero)
				if sharpshooter_modifier then
					if self.range_finder_drawings[entindex.."_sharpshooter"] == nil then
						local ability = Modifier.GetAbility(sharpshooter_modifier)
						self.range_finder_drawings[entindex.."_sharpshooter"] = {
							fx=Particle.Create("particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_range_finder.vpcf", Enum.ParticleAttachment.PATTACH_ABSORIGIN_FOLLOW, hero),
							modifier_name=Modifier.GetName(sharpshooter_modifier),
							range=Ability.GetLevelSpecialValueFor(ability, "arrow_range"),
							owner=hero,
						}
					end
				end
			end
		end
	end
	for _, drawing in pairs(table.copy(self.range_finder_drawings)) do
		if Entity.IsEntity(drawing["owner"]) and NPC.HasModifier(drawing["owner"], drawing["modifier_name"]) then
			Particle.SetControlPoint(drawing["fx"], 1, Entity.GetAbsOrigin(drawing["owner"]) + Entity.GetRotation(drawing["owner"]):GetForward() * drawing["range"])
		else
			Particle.Destroy(drawing["fx"])
			self.range_finder_drawings[_] = nil
		end
	end
end

function ShowMeMoreDestinations:OnDraw()
	if not self.enable:Get() or not self.show_destination:Get() then return end
	local now = GameRules.GetGameTime()
	for _, drawing in pairs(table.copy(self.drawings)) do
		if drawing[1] < now then
			self.drawings[_] = nil
		else
			local pos, visible = Render.WorldToScreen(drawing[4])
			if visible then
				if drawing[3] == "circle_outlined" then
					Render.Circle(pos, drawing[6], drawing[7], nil, nil, nil, nil, drawing[6] * 2)
				end
			end
		end
	end
end

function ShowMeMoreDestinations:OnParticle(particle)
	local particle_info = self.particles_info[particle["name"]] or self.particles_info[particle["shortname"]]
	if particle_info ~= nil then
		local localteam = Player.GetLocalTeam()
		local owner = particle["entity_for_modifiers"]
		if owner == nil then
			for _, enemy in pairs(Heroes.GetAll()) do
				if Entity.GetTeamNum(enemy) ~= localteam then
					local ability = NPC.GetAbilityOrItemByName(enemy, particle_info["ability"])
					if ability ~= nil then
						owner = enemy
						break
					end
				end
			end
		end
		if owner == nil and particle["entity"] ~= nil then
			owner = particle["entity"]
		end
		if owner == nil or Entity.GetTeamNum(owner) == localteam then return end
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
	if not self.enable:Get() or not self.show_destination:Get() then return end
	if Entity.IsNPC(entity) then
		Timers:CreateTimer(0.01, function()
			if not Entity.IsEntity(entity) then return nil end
			if Entity.GetTeamNum(entity) == Player.GetLocalTeam() then return end
			if NPC.GetUnitName(entity) == "npc_dota_techies_remote_mine" then
				local old_pos = Entity.GetAbsOrigin(entity)
				local old_time = GameRules.GetGameTime()
				local old_speed = 0
				local start_time = GameRules.GetGameTime()
				local start_pos = Entity.GetAbsOrigin(entity)
				Timers:CreateTimer(0.01, function()
					if not Entity.IsEntity(entity) or not Entity.IsAlive(entity) then
						return
					end
					local now = GameRules.GetGameTime()
					local elapsed_time = now - old_time
					local new_pos = Entity.GetAbsOrigin(entity)
					local distance = (new_pos-old_pos):Length2D()
					local speed = distance / elapsed_time
					if old_speed > 0 and speed > 0 then
						local direction = (new_pos-old_pos)
						direction.z = 0
						direction = direction:Normalized()
						if math.abs(old_speed-speed) < 2 then
							local life_time = now-start_time
							local predict_pos = new_pos + direction * (speed * (self.sticky_bomb_duration-life_time) - (new_pos-start_pos):Length2D() + distance)
							local end_pos = World.GetGroundPosition(predict_pos)
							self:DrawAlert("techies_sticky_bomb", end_pos, 300, self.sticky_bomb_duration-0.01-life_time-0.01-0.1)
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
	if not self.enable:Get() or not self.show_destination:Get() then return end
	local alert_info = self.alerts_info[alert]
	if alert == "hoodwink_bushwhack" then
		local trees = table.combine(Trees.InRadius(position, radius+32, true), TempTrees.InRadius(position, radius+32))
		for _, tree in pairs(trees) do
			table.insert(self.drawings, {GameRules.GetGameTime() + duration + 0.1, alert, "circle_outlined", Entity.GetAbsOrigin(tree), radius, 10, Color(15, 255, 15)})
		end
	end
	return Particle.DrawAlert(position, radius, duration + 0.1, alert_info["color"] or Color(255, 255, 255), true)
end

return BaseScript(ShowMeMoreDestinations)