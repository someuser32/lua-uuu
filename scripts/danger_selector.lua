require("libraries/__init__")

local DangerSelector = class("DangerSelector")

function DangerSelector:initialize()
	self.path = {"Magma", "Utility", "Danger Selector"}

	local danger_modifiers = {
		{"modifier_spirit_breaker_charge_of_darkness_vision", "spirit_breaker_charge_of_darkness", nil, true},
		{"modifier_dark_seer_ion_shell", "dark_seer_ion_shell", true, true},
	}

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.select_bind = UILib:CreateKeybind(self.path, "Select key", true)
	self.select_bind:SetTip("Selects units under danger effects")

	self.danger_modifiers = UILib:CreateMultiselect(self.path, "Danger effects", table.map(danger_modifiers, function(_, info) return {info[1], CAbility:GetAbilityNameIconPath(info[2]), info[4]} end))

	self.select_filter_unit_types = UILib:CreateCombo({self.path, "Selection filter"}, "Unit type", {"Heroes", "Non-heroes", "Both"}, 3)
	self.select_filter_unit_types:SetIcon("~/MenuIcons/people.png")
	self.select_filter_only_own = UILib:CreateCheckbox({self.path, "Selection filter"}, "Only own units", true)
	self.select_filter_only_own:SetTip("Despite of this option, you cannot \"query unit\" (aka select units when you cannot control them)")
	self.select_filter_only_own:SetIcon("~/MenuIcons/helmet_g.png")

	UILib:SetTabIcon({self.path, "Selection filter"}, "~/MenuIcons/target_alt.png")

	self.auto_save_enable = UILib:CreateCheckbox({self.path, "Auto Save summons"}, "Enable", false)
	self.auto_save_enable:SetTip("If your mass summon (like Broodmother spiders) applies with danger effect, it will automatically save him")

	self.auto_save_position = UILib:CreateCombo({self.path, "Auto Save summons"}, "Position", {"Fastest", "Near camera", "Camera only"}, 2)
	self.auto_save_position:SetTip("[Fastest] Fastest near unit safe position\n[Near camera] Recommended. Try to find fastest safe position in camera bounds\n[Camera only] Full Overwatch Legit. Works as near camera, but if position not found it will NOT save unit")
	self.auto_save_position:SetIcon("~/MenuIcons/map_points.png")

	self.auto_save_position_re_move = UILib:CreateCheckbox({self.path, "Auto Save summons"}, "Re-move after order", false)
	self.auto_save_position_re_move:SetTip("Recalculates and moves to new position saving unit when order")
	self.auto_save_position_re_move:SetIcon("~/MenuIcons/shuffle.png")
	self.auto_save_position_re_move_delay = UILib:CreateSlider({self.path, "Auto Save summons"}, "Re-move delay", 0, 0.5, 0.35)
	self.auto_save_position_re_move_delay:SetTip("Highly not recommended to set values below 0.2!")
	self.auto_save_position_re_move_delay:SetIcon("~/MenuIcons/Time/timer_def.png")

	self.auto_save_deselect = UILib:CreateCombo({self.path, "Auto Save summons"}, "Selection", {
		"Do nothing",
		"Deselect",
		"Deselect and prevent selection",
	}, 2)
	self.auto_save_deselect:SetIcon("~/MenuIcons/collect.png")

	UILib:SetTabIcon({self.path, "Auto Save summons"}, "~/MenuIcons/group4.png")

	UILib:SetTabIcon(self.path, "~/MenuIcons/target.png")

	self.saving_units = {}
	self.re_saving_units_timers = {}
	self.last_order_position = nil

	self.listeners = {}
end

function DangerSelector:OnUpdate()
	if not self.enable:Get() then return end
	local tick = self:GetTick()
	if self.select_bind:IsActiveOnce() then
		local localplayer = CPlayer:GetLocal()
		local localplayerid = CPlayer:GetLocalID()
		local units = table.values(table.filter(self.select_filter_unit_types:GetIndex() == 1 and CHero:GetAllies() or CNPC:GetAll(), function(_, unit)
			return unit:IsControllableByPlayer(localplayerid) and (not self.select_filter_only_own:Get() or unit:RecursiveGetOwner() == localplayer) and (not (self.select_filter_unit_types == 1 and not unit:IsHero())) and self:IsUnderDangerEffect(unit)
		end))
		if #units > 0 then
			CPlayer:SetSelectedUnit(units)
		end
	end
	if tick % 3 == 0 then
		if self.auto_save_enable:Get() then
			local localplayer = CPlayer:GetLocal()
			local localplayerid = CPlayer:GetLocalID()
			local saved_units = {}
			for _, unit in pairs(CNPC:GetAll()) do
				if unit:IsControllableByPlayer(localplayerid) and (not self.select_filter_only_own:Get() or unit:RecursiveGetOwner() == localplayer) and self:IsMassSummon(unit) then
					local entindex = unit:GetIndex()
					if self:IsUnderDangerEffect(unit) then
						table.insert(saved_units, entindex)
						if self.saving_units[entindex] == nil then
							self.saving_units[entindex] = self:SaveUnit(unit)
						end
					else
						if self.saving_units[entindex] ~= nil then
							self.saving_units[entindex] = nil
						end
					end
				end
			end
			if self.auto_save_deselect:GetIndex() == 3 then
				if #saved_units > 0 then
					local units = table.map(saved_units, function(_, entindex) return CNPC:FromIndex(entindex) end)
					CPlayer:DeselectUnit(units)
				end
			end
		end
	end
