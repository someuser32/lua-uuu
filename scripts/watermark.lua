if XHelpers.xmath.ease_out_progress == nil then

---@param value number
---@param target number
---@param speed number
---@param error number? @default: 1
---@return number
function XHelpers.xmath.ease_out_progress(value, target, speed, error)
    error = error or 1

    if math.abs(value - target) < error then
        return target
    end

    local eased = 1 - math.exp(-speed * GlobalVars.GetAbsFrameTime())
    eased = 1 - (1 - eased) * (1 - eased)

    local result = value + (target - value) * eased
    return result > value and math.min(result, target) or math.max(result, target)
end

end

---@class Watermark
local Watermark = {
	logo = {
		Render.LoadImage("https://i.imgur.com/ualjUxr.png"),
		Render.LoadImage("~/MenuIcons/UmbIcon.png"),
		nil,
	},

	avatar = UserInfo.avatar_url ~= "null" and Render.LoadImage(UserInfo.avatar_url) or 0,

	---@diagnostic disable-next-line: param-type-mismatch
	font = Render.LoadFont("Cascadia Code", Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.NORMAL),

	---@diagnostic disable-next-line: param-type-mismatch
	font_logo = Render.LoadFont("MuseoSansEx", Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.BOLD),

	color_settings = {
		{
			name = "background",
			default = "additional_background",
			icon = "\u{f2d0}",
		},
		-- {
		-- 	name = "background_shadow",
		-- 	default = "shadow",
		-- },
		{
			name = "text",
			default = "primary_second_tab_text",
			icon = "\u{f893}",
		},
		{
			name = "logo",
			default = "primary",
			icon = "\u{f1b2}",
		},
		{
			name = "icons",
			default = "primary",
			icon = "\u{f86d}",
		},
		{
			name = "alternative",
			default = "indication_inactive",
			icon = "\u{f576}",
		},
		{
			name = "pre_alternative",
			default = Color(213, 164, 137),
			icon = "\u{f576}",
		},
	},

	net_graph_convar = "dota_hud_netgraph",

	net_graph_path = {"DotaHud", "Hud", "HUDElements", "NetGraph"},
	net_graph_fps_path = {"DotaHud", "Hud", "HUDElements", "NetGraph", "RightColumn_1", "NetGraph_FPS"},
	net_graph_ping_path = {"DotaHud", "Hud", "HUDElements", "NetGraph", "RightColumn_2", "NetGraph_PING"},
	net_graph_loss_in_path = {"DotaHud", "Hud", "HUDElements", "NetGraph", "RightColumn_1", "NetGraph_LOSS_IN"},
	net_graph_loss_out_path = {"DotaHud", "Hud", "HUDElements", "NetGraph", "RightColumn_2", "NetGraph_LOSS_OUT"},

	time_format_tooltip = [[%a	abbreviated weekday name (e.g., Wed)
%A	full weekday name (e.g., Wednesday)
%b	abbreviated month name (e.g., Sep)
%B	full month name (e.g., September)
%c	date and time (e.g., 09/16/98 23:48:10)
%d	day of the month (16) [01-31]
%H	hour, using a 24-hour clock (23) [00-23]
%I	hour, using a 12-hour clock (11) [01-12]
%M	minute (48) [00-59]
%m	month (09) [01-12]
%p	either "am" or "pm" (pm)
%S	second (10) [00-61]
%w	weekday (3) [0-6 = Sunday-Saturday]
%x	date (e.g., 09/16/98)
%X	time (e.g., 23:48:10)
%Y	full year (1998)
%y	two-digit year (98) [00-99]
%%	the character "%"]]
}

---@param d1 integer
---@param d2 integer
---@return string
local function pretty_timedelta(d1, d2)
	if d2 >= 3786894000 then
		return "never"
	end

	local delta = os.difftime(d2, d1)

	if delta > 60 then
		delta = delta / 60

		if delta > 60 then
			delta = delta / 60

			if delta > 24 then
				delta = delta / 24

				return tostring(math.floor(delta)) .. " days"
			end

			return tostring(math.floor(delta)) .. " hours"
		end

		return tostring(math.floor(delta)) .. " minutes"
	end

	return tostring(delta) .. " seconds"
end

