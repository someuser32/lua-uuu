require("xlib/__init__")

local IPos = {}

function IPos:Init()
	self.menu = Menu.Create("Info Screen", "xScripts", "IPos")
	self.menu:Icon("")

	self.menu_main = self.menu:Create("Main")

	self.menu_settings = self.menu_main:Create("Settings")

	self.enable = self.menu_settings:Switch("Enable", false)
	self.enable:Icon("\u{f5a0}")
	self.enable:ToolTip("UPDATED AT: 04.05.24 (7.35d)")

	self.enable_gear = self.enable:Gear("Show Positions")
	self.enable_roshan_positions = self.enable_gear:Switch("Roshan", false)
	self.enable_roshan_positions:Icon("\u{f2a8}")
	self.enable_fountain_positions = self.enable_gear:Switch("Fountain", false)
	self.enable_fountain_positions:Icon("\u{f2a8}")
	self.enable_wards = self.enable_gear:Switch("Wards", true)
	self.enable_wards:Icon("\u{e4bf}")

	self.roshan_positions = {
		-- top
		Vector(-7333.53, 7582.62, 0.4375),
        Vector(-7463, 7417.81, 9.25),
        Vector(-7576.34, 7292.47, 8.0625),
		-- bot
        Vector(7655.28, -7463.38, 7.625),
        Vector(7497.16, -7605.5, 6.3125),
        Vector(7360.06, -7783.78, 0),
	}

	self.fountain_positions = {
		-- radiant
		Vector(6360.78, 6198.5, 374.031),
		Vector(6726.31, 5830.59, 372.094),
		Vector(6489.22, 5981.31, 347.969),
		-- dire
		Vector(-6878.84, -5855.91, 352.094),
		Vector(-6360.28, -6362.41, 349.219),
	}

	self.ward_positions = {
		["observer"] = {
			Vector(-1758, -8570, 239),
			Vector(2093, -8176, 128),
			Vector(4934, -8148, 128),
			Vector(6946, -6278, 128),
			Vector(1276, -5635, 256),
			Vector(-160, -5178, 384),
			Vector(-2102, -4616, 256),
			Vector(3436, -3382, 128),
			Vector(-2612, -3837, 256),
			Vector(-7374, -2818, 256),
			Vector(-5307, -1553, 256),
			Vector(-3511, -1760, 235),
			Vector(-4663, 376, 256),
			Vector(-7446, 621, 256),
			Vector(-2642, 275, 128),
			Vector(-3017, 1825, 128),
			Vector(-3088, 2777, 128),
			Vector(-1243, 1507, 128),
			Vector(3217, -2453, 0),
			Vector(4487, -1926, 128),
			Vector(7681, -2623, 256),
			Vector(8580, -590, 256),
			Vector(5102, -303, 256),
			Vector(7136, 1783, 256),
			Vector(7163, 2214, 256),
			Vector(4604, 2806, 256),
			Vector(3008, 4893, 256),
			Vector(3044, 6609, 256),
			Vector(-2827, 3286, 256),
			Vector(-1677, 5412, 256),
			Vector(-1032, 4812, 256),
			Vector(-726, 5146, 256),
			Vector(57, 4672, 128),
			Vector(438, 2329, 128),
			Vector(-304, 1528, 128),
			Vector(-7180, 6178, 128),
			Vector(-5152, 7754, 128),
			Vector(15, 8793, 512),
			Vector(521, 8793, 512),
			Vector(-7397, 2337, 256),
			Vector(304, -2056, 256),
			Vector(5408, -2553, 128),
			Vector(-1955, 2020, 128),
			Vector(-7470, 4415, 128),
			Vector(-1269, 2536, 256),
			Vector(853, 6042, 128),
			Vector(1102, 1442, 128),
			Vector(2522, 4797, 128),
			Vector(-4909, 2329, 128),
			Vector(-6650, 3091, 128),
			Vector(1766, -1074, 256),
			-- requires tree cut
			Vector(-3313, 2302, 128),
			Vector(-3331, 2042, 256),
			Vector(3595, -1580, 256),
		},
		["sentry"] = {
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
	}

	self.circle_radius = 10

	self.is_mouse_down = false
	self.mouse_position = Vec2(0, 0)
end

function IPos:DrawPosition(position, color, color_hover, can_move)
	local screen_position, visible = Render.WorldToScreen(position)
	if not visible then return end
	local is_hover = math.abs(screen_position.x-self.mouse_position.x) < self.circle_radius and math.abs(screen_position.y-self.mouse_position.y) < self.circle_radius
	if color_hover ~= nil and is_hover then
		color = color_hover
	end
	Render.Circle(screen_position, self.circle_radius, color, nil, nil, nil, nil, self.circle_radius*2)
	if can_move then
		if self.is_mouse_down and is_hover then
			local units = Player.GetSelectedUnits(Players.GetLocal())
			NPC.MoveTo(units[1], position, Input.IsKeyDown(Enum.ButtonCode.KEY_LSHIFT), true, true, false)
		end
	end
end

function IPos:OnDraw()
	if not self.enable:Get() then return end
	local localplayer = Players.GetLocal()
	local active_ability = Player.GetActiveAbility(localplayer)
	self.mouse_position = Vec2(Input.GetCursorPos())
	self.is_mouse_down = Input.IsKeyDownOnce(Enum.ButtonCode.KEY_MOUSE1)
	if self.enable_roshan_positions:Get() then
		for _, position in pairs(self.roshan_positions) do
			self:DrawPosition(position, Color(245, 245, 245, 255), nil, true)
		end
	end
	if self.enable_fountain_positions:Get() then
		for _, position in pairs(self.roshan_positions) do
			self:DrawPosition(position, Color(245, 245, 245, 255), nil, true)
		end
	end
	if self.enable_wards:Get() and active_ability ~= nil then
		local ability_name = Ability.GetName(active_ability)
		if ability_name == "item_ward_dispenser" then
			ability_name = Ability.GetToggleState(active_ability) and "item_ward_observer" or "item_ward_sentry"
		end
		if ability_name == "item_ward_observer" then
			for _, position in pairs(self.ward_positions["observer"]) do
				self:DrawPosition(position, Color(245, 245, 5, 255), Color(245, 5, 5, 255), false)
			end
		elseif ability_name == "item_ward_sentry" then
			for _, position in pairs(self.ward_positions["sentry"]) do
				self:DrawPosition(position, Color(5, 245, 245, 255), Color(245, 5, 5, 255), false)
			end
		end
	end
end

return BaseScript(IPos)