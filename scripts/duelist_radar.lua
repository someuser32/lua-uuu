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

	self.draw_radius_on_visible_on = self.menu_script:MultiCombo("Show Visible Radius On", {"Local hero", "Allies"}, {"Local hero"})
	self.draw_radius_on_visible_on:Icon("\u{e533}")

	self.radius_type, self.radius_color, self.radiuses = table.unpack(RadiusManager:CreateUI(self.menu_script, true, true, true, true))

	self.enable:SetCallback(function(widget)
		local enabled = widget:Get()
		icon_label:Disabled(not enabled)
		self.show_on:Disabled(not enabled)
		self.draw_radius_on_visible_on:Disabled(not enabled)
		self.radiuses:Disabled(not enabled)
	end, true)

	self.radius_type:SetCallback(function(widget)
		local _type = widget:Get()+1
		for _, particle in pairs(self.particles) do
			self.particles[_] = RadiusManager:ChangeType(particle, _type)
		end
	end)

	self.radius_color:SetCallback(function(widget)
		local color = widget:Get()
		for _, particle in pairs(self.particles) do
			self.particles[_] = RadiusManager:ChangeColor(particle, color)
		end
	end)

	self.triggered_units = {}
	self.particles = {}
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
				local trigger = false
				local is_local = Entity.RecursiveGetOwner(hero) == localplayer
				if (not is_local and self.show_on:Get("Allies")) or (is_local and self.show_on:Get("Local hero")) then
					local modifier = NPC.GetModifier(hero, "modifier_item_duelist_gloves")
					if modifier then
						if Modifier.GetField(modifier, "actual_attack_speed", true) > 0 then
							trigger = true
						end
					end
				end
				if trigger then
					self.triggered_units[hero] = true
					local can_trigger = (not is_local and self.draw_radius_on_visible_on:Get("Allies")) or (is_local and self.draw_radius_on_visible_on:Get("Local hero"))
					if self.particles[hero] == nil and can_trigger then
						self.particles[hero] = RadiusManager:DrawParticle(self.radius_type:Get()+1, self.radius_color:Get(), 1200, hero)
					elseif self.particles[hero] ~= nil and not can_trigger then
						Particle.Destroy(self.particles[hero])
						self.particles[hero] = nil
					end
				else
					self.triggered_units[hero] = nil
					if self.particles[hero] ~= nil then
						Particle.Destroy(self.particles[hero])
						self.particles[hero] = nil
					end
				end
			end
		end
	end
end

return BaseScript(DuelistRadar)