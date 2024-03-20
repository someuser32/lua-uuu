require("libraries/__init__")

local ChargeSelector = class("ChargeSelector")

function ChargeSelector:initialize()
	self.path = {"Magma", "Utility", "Charge Selector"}

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.select_bind = UILib:CreateKeybind(self.path, "Select key", true)
	self.select_bind:SetTip("Selects unit under Spirit Breaker's charge")

	self.select_filter_only_heroes = UILib:CreateCheckbox({self.path, "Selection filter"}, "Only heroes", false)
	self.select_filter_only_heroes:SetIcon("~/MenuIcons/people.png")
	self.select_filter_only_own = UILib:CreateCheckbox({self.path, "Selection filter"}, "Only own units", true)
	self.select_filter_only_own:SetTip("Despite of this option, you cannot \"query unit\" (aka select units when you cannot control them)")
	self.select_filter_only_own:SetIcon("~/MenuIcons/helmet_g.png")

	UILib:SetTabIcon({self.path, "Selection filter"}, "~/MenuIcons/target_alt.png")

	self.auto_save_enable = UILib:CreateCheckbox({self.path, "Auto Save summons"}, "Enable", false)
	self.auto_save_enable:SetTip("If Spirit Breaker charges on your mass summon (like Broodmother spiders)")

	self.auto_save_position = UILib:CreateCombo({self.path, "Auto Save summons"}, "Position", {"Fastest", "Near camera", "Camera only"}, 2)
	self.auto_save_position:SetTip("[Fastest] Fastest near unit safe position\n[Near camera] Recommended. Try to find fastest safe position in camera bounds\n[Camera only] Full Overwatch Legit. Works as near camera, but if position not found it will NOT save unit")
	self.auto_save_position:SetIcon("~/MenuIcons/map_points.png")

	self.auto_save_position_angle = UILib:CreateCombo({self.path, "Auto Save summons"}, "Position angle search type", {"Away from cursor", "Away from hero forward"}, 2)
	self.auto_save_position_angle:SetIcon("~/MenuIcons/restart.png")

	self.auto_save_deselect = UILib:CreateCheckbox({self.path, "Auto Save summons"}, "Deselect unit", true)
	self.auto_save_deselect:SetTip("Removes saved unit from selection")
	self.auto_save_deselect:SetIcon("~/MenuIcons/collect.png")

	UILib:SetTabIcon({self.path, "Auto Save summons"}, "~/MenuIcons/group4.png")

	UILib:SetTabIcon(self.path, CAbility:GetAbilityNameIconPath("spirit_breaker_charge_of_darkness"))

	self.charge_modifier = "modifier_spirit_breaker_charge_of_darkness_vision"

	self.saving_unit = nil

	self.listeners = {}
end

function ChargeSelector:OnUpdate()
	if not self.enable then return end
	local tick = self:GetTick()
	if self.select_bind:IsActiveOnce() then
		local units = self.select_filter_only_heroes:Get() and CHero:GetAllies() or CNPC:GetAll()
		local localplayer = CPlayer:GetLocal()
		local localplayerid = CPlayer:GetLocalID()
		for _, unit in pairs(units) do
			if unit:HasModifier(self.charge_modifier) and unit:IsControllableByPlayer(localplayerid) and (not self.select_filter_only_own:Get() or unit:RecursiveGetOwner() == localplayer) then
				CPlayer:SetSelectedUnit(unit)
				break
			end
		end
	end
	if tick % 3 == 0 then
		if self.auto_save_enable:Get() then
			local localplayer = CPlayer:GetLocal()
			local localplayerid = CPlayer:GetLocalID()
			local saving = false
			for _, unit in pairs(CNPC:GetAll()) do
				if unit:HasModifier(self.charge_modifier) and unit:IsControllableByPlayer(localplayerid) and (not self.select_filter_only_own:Get() or unit:RecursiveGetOwner() == localplayer) and self:IsMassSummon(unit) then
					if saving_unit ~= unit then
						saving_unit = unit
						self:SaveUnit(unit)
					end
					saving = true
					break
				end
			end
			if not saving then
				saving_unit = nil
			end
		end
	end
end

function ChargeSelector:SaveUnit(unit)
	local position_option = self.auto_save_position:GetIndex()
	local angle_option = self.auto_save_position_angle:GetIndex()
	local position = unit:GetAbsOrigin()
	local angle_source = angle_option == 1 and (CInput:GetWorldCursorPos() - position):Normalized() or CHero:GetLocal():GetRotation():GetForward()
	if position_option == 1 then
		local best_positions = {}
		for i=-12, 12 do
			local angle = Angle(0, i*15, 0)
			local rotated_direction = unit:GetRotation():GetForward():Rotated(angle)
			local rotated_pos = CWorld:GetGroundPosition(position + rotated_direction * 600)
			if CGridNav:IsTraversable(rotated_pos) then
				local path_length = CGridNav:GetPathLength(position, rotated_pos)
				table.insert(best_positions, {rotated_pos, path_length, vector.angle_between_vectors((rotated_pos - position):Normalized(), angle_source), i})
			end
		end
		table.sort(best_positions, function(a, b)
			if math.min(a[3], b[3]) < 50 then
				return a[3] > b[3]
			end
			if a[2] ~= b[2] then
				return a[2] < b[2]
			end
			if math.abs(a[4]) ~= math.abs(b[4]) then
				return math.abs(a[4]) < math.abs(b[4])
			end
			if math.abs(math.abs(a[4]) - math.abs(b[4])) < 30 then
				return a[3] > b[3]
			end
			return a[4] < b[4]
		end)
		position = best_positions[1][1]
	end
	if self.auto_save_deselect:Get() then
		CPlayer:DeselectUnit(unit)
	end
	print(position)
	CMiniMap:Ping(position)
	unit:MoveTo(position)
	return true
end

function ChargeSelector:IsMassSummon(unit)
	if unit:IsHero() or not unit:HasModifier("modifier_kill") then
		return false
	end
	return true
end

return BaseScriptAPI(ChargeSelector)