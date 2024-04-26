require("libraries/__init__")

local SpinWebRadius = class("SpinWebRadius")

function SpinWebRadius:initialize()
	local heroname = "npc_dota_hero_broodmother"

	self.spin_web_ability_name = "broodmother_spin_web"
	self.spin_web_unit_name = "npc_dota_broodmother_web"

	self.path = {"Magma", "Hero Specific", LocaleLib:LocalizeAttribute(KVLib:GetHeroAttribute(heroname)), LocaleLib:LocalizeHeroName(heroname), LocaleLib:LocalizeAbilityName(self.spin_web_ability_name).." Helper"}

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.editor_mode = UILib:CreateCheckbox({self.path, "Positions"}, "Editor mode", false)
	self.editor_mode:SetIcon("~/MenuIcons/edit.png")
	self.remove_key = UILib:CreateKeybind({self.path, "Positions"}, "Delete")
	self.remove_key:SetIcon("~/MenuIcons/delete.png")

	UILib:SetTabIcon({self.path, "Positions"}, "~/MenuIcons/map_points.png")

	UILib:SetTabIcon(self.path, CAbility:GetAbilityNameIconPath(self.spin_web_ability_name))

	self.spin_web_radius = 1300
	self.circle_radius = 24
	self.particles = {}
	self.positions = self:ReadPositions()

	self.listeners = {}
end

function SpinWebRadius:OnUpdate()
	if not self.enable:Get() then
		for entindex, fx in pairs(table.copy(self.particles)) do
			CParticleManager:Destroy(fx)
			self.particles[entindex] = nil
		end
		return
	end
	local tick = self:GetTick()
	if tick % 5 == 0 then
		if CHero:GetLocal():GetAbility(self.spin_web_ability_name) ~= nil then
			local units = {}
			for _, web in pairs(CNPC:GetAll()) do
				if web:GetUnitName() == self.spin_web_unit_name and self.particles[web:GetIndex()] == nil then
					local fx = CParticleManager:Create("materials/alert_range.vpcf", Enum.ParticleAttachment.PATTACH_WORLDORIGIN, nil)
					CParticleManager:SetControlPoint(fx, 0, web:GetAbsOrigin())
					CParticleManager:SetControlPoint(fx, 1, Vector(255, 255, 255))
					CParticleManager:SetControlPoint(fx, 2, Vector(self.spin_web_radius, 185, 0))
					CParticleManager:SetControlPoint(fx, 3, Vector(100, 0, 0))
					self.particles[web:GetIndex()] = fx
				end
			end
		end
		for entindex, fx in pairs(table.copy(self.particles)) do
			local web = CEntity:Get(entindex)
			if web == nil or not web:IsEntity() then
				CParticleManager:Destroy(fx)
				self.particles[entindex] = nil
			end
		end
	end
end

function SpinWebRadius:OnDraw()
	if not self.enable:Get() then return end
	local active_ability = CPlayer:GetActiveAbility()
	local cx, cy = CInput:GetCursorPos()
	local remove = self.remove_key:IsActiveOnce()
	if active_ability ~= nil and active_ability:GetName() == self.spin_web_ability_name then
		for _, pos in pairs(table.copy(self.positions)) do
			local position = CWorld:GetGroundPosition(pos)
			local x, y, visible = CRenderer:WorldToScreen(position)
			if visible then
				CRenderer:SetDrawColor(255, 255, 255, 255)
				CRenderer:DrawImageCentered(CRenderer:GetOrLoadImage(CAbility:GetAbilityNameIconPath(self.spin_web_ability_name)), x, y, self.circle_radius+4, self.circle_radius+4)
				if math.abs(x-cx) < self.circle_radius and math.abs(y-cy) < self.circle_radius then
					CRenderer:SetDrawColor(245, 5, 5, 255)
					if self.editor_mode:Get() and remove then
						self:DeletePosition(pos)
					end
				else
					CRenderer:SetDrawColor(5, 245, 245, 255)
				end
				CRenderer:DrawOutlineCircle(x, y, self.circle_radius, self.circle_radius*2)
			end
		end
	end
end

function SpinWebRadius:OnPrepareUnitOrders(order)
	if not self.enable:Get() then return true end
	if order["order"] == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION and order["ability"] ~= nil then
		local ability = CAbility:new(order["ability"])
		if ability:GetName() == self.spin_web_ability_name then
			local cx, cy, cvisible = CRenderer:WorldToScreen(order["position"])
			for _, pos in pairs(table.copy(self.positions)) do
				local position = CWorld:GetGroundPosition(pos)
				local x, y, visible = CRenderer:WorldToScreen(position)
				if math.abs(x-cx) < self.circle_radius and math.abs(y-cy) < self.circle_radius then
					if (order["position"]-position):Length2D() < 16 then
						return true
					end
					ability:Cast(position, false, true, false)
					return false
				end
			end
		end
	end
	return true
end

function SpinWebRadius:OnEntityCreate(entity)
	local ent = CEntity:new(entity)
	Timers:CreateTimer(0.01, function()
		if self.enable:Get() then
			if self.editor_mode:Get() then
				if ent:GetUnitName() == self.spin_web_unit_name then
					self:SavePosition(ent:GetAbsOrigin())
				end
			end
		end
	end, self)
end

function SpinWebRadius:SavePosition(position)
	local positions = table.values(json:decode(CConfig:ReadString("magma_spinwebradius", "positions", "{}")))
	table.insert(positions, {x=position.x, y=position.y})
	CConfig:WriteString("magma_spinwebradius", "positions", json:encode(positions))
	self.positions = self:ReadPositions()
end

function SpinWebRadius:DeletePosition(position)
	local positions = table.values(json:decode(CConfig:ReadString("magma_spinwebradius", "positions", "{}")))
	table.sort(positions, function(a, b) return (Vector(a["x"], a["y"], 0)-position):Length2D() < (Vector(b["x"], b["y"], 0)-position):Length2D() end)
	table.remove(positions, 1)
	CConfig:WriteString("magma_spinwebradius", "positions", json:encode(positions))
	self.positions = self:ReadPositions()
end

function SpinWebRadius:ReadPositions()
	return table.map(table.values(json:decode(CConfig:ReadString("magma_spinwebradius", "positions", "{}"))), function(_, pos) return Vector(pos["x"], pos["y"], 0) end)
end

return BaseScriptAPI(SpinWebRadius)