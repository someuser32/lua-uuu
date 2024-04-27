require("libraries/__init__")

local IPos = class("IPos")

function IPos:initialize()
	self.path = {"Magma", "Utility", "IPos"}

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)
	self.enable:SetTip("Shows useful positions on map:\n- Roshan blind spots\n- Fountain invis positions (you must be in invisibility)\n- Camp block helper")

	self.show_key = UILib:CreateCombo(self.path, "Show key", {
		"Ctrl",
		"Alt",
		"Always",
	}, 0)

	UILib:SetTabIcon(self.path, "~/MenuIcons/google_maps.png")

	self.positions = {
		-- top roshan
		Vector(-7333.53, 7582.62, 0.4375),
        Vector(-7463, 7417.81, 9.25),
        Vector(-7576.34, 7292.47, 8.0625),
		-- bot roshan
        Vector(7655.28, -7463.38, 7.625),
        Vector(7497.16, -7605.5, 6.3125),
        Vector(7360.06, -7783.78, 0),

		-- radiant invis fountain
		Vector(6360.78, 6198.5, 374.031),
		Vector(6726.31, 5830.59, 372.094),
		Vector(6489.22, 5981.31, 347.969),
		-- dire invis fountain
		Vector(-6878.84, -5855.91, 352.094),
		Vector(-6360.28, -6362.41, 349.219),
	}

	self.ward_positions = {
		-- radiant camps
        Vector(-2434.02, -4006.03, 256),
        Vector(-385.831, -1942.04, 256),
		Vector(140, -1942.04, 256),
        Vector(771.463, -3901.92, 256),
        Vector(3250.42, -2955, 128),
        Vector(4813.76, -3505.17, 128),
        Vector(3334.48, -5761.97, 128),
        Vector(4441.18, -7034.26, 128),
        Vector(3781.09, -8743.02, 128),
        Vector(-498.742, -7741.85, 0),
        Vector(-8765.33, 432.869, 257.958),
        Vector(-4916.79, 187.949, 256),
        Vector(-4139.94, 1290.67, 256),
        Vector(-2429.15, -8712.56, 256),
        Vector(1967.26, -8792.65, 128),
        Vector(-3499.83, 604.119, 256),
		-- dire camps
		Vector(-2740.5, 3322.12, 256),
        Vector(-1983.23, 3321.57, 256),
        Vector(-3206.1, 4500.16, 128),
        Vector(-5183.63, 4608.9, 0),
        Vector(-1023.58, 8405.63, 128),
        Vector(-1087.47, 5344.55, 128),
        Vector(-3903.05, 8739.46, 128),
        Vector(-4094.47, 7709.23, 128),
        Vector(830.039, 7743.44, 31.0197),
        Vector(2792.69, 8069.18, 256),
        Vector(1519.69, 4328.81, 128),
        Vector(15.6566, 2949.88, 128),
        Vector(4774.49, -256.136, 256),
        Vector(3003.78, -1528.9, 256),
        Vector(3656.65, -1452.33, 256),
        Vector(8724.8, -767.378, 256),
	}

	self.circle_radius = 10

	self.listeners = {}
end

function IPos:ShouldDraw()
	local option = self.show_key:Get()
	if option == "Always" then
		return true
	elseif option == "Ctrl" then
		return CInput:IsKeyDown(Enum.ButtonCode.KEY_LCONTROL)
	elseif option == "Alt" then
		return CInput:IsKeyDown(Enum.ButtonCode.KEY_LALT)
	end
	return false
end

function IPos:OnDraw()
	if not self.enable:Get() then return end
	local is_key_down = CInput:IsKeyDownOnce(Enum.ButtonCode.KEY_MOUSE1)
	local active_ability = CPlayer:GetActiveAbility()
	local cx, cy = CInput:GetCursorPos()
	if self:ShouldDraw() then
		for _, position in pairs(self.positions) do
			local x, y, visible = CRenderer:WorldToScreen(position)
			if visible then
				CRenderer:SetDrawColor(245, 245, 245, 255)
				CRenderer:DrawOutlineCircle(x, y, self.circle_radius, self.circle_radius*2)
				if is_key_down and math.abs(x-cx) < self.circle_radius and math.abs(y-cy) < self.circle_radius then
					local units = CPlayer:GetSelectedUnits()
					units[1]:MoveTo(position, false, true, true)
				end
			end
		end
	end
	if active_ability ~= nil then
		if (active_ability:GetName() == "item_ward_sentry") or (active_ability:GetName() == "item_ward_dispenser") then
			for _, position in pairs(self.ward_positions) do
				local x, y, visible = CRenderer:WorldToScreen(position)
				if visible then
					if math.abs(x-cx) < self.circle_radius and math.abs(y-cy) < self.circle_radius then
						CRenderer:SetDrawColor(245, 5, 5, 255)
					else
						CRenderer:SetDrawColor(5, 245, 245, 255)
					end
					CRenderer:DrawOutlineCircle(x, y, self.circle_radius, self.circle_radius*2)
				end
			end
		end
	end
end

return BaseScriptAPI(IPos)