end

function DangerSelector:OnPrepareUnitOrders(order)
	if not self.enable:Get() then return true end
	if self.auto_save_enable:Get() then
		if table.contains({
			Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_DIRECTION,
			Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET,
			Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE,
			Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET,
		}, order["order"]) and (order["npc"] == nil or order["npc"] == CHero:GetLocal().ent) then
			self.last_order_position = order["position"]
			if self.auto_save_position_re_move:Get() then
				for entindex, saving_position in pairs(table.copy(self.saving_units)) do
					local unit = CNPC:FromIndex(entindex)
					if unit ~= nil and unit:IsAlive() then
						local position = unit:GetAbsOrigin()
						local angle_source = (self.last_order_position - saving_position):Normalized()
						local angle = vector.angle_between_vectors((saving_position - position):Normalized(), angle_source)
						local distance = (saving_position-self.last_order_position):Length2D()
						if angle < 90 or distance < 300 then
							local delta = self.auto_save_position_re_move_delay:Get()
							if self.re_saving_units_timers[entindex] ~= nil then
								delta = Timers:GetRemainingTime(self.re_saving_units_timers[entindex])
								Timers:RemoveTimer(self.re_saving_units_timers[entindex])
							end
							self.re_saving_units_timers[entindex] = Timers:CreateTimer(math.max(delta, 0.01), function()
								self.saving_units[entindex] = self:SaveUnit(unit)
								self.re_saving_units_timers[entindex] = nil
							end, self)
						end
					else
						self.saving_units[entindex] = nil
					end
				end
			end
		end
	end
	return true
end

function DangerSelector:SaveUnit(unit)
	local position_option = self.auto_save_position:GetIndex()
	local position = unit:GetAbsOrigin()
	local angle_source = self.last_order_position ~= nil and (self.last_order_position - position):Normalized() or CHero:GetLocal():GetRotation():GetForward()
	local best_positions = {}
	for i=-8, 8 do
		local angle = Angle(0, i*15, 0)
		local rotated_direction = unit:GetRotation():GetForward():Rotated(angle)
		local rotated_pos = CWorld:GetGroundPosition(position + rotated_direction * 600)
		if CGridNav:IsTraversable(rotated_pos) then
			table.insert(best_positions, {rotated_pos, CGridNav:GetPathDifficult(position, rotated_pos), vector.angle_between_vectors((rotated_pos - position):Normalized(), angle_source), nil, i})
		end
	end
	--[[
		1 - position
		2 - path difficulty (how much rotations)
		3 - angle between source
		4 - angle from camera
		5 - angle offset
	]]
	if position_option == 1 then
		table.sort(best_positions, function(a, b)
			if math.max(a[3], b[3]) > 150 then
				return a[3] < b[3]
			end
			if math.min(a[3], b[3]) < 70 then
				return a[3] > b[3]
			end
			if a[2] ~= b[2] then
				return a[2] < b[2]
			end
			if math.abs(a[5]) ~= math.abs(b[5]) then
				return math.abs(a[5]) > math.abs(b[5])
			end
			if math.abs(math.abs(a[5]) - math.abs(b[5])) < 30 then
				return a[3] > b[3]
			end
			return a[5] < b[5]
		end)
	elseif position_option == 2 or position_option == 3 then
		table.sort(best_positions, function(a, b)
			if math.max(a[3], b[3]) > 150 then
				return a[3] < b[3]
			end
			if math.min(a[3], b[3]) < 70 then
				return a[3] > b[3]
			end
			if a[2] ~= b[2] then
				return a[2] < b[2]
			end
			if math.abs(a[5]) ~= math.abs(b[5]) then
				return math.abs(a[5]) > math.abs(b[5])
			end
			if math.abs(math.abs(a[5]) - math.abs(b[5])) < 30 then
				return a[3] > b[3]
			end
			return a[5] < b[5]
		end)
	end
	position = best_positions[1][1]
	local deselection = self.auto_save_deselect:GetIndex()
	if deselection == 2 or deselection == 3 then
		CPlayer:DeselectUnit(unit)
	end
	unit:MoveTo(position, false, true, false)
	return position
end

function DangerSelector:IsMassSummon(unit)
	if unit:IsHero() or not unit:HasModifier("modifier_kill") then
		return false
	end
	return true
end

function DangerSelector:IsUnderDangerEffect(unit)
	for _, mod in pairs(self.danger_modifiers:Get()) do
		if unit:HasModifier(mod) then
			return true
		end
	end
	return false
end

return BaseScriptAPI(DangerSelector)