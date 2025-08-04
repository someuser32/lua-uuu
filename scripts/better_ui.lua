local BetterUI = {
	panorama_elements = {
		{
			name = "Center",
			icon = "\u{f84d}",
			settings = {
				"scale", "opacity",
			},
			panel_path = {
				{"DotaHud", "Hud", "HUDElements", "lower_hud", "center_with_stats"},
				{"DotaHud", "Hud", "HUDElements", "lower_hud", "BuffContainer"},
			},
		},
		{
			name = "Scoreboard",
			icon = "\u{f0c9}",
			settings = {
				"scale",
				{
					name = "opacity",
					widget = function(self, parent, ctx)
						local widget = parent:Slider("Opacity", 0, 100, 100, "%d%%")
						widget:Icon("\u{f850}")
						return widget
					end,
					callback = function(self, widget, ctx)
						local opacity = self.enable:Get() and widget:Get() / 100 or 1.0
						local style = "opacity: " .. tostring(opacity) .. "; background-img-opacity: " .. tostring(opacity) .. "; background-color-opacity: " .. tostring(opacity) .. ";"

						local panel = Panorama.GetPanelByPath(ctx["panel_path"], self.DEBUG)

						if panel ~= nil then
							for i=0, panel:GetChildCount() - 1 do
								local child = panel:GetChild(i)
								if child ~= nil then
									child:SetStyle(style)

									if child:GetID() == "Background" then
										child:SetStyle("box-shadow: #00000000 0px 0px 8px 0px;")
									end
								end
							end
						end
					end,
				}
			},
			panel_path = {"DotaHud", "Hud", "HUDElements", "scoreboard"},
		},
		{
			name = "Topbar",
			icon = "\u{f855}",
			tooltip = "Does not work properly with Info Screen",
			settings = {
				"scale", "opacity",
			},
			panel_path = {"DotaHud", "Hud", "HUDElements", "topbar"},
		},
		{
			name = "Quickstats",
			icon = "\u{f648}",
			settings = {
				"scale", "opacity",
			},
			panel_path = {"DotaHud", "Hud", "HUDElements", "stackable_side_panels", "quickstats"},
		},
		{
			name = "Shop",
			icon = "\u{f54e}",
			settings = {
				"scale",
				{
					name = "opacity",
					widget = function(self, parent, ctx)
						local widget = parent:Slider("Opacity", 0, 100, 100, "%d%%")
						widget:Icon("\u{f850}")
						return widget
					end,
					callback = function(self, widget, ctx)
						local style = "opacity: " .. tostring(self.enable:Get() and widget:Get() / 100 or 1.0) .. ";"

						local panel_main = Panorama.GetPanelByPath(table.merge(ctx["panel_path"], {"Main"}), self.DEBUG)

						if panel_main ~= nil then
							panel_main:SetStyle(style)
						end

						local guides_button = Panorama.GetPanelByPath(table.merge(ctx["panel_path"], {"GuidesButton"}), self.DEBUG)

						if guides_button ~= nil then
							guides_button:SetStyle(style)
						end

						local guides_button_custom = Panorama.GetPanelByPath(table.merge(ctx["panel_path"], {"GuidesButtonCustom"}), self.DEBUG)

						if guides_button_custom ~= nil then
							guides_button_custom:SetStyle(style)
						end

						local guide_flyout_background = Panorama.GetPanelByPath(table.merge(ctx["panel_path"], {"GuideFlyout", "ItemsArea"}), self.DEBUG)

						if guide_flyout_background ~= nil then
							guide_flyout_background:SetStyle(style)
						end
					end,
				}
			},
			panel_path = {"DotaHud", "Hud", "HUDElements", "shop"},
		},
		{
			name = "Quickbuy",
			icon = "\u{e0dc}",
			settings = {
				"scale", "opacity",
			},
			panel_path = {"DotaHud", "Hud", "HUDElements", "lower_hud", "shop_launcher_block"},
		},
		{
			name = "Minimap",
			icon = "\u{f5a0}",
			tooltip = "Toggle \"Use Extra Large Minimap\" to fix Scan Glyph Info",
			settings = {
				"scale", "opacity",
			},
			panel_path = {"DotaHud", "Hud", "HUDElements", "minimap_container"},
		},
	},

	DEBUG = false,
}