---@param mmr number
---@return number
local function mmr_to_rank_tier(mmr)
	if mmr >= 5620 then
		return 80
	elseif mmr >= 5420 then
		return 75
	elseif mmr >= 5220 then
		return 74
	elseif mmr >= 5020 then
		return 73
	elseif mmr >= 4820 then
		return 72
	elseif mmr >= 4620 then
		return 71
	elseif mmr >= 4466 then
		return 65
	elseif mmr >= 4312 then
		return 64
	elseif mmr >= 4158 then
		return 63
	elseif mmr >= 4004 then
		return 62
	elseif mmr >= 3850 then
		return 61
	elseif mmr >= 3696 then
		return 55
	elseif mmr >= 3542 then
		return 54
	elseif mmr >= 3388 then
		return 53
	elseif mmr >= 3234 then
		return 52
	elseif mmr >= 3080 then
		return 51
	elseif mmr >= 2926 then
		return 45
	elseif mmr >= 2772 then
		return 44
	elseif mmr >= 2618 then
		return 43
	elseif mmr >= 2464 then
		return 42
	elseif mmr >= 2310 then
		return 41
	elseif mmr >= 2156 then
		return 35
	elseif mmr >= 2002 then
		return 34
	elseif mmr >= 1848 then
		return 33
	elseif mmr >= 1694 then
		return 32
	elseif mmr >= 1540 then
		return 31
	elseif mmr >= 1386 then
		return 25
	elseif mmr >= 1232 then
		return 24
	elseif mmr >= 1078 then
		return 23
	elseif mmr >= 924 then
		return 22
	elseif mmr >= 770 then
		return 21
	elseif mmr >= 616 then
		return 15
	elseif mmr >= 462 then
		return 14
	elseif mmr >= 308 then
		return 13
	elseif mmr >= 154 then
		return 12
	elseif mmr > 0 then
		return 11
	end

	return 0
end

function Watermark:Init()
	self.menu = Menu.Create("Changer", "Main", "Watermark")
	self.menu:Icon("\u{f641}")

	self.menu_main = self.menu:Create("Main")

	self.menu_script = self.menu_main:Create("General")

	self.enable = self.menu_script:Switch("Enable", false, "\u{f00c}")

	self.enable_gear = self.enable:Gear("Settings")

	self.scale = self.enable_gear:Combo("Scale", ZHelpers.menu_scale_table_string, ZHelpers.menu_scale_table[100] - 1)
	self.scale:Icon("\u{f065}")

	self.watermark_items = self.menu_script:MultiCombo("Items", {"Logo", "Framerate", "Latency", "Loss", "Username", "MMR", "Subscription", "Time", "Avatar"}, {"Logo", "Framerate", "Latency"})
	self.watermark_items:Icon("\u{f0c9}")

	self.watermark_items_gear = self.watermark_items:Gear("Settings")

	self.watermark_items_logo = self.watermark_items_gear:Combo("Logo", {"Default", "Alternative", "UC"})
	self.watermark_items_logo:Icon("\u{f1b2}")

	self.watermark_items_mmr_use_rank_icon = self.watermark_items_gear:Combo("MMR icon", {"Trophy", "Ranks"})
	self.watermark_items_mmr_use_rank_icon:Icon("\u{f03e}")
	self.watermark_items_hide_mmr_in_game = self.watermark_items_gear:Switch("Hide MMR during match", true, "\u{f091}")

	self.watermark_items_time_format = self.watermark_items_gear:Input("Time format", "%H:%M", "\u{e1bd}")
	self.watermark_items_time_format:ToolTip(self.time_format_tooltip)

	self.watermark_items_menu_same = self.watermark_items_gear:Switch("Same with opened menu", true, "\u{e24e}")
	self.watermark_items_menu = self.watermark_items_gear:MultiCombo("Items with menu", {"Logo", "Framerate", "Latency", "Loss", "Username", "MMR", "Subscription", "Time", "Avatar"}, {})
	self.watermark_items_menu:Icon("\u{f0c9}")
	self.watermark_items_time_format_menu = self.watermark_items_gear:Input("Time format with menu", "%H:%M", "\u{e1bd}")
	self.watermark_items_time_format_menu:ToolTip(self.time_format_tooltip)

	self.custom_colors = self.menu_script:Label("Custom Colors", "\u{f53f}")

	self.custom_colors_gear = self.custom_colors:Gear("Settings")

	self.custom_color_settings = {}

	for _, setting in pairs(self.color_settings) do
		self.custom_color_settings[setting["name"]] = {}

		self.custom_color_settings[setting["name"]]["enable"] = self.custom_colors_gear:Switch(setting["title"] or string.capitalize(string.gsub(setting["name"], "_", " ")), false, setting["icon"])
		self.custom_color_settings[setting["name"]]["color"] = self.custom_color_settings[setting["name"]]["enable"]:ColorPicker("Color", setting["default"])

		self.custom_color_settings[setting["name"]]["enable"]:SetCallback(function(widget)
			self.custom_color_settings[setting["name"]]["color"]:Visible(widget:Get())
		end, true)
	end

	self.watermark_items_logo:SetCallback(function(widget)
		local value = widget:Get() + 1

		if self.custom_color_settings["logo"] ~= nil then
			self.custom_color_settings["logo"]["enable"]:Disabled(value ~= 3)
		end
	end, true)

	self.watermark_items_menu_same:SetCallback(function(widget)
		local enabled = widget:Get()

		self.watermark_items_menu:Visible(not enabled)
		self.watermark_items_time_format_menu:Visible(not enabled)
	end, true)

	self.watermark_items:SetCallback(function(widget)
		self.watermark_items_hide_mmr_in_game:Disabled(not widget:Get("MMR"))
		self.watermark_items_time_format:Disabled(not widget:Get("Time"))
	end, true)

	self.watermark_items_menu:SetCallback(function(widget)
		self.watermark_items_time_format_menu:Disabled(not widget:Get("Time"))
	end, true)

	self.items_order = {"Logo", "Framerate", "Latency", "Loss", "Username", "MMR", "Subscription", "Time", "Avatar"}

	self.animation_width_progress = 1
	self.animation_width_progress_start = 0
	self.animation_width_value = nil
	self.animation_width_items = {}

	self.drag_hover = false
	self.dragging_item = nil
	self.dragging_start_cursor_item = nil
	self.dragged_item, self.dragged_item_pos = nil, nil

	self.fps = 0
	self.ping = 0
	self.loss_in = 0
	self.loss_out = 0
	self.mmr = 0
	self.mmr_diff = 0
	self.subscription_left = ""

	self.fps_history = {}
	self.fps_drop = 0
	self.has_loss_time = -1
	self.has_ping_time = -1
	self.is_in_game = false
	self.game_state = Enum.GameState.DOTA_GAMERULES_STATE_INIT

	self.net_graph_convar_ref = nil
	self.net_graph_convar_user_value = nil

	self.net_graph_panel = nil
	self.net_graph_fps_panel = nil
	self.net_graph_ping_panel = nil
	self.net_graph_loss_in_panel = nil
	self.net_graph_loss_out_panel = nil
