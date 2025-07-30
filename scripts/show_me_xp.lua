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
	self.menu = Menu.Create("Info Screen", "Main", "Show Me XP")
	self.menu:Icon("\u{e02f}")

	self.menu_main = self.menu:Create("Main")

	self.menu_script = self.menu_main:Create("General")

	self.enable = self.menu_script:Switch("Enable", false, "\u{f00c}")

	self.xp_color_gradient_1 = self.menu_script:ColorPicker("Gradient Start", Color(0, 255, 184, 123), "\u{f53f}")
	self.xp_color_gradient_2 = self.menu_script:ColorPicker("Gradient End", Color(255, 255, 0, 255), "\u{f53f}")

	self.experiences = {}
end

function ShowMeXP:OnUpdate()
	if not self.enable:Get() then
		return
	end

	local local_player = Players.GetLocal()
	local local_team = Entity.GetTeamNum(local_player)

	for _, hero in pairs(Heroes.GetAll()) do
		if Entity.GetTeamNum(hero) ~= local_team then
			local visible = NPC.IsVisible(hero)
			self.experiences[hero] = self.experiences[hero] or {0, 0, visible, 0}

			if visible then
				local xp = Hero.GetCurrentXP(hero)
				local lvl = (table.find_index(self.lvl_xp_table, function(k, v)
					return v > xp
				end) or #self.lvl_xp_table + 1) - 1

				self.experiences[hero][1] = lvl < 30 and (xp - self.lvl_xp_table[lvl])/(self.lvl_xp_table[lvl+1] - self.lvl_xp_table[lvl]) or 1
				self.experiences[hero][2] = NPC.GetHealthBarOffset(hero)
				self.experiences[hero][3] = visible
			else
				self.experiences[hero][3] = visible
			end
		end
	end
end

function ShowMeXP:OnDraw()
	if not self.enable:Get() then
		return
	end

	local dt = 0.005

	local draw_mana_bar_widget = Menu.Find("Info Screen", "Main", "Heroes Overlay", "Main", "Bars Overlay", "Draw Mana")
	local draw_mana_bar = draw_mana_bar_widget ~= nil and draw_mana_bar_widget:Get()

	for hero, info in pairs(self.experiences) do
		if info[3] then
			local origin = Entity.GetAbsOrigin(hero)
			local hbo = origin + Vector(0, 0, info[2])

			local xy, visible = Render.WorldToScreen(hbo)

			if visible then
				xy.x = xy.x - 68
				xy.y = xy.y - 19

				if draw_mana_bar then
					xy.y = xy.y + 7
				end

				if info[4] < info[1] then
					info[4] = math.min(info[4] + (info[1] - info[4]) * (1 - math.exp(-6 * dt)), info[1])
				elseif info[4] > info[1] then
					info[4] = math.max(info[4] + (info[1] - info[4]) * (1 - math.exp(-6 * dt)), info[1])
				elseif info[5] ~= nil then
					info[5] = nil
				end

				Render.Gradient(xy, xy + Vec2(134 * info[4], 7), self.xp_color_gradient_1:Get(), self.xp_color_gradient_2:Get(), self.xp_color_gradient_1:Get(), self.xp_color_gradient_2:Get())
				Render.FilledRect(xy + Vec2(134, 7), xy, Color(0, 0, 0, 65))
				Render.Rect(xy, xy + Vec2(134, 7), Color(0, 0, 0), 0, Enum.DrawFlags.None, 1)
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