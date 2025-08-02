local ShowMeXP = {
	lvl_xp_table = {
		0,
		240,
		640,
		1160,
		1760,
		2440,
		3200,
		4000,
		4900,
		5900,
		7000,
		8200,
		9500,
		10900,
		12400,
		14000,
		15700,
		17500,
		19400,
		21400,
		23600,
		26000,
		28600,
		31400,
		34400,
		38400,
		43400,
		49400,
		56400,
		64400,
	},
}

function ShowMeXP:Init()
	self.menu = Menu.Create("Info Screen", "Main", "Heroes Overlay")

	self.menu_main = self.menu:Create("Main")

	self.menu_script = self.menu_main:Create("Show Me XP")

	self.enable = self.menu_script:Switch("Enable", false, "\u{f00c}")

	self.customization = self.menu_script:Label("Customize", "\u{f84c}")
	self.customization_gear = self.customization:Gear("Settings")

	self.bar_height = self.customization_gear:Slider("Height", 3, 12, 4, "%dpx")
	self.bar_height:Icon("\u{f07d}")

	self.xp_color_gradient_1 = self.customization_gear:ColorPicker("Gradient Start", Color(0, 255, 184, 123), "\u{f53f}")
	self.xp_color_gradient_2 = self.customization_gear:ColorPicker("Gradient End", Color(255, 255, 0, 255), "\u{f53f}")

	self.animation_speed = self.customization_gear:Slider("Animation Speed", 2, 10, 6)
	self.animation_speed:Icon("\u{f625}")

	self.max_lvl = self.menu_script:Slider("Maximum Level", 1, 30, 30)
	self.max_lvl:Icon("\u{e252}")

	self.enable:SetCallback(function(widget)
		local enabled = widget:Get()

		self.customization:Disabled(not enabled)
		self.max_lvl:Disabled(not enabled)
	end, true)

	self.experiences = {}
end

function ShowMeXP:OnUpdate()
	if not self.enable:Get() then
		return
	end

	local local_player = Players.GetLocal()
	local local_team = Entity.GetTeamNum(local_player)

	for _, hero in pairs(Heroes.GetAll()) do
		if Entity.GetTeamNum(hero) ~= local_team and not NPC.IsIllusion(hero) and not NPC.HasModifier(hero, "modifier_arc_warden_tempest_double") and not NPC.HasModifier(hero, "modifier_vengefulspirit_command_aura_illusion") and not NPC.HasModifier(hero, "modifier_monkey_king_fur_army_soldier") and Entity.GetClassName(hero) ~= "C_DOTA_Unit_SpiritBear" then
			local visible = NPC.IsVisible(hero)
			local alive = Entity.IsAlive(hero)
			self.experiences[hero] = self.experiences[hero] or {0, 0, 0, visible and alive, 0}

			if visible then
				local xp = Hero.GetCurrentXP(hero)
				local lvl = (table.find_index(self.lvl_xp_table, function(k, v)
					return v > xp
				end) or #self.lvl_xp_table + 1) - 1

				self.experiences[hero][1] = lvl < 30 and (xp - self.lvl_xp_table[lvl])/(self.lvl_xp_table[lvl+1] - self.lvl_xp_table[lvl]) or 1
				self.experiences[hero][2] = lvl
				self.experiences[hero][3] = NPC.GetHealthBarOffset(hero)
				self.experiences[hero][4] = visible and alive
			else
				self.experiences[hero][4] = visible and alive
			end
		end
	end
end

function ShowMeXP:OnDraw()
	if not self.enable:Get() then
		return
	end

	local dt = 0.005

	local bars_overlay = Menu.Find("Info Screen", "Main", "Heroes Overlay", "Main", "Bars Overlay", "Enable")
	local draw_mana_bar_widget = Menu.Find("Info Screen", "Main", "Heroes Overlay", "Main", "Bars Overlay", "Draw Mana")
	local draw_mana_bar = bars_overlay ~= nil and draw_mana_bar_widget ~= nil and bars_overlay:Get() and draw_mana_bar_widget:Get()

	local max_lvl = self.max_lvl:Get()
	local animation_speed = self.animation_speed:Get()

	local screen_size = Render.ScreenSize()

	for hero, info in pairs(self.experiences) do
		if info[4] and info[2] <= max_lvl then
			local origin = Entity.GetAbsOrigin(hero)
			local hbo = origin + Vector(0, 0, info[3])

			local xy, visible = Render.WorldToScreen(hbo)

			if visible then
				xy.x = xy.x - (67.5 * (screen_size.x / 2560))
				xy.y = xy.y - (19 * (screen_size.y / 1440))

				if draw_mana_bar then
					xy.y = xy.y + (6.5 * (screen_size.y / 1440))
				end

				if info[5] < info[1] then
					info[5] = math.min(info[5] + (info[1] - info[5]) * (1 - math.exp(-animation_speed * dt)), info[1])
				elseif info[5] > info[1] then
					info[5] = math.max(info[5] + (info[1] - info[5]) * (1 - math.exp(-animation_speed * dt)), info[1])
				end

				local width = 134 * (screen_size.x / 2560)
				local height = self.bar_height:Get() * (screen_size.y / 1080)

				Render.Gradient(xy, xy + Vec2(width * info[5], height), self.xp_color_gradient_1:Get(), self.xp_color_gradient_2:Get(), self.xp_color_gradient_1:Get(), self.xp_color_gradient_2:Get())
				Render.FilledRect(xy + Vec2(width, height), xy, Color(0, 0, 0, 65))
				Render.Rect(xy, xy + Vec2(width, height), Color(0, 0, 0), 0, Enum.DrawFlags.None, 1)
			end
		end
	end
end

local script = {}

setmetatable(script, {
	__index = function(_, key)
		local v = ShowMeXP[key]

		if type(v) == "function" then
			return function(firstArg, ...)
				if firstArg == script then
					return v(ShowMeXP, ...)
				else
					return v(ShowMeXP, firstArg, ...)
				end
			end
		else
			return v
		end
	end,

	__newindex = function(_, key, val)
		ShowMeXP[key] = val
	end,
})

if script.Init ~= nil then
	script:Init()
end

return script