end

function Watermark:OnGameThreadInit()
	if type(db["x"]) ~= "userdata" then
		db["x"] = {}
	end

	if type(db["x"]["watermark"]) ~= "userdata" then
		db["x"]["watermark"] = {}
	end

	local mmr = Engine.GetMMRV2()
	local steamid = GC.GetSteamID()

	if db["x"]["watermark"]["mmr"] ~= nil and db["x"]["watermark"]["steam_id"] == steamid then
		self.mmr_diff = mmr - db["x"]["watermark"]["mmr"]
	end

	db["x"]["watermark"]["mmr"] = mmr
	db["x"]["watermark"]["steam_id"] = steamid

	if type(db["x"]["watermark"]["items_order"]) ~= "userdata" then
		db["x"]["watermark"]["items_order"] = self.items_order
	else
		local actual_items = XHelpers.xtable.to_keys(self.items_order)
		local update_db = false

		local items_order = {}
		local db_items = {}

		---@diagnostic disable-next-line: param-type-mismatch
		for _, item in ipairs(db["x"]["watermark"]["items_order"]) do
			if actual_items[item] then
				table.insert(items_order, item)
				db_items[item] = true
			else
				update_db = true
			end
		end

		for _, item in pairs(self.items_order) do
			if not db_items[item] then
				table.insert(items_order, _, item)

				update_db = true
			end
		end

		if update_db then
			db["x"]["watermark"]["items_order"] = items_order
		end

		self.items_order = items_order
	end

	self.net_graph_convar_ref = ConVar.Find(self.net_graph_convar)
	self.game_state = GameRules.GetGameState()

	self.mmr = mmr

	self.enable:SetCallback(function(widget)
		local enabled = widget:Get()

		self.enable_gear:Visible(enabled)
		self.watermark_items:Disabled(not enabled)
		self.watermark_items_gear:Visible(enabled)
		self.custom_colors:Disabled(not enabled)
		self.custom_colors_gear:Visible(enabled)

		local net_graph_panel = Panorama.GetPanelByPath(self.net_graph_path)
		if net_graph_panel ~= nil then
			net_graph_panel:SetStyle(enabled and "opacity: 0.0;" or "opacity: 1.0;")
		end

		if not enabled then
			if self.net_graph_convar_ref ~= nil then
				if self.net_graph_convar_user_value == false then
					ConVar.SetBool(self.net_graph_convar_ref, self.net_graph_convar_user_value)
				end

				self.net_graph_convar_user_value = nil
			end
		end
	end, true)

	if not self.enable:Get() then
		return
	end

	self:UpdateMetrics()
