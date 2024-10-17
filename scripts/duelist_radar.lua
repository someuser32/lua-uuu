require("xlib/__init__")

local DuelistRadar = {}

function DuelistRadar:Init()
	self.icons = Render.LoadFont("FontAwesomeEx", Enum.FontCreate.FONTFLAG_ANTIALIAS + Enum.FontCreate.FONTFLAG_DROPSHADOW, 0)

	self.menu = Menu.Create("Info Screen", "Main", "Show Me More")

	self.menu_main = self.menu:Create("xScripts")
	self.menu_main:Icon("\u{e12e}")

	self.menu_script = self.menu_main:Create("Duelist Radar")

	self.enable = self.menu_script:Switch("Enable", false)
	self.enable:Icon("\u{f00c}")
	self.enable:ToolTip("Indicates if there are any enemy heroes within 1200 radius")

	local icon_label = self.menu_script:Label("Icon")
	icon_label:Icon("\u{f03e}")
	self.icon_settings = icon_label:Gear("Settings")

	self.icon_size = self.icon_settings:Slider("Size", 14, 36, 24, function(value) return tostring(value).."px" end)
	self.icon_size:Icon("\u{e0a0}")
	self.icon_color = self.icon_settings:ColorPicker("Color", Color(255, 255, 255, 255))
	self.icon_color:Icon("\u{f53f}")
	self.icon_offset_x = self.icon_settings:Slider("Offset X", -150, 150, 0)
	self.icon_offset_x:Icon("\u{f89c}")
	self.icon_offset_y = self.icon_settings:Slider("Offset Y", -150, 150, 0)
	self.icon_offset_y:Icon("\u{f89d}")

	self.show_on = self.menu_script:MultiCombo("Show On", {"Local hero", "Allies"}, {"Local hero"})
	self.show_on:Icon("\u{e533}")

	self.enable:SetCallback(function(widget)
		local enabled = widget:Get()
		self.icon_settings:Disabled(not enabled)
	end, true)

	self.triggered_units = {}
end

function DuelistRadar:OnDraw()
	for unit, _ in pairs(self.triggered_units) do
		local position = Entity.GetAbsOrigin(unit)
		position.z = position.z + NPC.GetHealthBarOffset(unit)
		local xy, visible = Render.WorldToScreen(position)
		if visible then
			xy.x = xy.x + self.icon_offset_x:Get()
			xy.y = xy.y - 36 + self.icon_offset_y:Get()
			local size = Render.TextSize(self.icons, self.icon_size:Get(), "\u{e024}")
			Render.Text(self.icons, self.icon_size:Get(), "\u{e024}", xy - Vec2(size.x/2, size.y/2), self.icon_color:Get())
		end
	end
end

function DuelistRadar:OnUpdate()
	if not self.enable:Get() then return end
	local tick = Tick()
	if tick % 3 == 0 then
		local localplayer = Players.GetLocal()
		local localteam = Players.GetLocalTeam()
		for _, hero in pairs(Heroes.GetAll()) do
			if Entity.GetTeamNum(hero) == localteam then
				local is_local = Entity.RecursiveGetOwner(hero) == localplayer
				if (not is_local and self.show_on:Get("Allies")) or (is_local and self.show_on:Get("Local hero")) then
					local modifier = NPC.GetModifier(hero, "modifier_item_duelist_gloves")
					if modifier then
						local has_enemy = Modifier.GetField(modifier, "actual_attack_speed", true) > 0
						self.triggered_units[hero] = has_enemy or nil
					elseif self.triggered_units[hero] then
						self.triggered_units[hero] = nil
					end
				elseif self.triggered_units[hero] then
					self.triggered_units[hero] = nil
				end
			end
		end
	end
end

return BaseScript(DuelistRadar)