function BetterUI:Init()
	self.menu = Menu.Create("Changer", "Main", "Better UI")
	self.menu:Icon("\u{e0cb}")

	self.menu_main = self.menu:Create("Main")

	self.menu_script = self.menu_main:Create("General")

	self.enable = self.menu_script:Switch("Enable", false, "\u{f00c}")

	self.settings = {}

	for _, element in pairs(self.panorama_elements) do
		self.settings[element["name"]] = self.settings[element["name"]] or {
			label = self.menu_script:Label(element["name"], element["icon"]),
			settings = {},
		}

		if element["tooltip"] ~= nil then
			self.settings[element["name"]]["label"]:ToolTip(element["tooltip"])
		end

		self.settings[element["name"]]["gear"] = self.settings[element["name"]]["label"]:Gear("Settings")

		for _, setting in pairs(element["settings"]) do
			if setting == "scale" then
				self.settings[element["name"]]["settings"][setting] = self.settings[element["name"]]["gear"]:Slider("Scale", 10, 200, 100, "%d%%")
				self.settings[element["name"]]["settings"][setting]:Icon("\u{f065}")
				self.settings[element["name"]]["settings"][setting.."_callback"] = function(widget)
					local panel = nil

					if type(element["panel_path"]) == "function" then
						panel = element["panel_path"]()
					elseif type(element["panel_path"]) == "table" then
						if type(element["panel_path"][1]) == "table" then
							panel = table.map(element["panel_path"], function(_, path) return Panorama.GetPanelByPath(path, self.DEBUG) end)
						else
							panel = Panorama.GetPanelByPath(element["panel_path"], self.DEBUG)
						end
					end

					if panel ~= nil then
						local style = "ui-scale: " .. tostring(self.enable:Get() and widget:Get() or 100) .. "%;"

						if type(panel) == "table" then
							for _, pan in pairs(panel) do
								pan:SetStyle(style)
							end
						else
							panel:SetStyle(style)
						end
					end
				end
				self.settings[element["name"]]["settings"][setting]:SetCallback(self.settings[element["name"]]["settings"][setting.."_callback"], true)
			elseif setting == "opacity" then
				self.settings[element["name"]]["settings"][setting] = self.settings[element["name"]]["gear"]:Slider("Opacity", 0, 100, 100, "%d%%")
				self.settings[element["name"]]["settings"][setting]:Icon("\u{f850}")
				self.settings[element["name"]]["settings"][setting.."_callback"] = function(widget)
					local panel = nil

					if type(element["panel_path"]) == "function" then
						panel = element["panel_path"]()
					elseif type(element["panel_path"]) == "table" then
						if type(element["panel_path"][1]) == "table" then
							panel = table.map(element["panel_path"], function(_, path) return Panorama.GetPanelByPath(path, self.DEBUG) end)
						else
							panel = Panorama.GetPanelByPath(element["panel_path"], self.DEBUG)
						end
					end

					if panel ~= nil then
						local style = "opacity: " .. tostring(self.enable:Get() and widget:Get() / 100 or 1.0) .. ";"

						if type(panel) == "table" then
							for _, pan in pairs(panel) do
								pan:SetStyle(style)
							end
						else
							panel:SetStyle(style)
						end
					end
				end
				self.settings[element["name"]]["settings"][setting]:SetCallback(self.settings[element["name"]]["settings"][setting.."_callback"], true)
			elseif type(setting) == "table" then
				self.settings[element["name"]]["settings"][setting["name"]] = setting["widget"](self, self.settings[element["name"]]["gear"], element)
			end
		end
	end

	for _, element in pairs(self.panorama_elements) do
		if self.settings[element["name"]] ~= nil then
			for _, setting in pairs(element["settings"]) do
				if type(setting) == "table" then
					if self.settings[element["name"]]["settings"][setting["name"]] ~= nil then
						self.settings[element["name"]]["settings"][setting["name"].."_callback"] = function(widget)
							if setting["callback"] ~= nil then
								return setting["callback"](self, widget, element)
							end
						end
						self.settings[element["name"]]["settings"][setting["name"]]:SetCallback(self.settings[element["name"]]["settings"][setting["name"].."_callback"], true)
					end
				end
			end
		end
	end

	self.enable:SetCallback(function(widget)
		local enabled = widget:Get()

		for _, element in pairs(self.panorama_elements) do
			if self.settings[element["name"]] ~= nil then
				self.settings[element["name"]]["label"]:Disabled(not enabled)

				for key, value in pairs(self.settings[element["name"]]["settings"]) do
					if string.endswith(key, "_callback") and type(value) == "function" then
						value(self.settings[element["name"]]["settings"][string.sub(key, 1, #key - #"_callback")])
					end
				end
			end
		end
	end, true)
end

local script = {}

setmetatable(script, {
	__index = function(_, key)
		local v = BetterUI[key]

		if type(v) == "function" then
			return function(firstArg, ...)
				if firstArg == script then
					return v(BetterUI, ...)
				else
					return v(BetterUI, firstArg, ...)
				end
			end
		else
			return v
		end
	end,

	__newindex = function(_, key, val)
		BetterUI[key] = val
	end,
})

if script.Init ~= nil then
	script:Init()
end

return script