end

function Watermark:OnPreReload()
	if type(db["x"]) ~= "userdata" then
		db["x"] = {}
	end

	if type(db["x"]["watermark"]) ~= "userdata" then
		db["x"]["watermark"] = {}
	end

	db["x"]["watermark"]["items_order"] = self.items_order

	local net_graph_panel = Panorama.GetPanelByPath(self.net_graph_path)
	if net_graph_panel ~= nil then
		net_graph_panel:SetStyle("opacity: 1.0;")
	end

	if self.net_graph_convar_ref ~= nil then
		if self.net_graph_convar_user_value == false then
			ConVar.SetBool(self.net_graph_convar_ref, self.net_graph_convar_user_value)
		end
	end
end

---@param data OnGameRulesStateChangeData
function Watermark:OnGameRulesStateChange(data)
	self.game_state = data.new_state
end

function Watermark:OnGameEnd()
	if not Engine.IsInGame() then
		local mmr = Engine.GetMMRV2()

		self.mmr_diff = mmr - self.mmr
		self.mmr = mmr

		db["x"]["watermark"]["mmr"] = mmr
	end
end

---@param data OnKeyEventData
function Watermark:OnKeyEvent(data)
	if not self.enable:Get() then
		return true
	end

	if data.event == Enum.EKeyEvent.EKeyEvent_KEY_DOWN and data.key == Enum.ButtonCode.KEY_MOUSE1 then
		if self.drag_hover then
			return false
		end
	end

	return true
end

function Watermark:OnUpdateEx()
	local enabled = self.enable:Get()

	if self.net_graph_convar_ref == nil then
		self.net_graph_convar_ref = ConVar.Find(self.net_graph_convar)

		local net_graph_panel = Panorama.GetPanelByPath(self.net_graph_path)
		if net_graph_panel ~= nil then
			net_graph_panel:SetStyle(enabled and "opacity: 0.0;" or "opacity: 1.0;")
		end

		if self.net_graph_convar_ref ~= nil then
			if self.net_graph_convar_user_value == nil then
				self.net_graph_convar_user_value = ConVar.GetBool(self.net_graph_convar_ref)
			end

			if not enabled then
				if self.net_graph_convar_user_value == false then
					ConVar.SetBool(self.net_graph_convar_ref, self.net_graph_convar_user_value)
				end

				self.net_graph_convar_user_value = nil
			end
		end
	end

	if not enabled then
		return
	end

	if XHelpers.UpdateTick() % 10 == 0 then
		self:UpdateMetrics()
	end
end

function Watermark:OnFrame()
	if not self.enable:Get() then
		return
	end

	local screen_size = Render.ScreenSize()
	local screen_scale_x = screen_size.x / 1920
	local screen_scale_y = screen_size.y / 1080

	local scale = ZHelpers.menu_scale_table[self.scale:Get() + 1] / 100

	local now = os.clock()

	local colors = self:GetColors()

	local bg_color = colors["background"]
	-- local bg_shadow_color = colors["background_shadow"]
	local text_color = colors["text"]
	text_color.a = 255
	local logo_accent_color = colors["logo"]
	local icon_color = colors["icons"]
	icon_color.a = 255
	local alternative_color = colors["alternative"]
	alternative_color.a = 255
	local pre_alternative_color = colors["pre_alternative"]
	pre_alternative_color.a = 255

	local logo_size = 18 * screen_scale_y * scale
	local logo_text_size = 16 * screen_scale_y * scale
	local avatar_size = 22 * screen_scale_y * scale
	local icon_size = 12 * screen_scale_y * scale
	local icon_large_size = 18 * screen_scale_y * scale
	local font_size = 12 * screen_scale_y * scale
	local item_separator = 8 * screen_scale_x * scale
	local icon_separator = 5 * screen_scale_x * scale

	local panel_padding = Vec2(6 * screen_scale_x, 3 * screen_scale_y) * scale

	local offset = Vec2(4 * screen_scale_x, 3 * screen_scale_y) * scale

	local cursor_position = Vec2(Input.GetCursorPos())
	local is_mouse_down = Input.IsKeyDown(Enum.ButtonCode.KEY_MOUSE1)

	local menu_opened = Menu.Opened()
	local same_menu = self.watermark_items_menu_same:Get() or not menu_opened

	local time_success, time_result = pcall(os.date, same_menu and self.watermark_items_time_format:Get() or self.watermark_items_time_format_menu:Get())
	local time = tostring(time_result)

	local fps_icon_color = icon_color
	local fps_text_color = text_color

	if self.fps_drop > 0.1 then
		local color = pre_alternative_color:Lerp(alternative_color, math.min(self.fps_drop, 1))

		fps_icon_color = color
		fps_text_color = color
	end

	local ping_icon_color = icon_color
	local ping_text_color = text_color

	if self.ping > 100 then
		local color = pre_alternative_color:Lerp(alternative_color, math.min((self.ping - 100) / (300 - 100), 1))

		ping_icon_color = color
		ping_text_color = color
	end

	local loss_icon_color = icon_color
	local loss_text_color = text_color

	if self.loss_in > 0 or self.loss_out > 0 then
		loss_icon_color = alternative_color
		loss_text_color = alternative_color
	end

	local logo_index = self.watermark_items_logo:Get() + 1
	local logo = self.logo[logo_index]

	local mmr_index = self.watermark_items_mmr_use_rank_icon:Get() + 1

	local items = {
		["Logo"] = {},
		["Framerate"] = {
			icon = {
				src = "\u{e473}",
				size = icon_size + 2,
				color = fps_icon_color,
			},
			text = {
				text = tostring(self.fps) .. " FPS",
				font = self.font,
				size = font_size,
				color = fps_text_color,
			},
		},
		["Latency"] = {
			icon = {
				src = "\u{f690}",
				size = icon_size,
				color = ping_icon_color,
			},
			text = {
				text = tostring(self.ping) .. " MS",
				font = self.font,
				size = font_size,
				color = ping_text_color,
			},
		},
		["Loss"] = {
			icon = {
				src = "\u{e2cf}",
				size = icon_size,
				color = loss_icon_color,
			},
			text = {
				text = (self.loss_in == self.loss_out and (self.loss_in ~= -1 and (tostring(self.loss_in) .. "%") or "?") or ((self.loss_in ~= nil and (tostring(self.loss_in) .. "%") or "?") .. " " .. (self.loss_out ~= nil and (tostring(self.loss_out) .. "%") or "?"))) .. " LOSS",
				font = self.font,
				size = font_size,
				color = loss_text_color,
			},
		},
		["Username"] = {
			icon = {
				src = "\u{f007}",
				size = icon_size,
				color = icon_color,
			},
			text = {
				text = tostring(UserInfo.username),
				font = self.font,
				size = font_size,
				color = text_color,
			},
		},
		["MMR"] = {
			text = {
				text = self.mmr_diff == 0 and tostring(self.mmr) or (tostring(self.mmr) .. " (" .. (self.mmr_diff > 0 and "+" or "") .. tostring(self.mmr_diff) .. ")"),
				font = self.font,
				size = font_size,
				color = text_color,
			},
		},
		["Subscription"] = {
			icon = {
				src = "\u{f133}",
				size = icon_size,
				color = icon_color,
			},
			text = {
				text = self.subscription_left ~= "never" and (self.subscription_left .. " left") or "inf",
				font = self.font,
				size = font_size,
				color = text_color,
			},
		},
		["Time"] = {
			icon = {
				src = "\u{e29e}",
				size = icon_size,
				color = icon_color,
			},
			text = {
				text = tostring(time),
				font = self.font,
				size = font_size,
				color = text_color,
			},
		},
		["Avatar"] = {
			image = {
				src = self.avatar,
				size = Vec2(avatar_size, avatar_size),
				color = Color(),
				rounding = avatar_size,
				flags = Enum.DrawFlags.RoundCornersAll,
			},
		}
	}

	if logo ~= nil then
		items["Logo"]["image"] = {
			src = logo,
			size = Vec2(logo_size, logo_size),
			color = Color(),
		}
	end

	if logo_index == 3 then
		items["Logo"]["text"] = {
			text = "UC",
			font = self.font_logo,
			size = logo_text_size,
			color = Color(),

			shadow = {
				offset = Vec2(-1, 0.75) * scale,
				color = logo_accent_color,
			},
		}
	end

	if mmr_index == 1 then
		items["MMR"]["icon"] = {
			src = "\u{f091}",
			size = icon_size,
			color = icon_color,
		}
	elseif mmr_index == 2 then
		items["MMR"]["image"] = {
			src = Render.LoadImage("panorama/images/rank_tier_icons/rank" .. tostring(math.floor(mmr_to_rank_tier(self.mmr) / 10)) .. "_psd.vtex_c"),
			size = Vec2(icon_large_size, icon_large_size),
			color = Color(),
		}
	end

	local items_widget = same_menu and self.watermark_items or self.watermark_items_menu
	local items_enabled = XHelpers.xtable.to_keys(items_widget:ListEnabled())

	if not menu_opened then
		if items_enabled["Latency"] and (self.has_ping_time == -1 or now - self.has_ping_time > 3) then
			items_enabled["Latency"] = false
		end

		if items_enabled["Loss"] and (self.has_loss_time == -1 or now - self.has_loss_time > 3) then
			items_enabled["Loss"] = false
		end

		if items_enabled["MMR"] and self.watermark_items_hide_mmr_in_game:Get() and self.is_in_game and self.game_state ~= Enum.GameState.DOTA_GAMERULES_STATE_POST_GAME then
			items_enabled["MMR"] = false
		end
	end

	local items_enabled_order = table.filter(self.items_order, function(_, item) return items_enabled[item] end)

	local bg_width = #items_enabled_order <= 0 and icon_size or 0
	local bg_height = avatar_size

	for _, element_name in pairs(items_enabled_order) do
		local element = items[element_name]

		local previous_element = items[items_enabled[_ - 1]]
		local separator = previous_element ~= nil and previous_element.separator or item_separator

		local actual_size = Vec2()

		if _ > 1 then
			bg_width = bg_width + separator
		end

		if element.image ~= nil then
			bg_width = bg_width + element.image.size.x
			actual_size.x = actual_size.x + element.image.size.x
			actual_size.y = math.max(actual_size.y, element.image.size.y)
		end

		if element.icon ~= nil then
			local icon_text_size = Render.TextSize(XHelpers.XRender.fonts.icons, element.icon.size, element.icon.src)
			actual_size.x = actual_size.x + icon_text_size.x
			actual_size.y = math.max(actual_size.y, icon_text_size.y)

			if element.image ~= nil then
				bg_width = bg_width + icon_separator
				actual_size.x = actual_size.x + icon_separator
			end

			bg_width = bg_width + icon_text_size.x

			items[element_name]["icon"]["text_size"] = icon_text_size
		end

		if element.text ~= nil then
			local text_size = Render.TextSize(element.text.font, element.text.size, element.text.text)
			actual_size.x = actual_size.x + text_size.x
			actual_size.y = math.max(actual_size.y, text_size.y)

			if element.image ~= nil or element.icon ~= nil then
				bg_width = bg_width + icon_separator
				actual_size.x = actual_size.x + icon_separator
			end

			bg_width = bg_width + text_size.x

			items[element_name]["text"]["text_size"] = text_size
		end

		items[element_name]["actual_size"] = actual_size
	end

	bg_width = bg_width + (#items_enabled_order > 0 and (items[items_enabled_order[1]]["padding_override"] or panel_padding).x + (items[items_enabled_order[#items_enabled_order]]["padding_override"] or panel_padding).x or 0)
	bg_height = bg_height + panel_padding.y * 2

	if self.animation_width_value == nil then
		self.animation_width_value = bg_width
	end

	if self.animation_width_progress == 1 then
		if self.animation_width_value ~= bg_width then
			self.animation_width_progress = self.animation_width_value / bg_width
			self.animation_width_progress_start = self.animation_width_value / bg_width
			self.animation_width_value = bg_width
			self.animation_restarting_now = false
		end
	else
		if self.animation_width_value ~= bg_width then
			if not self.animation_restarting_now then
				self.animation_restarting_now = true
				self.animation_width_progress_start = self.animation_width_value / bg_width
			end

			self.animation_width_value = bg_width
		else
			self.animation_restarting_now = false
		end

		self.animation_width_progress = XHelpers.xmath.ease_out_progress(self.animation_width_progress, 1, 10, 0.005)
	end

	if self.animation_width_progress == 1 then
		self.animation_width_value = bg_width

		local item_sizes = {}

		for _, item in pairs(items_enabled_order) do
			item_sizes[item] = items[item]["actual_size"]
		end

		self.animation_width_items = item_sizes
	end

	local pct = (self.animation_width_progress - self.animation_width_progress_start) / (1 - self.animation_width_progress_start)

	local bg_xy_1 = Vec2(screen_size.x - offset.x - bg_width * self.animation_width_progress, offset.y)
	local bg_xy_2 = Vec2(screen_size.x - offset.x, offset.y + bg_height)

	local cursor_position_clamped_bg = Vec2(math.clamp(cursor_position.x, bg_xy_1.x, bg_xy_2.x), math.clamp(cursor_position.y, bg_xy_1.y, bg_xy_2.y))

	Render.FilledRect(bg_xy_1, bg_xy_2, bg_color, 32, Enum.DrawFlags.RoundCornersAll)
	Render.Blur(bg_xy_1, bg_xy_2, 1, 0.9, 32, Enum.DrawFlags.RoundCornersAll)
	-- Render.Shadow(bg_xy_1, bg_xy_2, bg_shadow_color, 8, 32, Enum.DrawFlags.ShadowCutOutShapeBackground + Enum.DrawFlags.RoundCornersAll)

	local drag_hover = false

	local element_offset_x = -(bg_width * self.animation_width_progress) + (items[items_enabled_order[1]] ~= nil and items[items_enabled_order[1]]["padding_override"] or panel_padding).x
	local element_offset_y = bg_height / 2
	for _, name in pairs(table.copy(self.items_order)) do
		local element = items[name]
		local separator = element.separator or item_separator

		if items_enabled[name] and self.animation_width_items[name] then
			local element_xy_1 = Vec2(screen_size.x - offset.x + math.min(element_offset_x - 3, 0), offset.y + math.min(element_offset_y - element.actual_size.y / 2 - 3, bg_height))
			local element_xy_2 = Vec2(screen_size.x - offset.x + math.min(element_offset_x + element.actual_size.x + 3, 0), offset.y + math.min(element_offset_y + element.actual_size.y / 2 + 3, bg_height))

			local x_offset = 0

			if
				name ~= "Avatar"
				and (
					(cursor_position.x > element_xy_1.x and cursor_position.x < element_xy_2.x) and (cursor_position.y > element_xy_1.y and cursor_position.y < element_xy_2.y) and self.dragging_item == nil
					or (self.dragging_item == name)
				)
			then
				if self.dragging_item == nil and is_mouse_down then
					self.dragging_item = name
					self.dragging_start_cursor_item = cursor_position_clamped_bg.x - element_xy_1.x
				elseif self.dragging_item == name and not is_mouse_down then
					self.dragging_item = nil
					self.dragging_start_cursor_item = nil
				elseif self.dragging_item == name then
					x_offset = cursor_position_clamped_bg.x - element_xy_1.x - self.dragging_start_cursor_item

					self.dragged_item, self.dragged_item_pos = name, element_xy_1.x + self.dragging_start_cursor_item + x_offset
				end

				drag_hover = true

				Render.FilledRect(element_xy_1 + Vec2(x_offset, 0), element_xy_2 + Vec2(x_offset, 0), Color(100, 100, 100, 75))
			end

			if element.image ~= nil then
				local position = Vec2(screen_size.x - offset.x, offset.y) + Vec2(element_offset_x, element_offset_y - element.image.size.y / 2) + Vec2(x_offset, 0)

				Render.Image(element.image.src, position, element.image.size, element.image.color, element.image.rounding, element.image.flags)
			end

			if element.icon ~= nil then
				local position = Vec2(screen_size.x - offset.x, offset.y) + Vec2(element_offset_x, element_offset_y - element.icon.text_size.y / 2) + Vec2(x_offset, 0)

				if element.image ~= nil then
					position.x = position.x + element.image.size.x + icon_separator
				end

				Render.Text(XHelpers.XRender.fonts.icons, element.icon.size, element.icon.src, position, element.icon.color)
			end

			if element.text ~= nil then
				local position = Vec2(screen_size.x - offset.x, offset.y) + Vec2(element_offset_x, element_offset_y - element.text.text_size.y / 2) + Vec2(x_offset, 0)

				if element.image ~= nil then
					position.x = position.x + element.image.size.x + icon_separator
				end

				if element.icon ~= nil then
					position.x = position.x + element.icon.text_size.x + icon_separator
				end

				if element.text.shadow ~= nil then
					Render.Text(element.text.font, element.text.size, element.text.text, position + element.text.shadow.offset, element.text.shadow.color or Color(0, 0, 0))
				end

				Render.Text(element.text.font, element.text.size, element.text.text, position, element.text.color)
			end

			if self.dragged_item ~= nil and self.dragged_item_pos ~= nil then
				if element_xy_1.x <= self.dragged_item_pos and element_xy_2.x >= self.dragged_item_pos then
					if self.dragged_item ~= name and name ~= "Avatar" then
						local dragged_item_index = table.find_index(self.items_order, function(k, v, t) return v == self.dragged_item end)

						if dragged_item_index ~= nil then
							self.items_order[_] = self.dragged_item
							self.items_order[dragged_item_index] = name

							db["x"]["watermark"]["items_order"] = self.items_order
						end
					end

					self.dragged_item, self.dragged_item_pos = nil, nil
				end
			end

			element_offset_x = element_offset_x + element.actual_size.x + separator
		elseif self.animation_width_items[name] then
			element_offset_x = element_offset_x + (self.animation_width_items[name].x + separator) * (1 - pct)
		elseif items_enabled[name] then
			element_offset_x = element_offset_x + (element.actual_size.x + separator) * pct
		end
	end

	self.drag_hover = drag_hover
end

function Watermark:UpdateMetrics()
	local is_in_game = Engine.IsInGame()

	if self.net_graph_convar_ref ~= nil then
		local net_graph_convar_value = ConVar.GetBool(self.net_graph_convar_ref)

		if self.net_graph_convar_user_value == nil then
			self.net_graph_convar_user_value = net_graph_convar_value
		end

		if net_graph_convar_value ~= true then
			ConVar.SetBool(self.net_graph_convar_ref, true)
		end
	end

	if is_in_game then
		if self.net_graph_fps_panel == nil or not self.net_graph_fps_panel:IsValid() then
			self.net_graph_fps_panel = Panorama.GetPanelByPath(self.net_graph_fps_path)
		end

		if self.net_graph_ping_panel == nil or not self.net_graph_ping_panel:IsValid() then
			self.net_graph_ping_panel = Panorama.GetPanelByPath(self.net_graph_ping_path)
		end

		if self.net_graph_loss_in_panel == nil or not self.net_graph_loss_in_panel:IsValid() then
			self.net_graph_loss_in_panel = Panorama.GetPanelByPath(self.net_graph_loss_in_path)
		end

		if self.net_graph_loss_out_panel == nil or not self.net_graph_loss_out_panel:IsValid() then
			self.net_graph_loss_out_panel = Panorama.GetPanelByPath(self.net_graph_loss_out_path)
		end
	else
		self.net_graph_fps_panel = nil
		self.net_graph_ping_panel = nil
		self.net_graph_loss_in_panel = nil
		self.net_graph_loss_out_panel = nil
	end

	local fps = (self.net_graph_fps_panel ~= nil and self.net_graph_fps_panel:IsValid()) and tonumber(self.net_graph_fps_panel:GetText()) or nil
	if fps == nil or fps <= 0 then
		fps = math.floor(1 / GlobalVars.GetAbsFrameTime())
	end

	local ping = is_in_game and ((self.net_graph_ping_panel ~= nil and self.net_graph_ping_panel:IsValid()) and tonumber(self.net_graph_ping_panel:GetText()) or nil) or 0
	if ping == nil or ping < 0 then
		ping = math.ceil(NetChannel.GetLatency(Enum.Flow.MAX_FLOWS) * 1000)
	end

	local loss_in = (self.net_graph_loss_in_panel ~= nil and self.net_graph_loss_in_panel:IsValid()) and tonumber(self.net_graph_loss_in_panel:GetText()) or -1
	local loss_out = (self.net_graph_loss_out_panel ~= nil and self.net_graph_loss_out_panel:IsValid()) and tonumber(self.net_graph_loss_out_panel:GetText()) or -1

	if loss_in > 0 or loss_out > 0 then
		self.has_loss_time = os.clock()
	end

	if ping > 0 then
		self.has_ping_time = os.clock()
	end

	self.fps = fps
	self.ping = ping
	self.loss_in = loss_in
	self.loss_out = loss_out

	table.insert(self.fps_history, fps)

	if #self.fps_history > 5 then
		if #self.fps_history > 60 then
			table.remove(self.fps_history, 1)
		end

		local fps_sorted = table.copy(self.fps_history)
		table.sort(fps_sorted, function(a, b) return a < b end)

		self.fps_drop = 1 - self.fps / fps_sorted[math.floor(#fps_sorted * 0.35)]

		if self.fps_drop < -2 then
			table.clear(self.fps_history)
		end
	else
		self.fps_drop = 0
	end

	self.subscription_left = pretty_timedelta(os.time(), UserInfo.subscription_timestamp)

	self.is_in_game = is_in_game
end

---@return table<string, Color>
function Watermark:GetColors()
	local colors = {}

	for _, setting in pairs(self.color_settings) do
		if self.custom_color_settings[setting["name"]]["enable"]:Get() then
			colors[setting["name"]] = self.custom_color_settings[setting["name"]]["color"]:Get()
		else
			local color = setting["default"]

			if type(color) == "string" then
				---@diagnostic disable-next-line: cast-local-type
				color = Menu.Style(color)
			elseif type(color) == "function" then
				color = color()
			end

			colors[setting["name"]] = color
		end
	end

	return colors
end

return (XHelpers.WrapCallbacks or XHelpers.BaseScript)(Watermark)