require("libraries/__init__")

local OBSBypass = class("OBSBypass")

function OBSBypass:initialize()
	self.path = {"Magma", "OBS bypass"}

	self.font = CRenderer:LoadFont("Consolas", 14, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.MEDIUM)

	self.visual_options = {
		{{"Creeps", "Creep Blocker", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Creeps", "Auto lasthit", "Draw attack radius"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"General", "Radius", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Hero Specific", "General settings", "Target selector", "Draw particle"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Wards Tracker", "Ward render type"}, Enum.MenuType.MENU_TYPE_COMBO, 1},
		{{"Info Screen", "Wards Tracker", "Render range particle"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Visible by Enemy", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Illusion", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		-- {{"Info Screen", "Show Me More", "Show Hidden Spells"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Me More", "Show Linear Projectiles"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Me More", "Tower Radius"}, Enum.MenuType.MENU_TYPE_COMBO, 0},
		{{"Info Screen", "Show Me More", "Watchers Radius"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Me More", "Show Linken/Mirror Shield"}, Enum.MenuType.MENU_TYPE_COMBO, 1},
		{{"Info Screen", "Show Me More", "Visible By Sentry", "For Your Hero"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Me More", "Visible By Sentry", "For Your Team"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Me More", "Visible By Sentry", "For Creeps"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Me More", "Visible By Sentry", "For Wards"}, Enum.MenuType.MENU_TYPE_BOOL, false},
	}

	self.visual_minimap_options = {
		{{"Creeps", "Creep Wave", "Show on Map"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Minimap", "Draw on minimap"}, Enum.MenuType.MENU_TYPE_MULTI_SELECT, {}},
		{{"Info Screen", "Map Hack", "Teleports", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false}, -- draws hero icon on minimap
		{{"Info Screen", "Map Hack", "Teleports", "Draw Arrows on Minimap"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Map Hack", "Show on Minimap"}, Enum.MenuType.MENU_TYPE_BOOL, false},
	}

	self.sound_options = {
		{{"Info Screen", "Sound Volume"}, Enum.MenuType.MENU_TYPE_RANGE_FLOAT, 0.0},

		{{"Magma", "General", "Items manager", "Trees destroyer", "Settings", "Notification", "Sound"}, Enum.MenuType.MENU_TYPE_COMBO, 0},
		{{"Magma", "Info Screen", "Side Notifications", "Sound"}, Enum.MenuType.MENU_TYPE_BOOL, false},
	}

	self.skinchanger_options = {
		{{"Skins & Bundles", "Unlock DotaPlus"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Skins & Bundles", "Unlock Emoticons"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Skins & Bundles", "Unlock Labyrinth"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Skins & Bundles", "Effects"}, Enum.MenuType.MENU_TYPE_COMBO, 0},
		{{"Skins & Bundles", "River"}, Enum.MenuType.MENU_TYPE_COMBO, 0},
		-- {{"Skins & Bundles", "Skin Changer"}, Enum.MenuType.MENU_TYPE_BOOL, false}, -- cannot change during game
		{{"Skins & Bundles", "Tree Changer", "Enabled"}, Enum.MenuType.MENU_TYPE_BOOL, false},
	}

	self.mainmenu_options = {
		{{"Utility", "MMR tracker", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
	}

	self.scripts_options = {
		{{"Creeps", "Auto Stack", "Enable [OVERWATCH RISK]"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Creeps", "Creep Blocker", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Creeps", "Jungle Bot", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Creeps", "Auto lasthit", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Creeps", "Agro | Deagro", "Auto Tower Deagro"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Creeps", "Agro | Deagro", "Auto Creeps Deagro"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"General", "Items manager", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"General", "Dodger", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"General", "Auto Disabler", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"General", "Illusion Controller", "Enable [OVERWATCH RISK]"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"General", "Kill Stealer", "Only Drawings"}, Enum.MenuType.MENU_TYPE_BOOL, true},
		{{"General", "Snatcher", "Rune Snatcher", "Enabled"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"General", "Snatcher", "Item Snatcher", "Items to Steal:"}, Enum.MenuType.MENU_TYPE_MULTI_SELECT, {}},
		{{"General", "Snatcher", "Item Snatcher", "Pick Jungle Items"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Utility", "Autobuy", "Items Selection:"}, Enum.MenuType.MENU_TYPE_MULTI_SELECT, {}},
		{{"Utility", "Courier", "Economy Courier"}, Enum.MenuType.MENU_TYPE_COMBO, 0},
		{{"Utility", "Auto Take Token", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Utility", "Harpoon Catch", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Utility", "Anti Illusion", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Utility", "Auto Pick-Ban-Lane", "Select Lane", "Select Search Role"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Utility", "Auto Pick-Ban-Lane", "Select Lane", "Select My Role:"}, Enum.MenuType.MENU_TYPE_COMBO, 0},
		{{"Utility", "MpHp Abuse", "Enabled"}, Enum.MenuType.MENU_TYPE_BOOL, false},

		{{"Magma", "General", "Auto Disabler", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Magma", "General", "Items manager", "Trees destroyer", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Magma", "Utility", "Danger Selector", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Magma", "Utility", "Lotus Helper", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Magma", "Hero Specific", "Universal", "Broodmother", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
	}

	self.font = CRenderer:LoadFont("Verdana", 24, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.MEDIUM)

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.disable_visual = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Visual", false)
	self.disable_visual:SetIcon("~/MenuIcons/sys_stats.png")

	self.disable_sound = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Sound", false)
	self.disable_sound:SetIcon("~/MenuIcons/volume.png")

	self.disable_camera = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Camera", false)
	self.disable_camera:SetIcon("~/MenuIcons/binoculars_filled.png")

	self.disable_visual_minimap = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Minimap", false)
	self.disable_visual_minimap:SetIcon("~/MenuIcons/google_maps.png")

	self.disable_skinchanger = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Skinchanger", false)
	self.disable_skinchanger:SetIcon("~/MenuIcons/palette.png")

	self.disable_mainmenu = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Mainmenu", false)
	self.disable_mainmenu:SetIcon("~/MenuIcons/panel_def.png")

	self.disable_scripts = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Scripts", false)
	self.disable_scripts:SetIcon("~/MenuIcons/robot.png")

	self.disable_maphack = UILib:CreateButton({self.path, "Quick disablers"}, "Turn off maphack", function()
		local hidden_spells = Menu.FindMenu({"Info Screen", "Show Me More"}, "Show Hidden Spells", Enum.MenuType.MENU_TYPE_BOOL)
		Timers:CreateTimer(0.01, function()
			for i=0, 100 do
				Menu.SetEnabled(hidden_spells, false, true)
				Timers:CreateTimer(0.1+0.01*i, function()
					Menu.SetEnabled(hidden_spells, true, true)
					Timers:CreateTimer(0.1+0.01*i, function()
						Menu.SetEnabled(hidden_spells, false, true)
					end, self)
				end, self)
			end
		end, self)
	end)
	self.disable_maphack:SetIcon("~/MenuIcons/robot.png")
	self.disable_maphack:SetTip("[WARNING]\nMAY NOT WORK! CLICK MULTIPLE TIMES TO FIX")

	UILib:SetTabIcon({self.path, "Quick disablers"}, "~/MenuIcons/Enable/enable_ios.png")

	self.alternative = UILib:CreateCheckbox({self.path, "Alternative"}, "Enable", false)

	-- self.alternative_autolasthit_attack_radius = UILib:CreateCheckbox({self.path, "Alternative", "Creeps", "Auto lasthit"}, "Draw attack radius", false)

	-- self.alternative_ward_tracker_radius = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Wards Tracker"}, "Render range particle", false)

	self.alternative_vbe = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Enable", false)
	self.alternative_vbe_localhero = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Local hero", false)
	self.alternative_vbe_localhero:SetIcon("~/MenuIcons/Enable/enable_ios.png")
	self.alternative_vbe_allies = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Allies", false)
	self.alternative_vbe_allies:SetIcon("~/MenuIcons/Enable/enable_ios.png")
	self.alternative_vbe_creeps = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Creeps", false)
	self.alternative_vbe_creeps:SetIcon("~/MenuIcons/Enable/enable_ios.png")
	self.alternative_vbe_wards = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Wards", false)
	self.alternative_vbe_wards:SetIcon("~/MenuIcons/Enable/enable_ios.png")
	self.alternative_vbe_courier = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Courier", false)
	self.alternative_vbe_courier:SetIcon("~/MenuIcons/Enable/enable_ios.png")

	UILib:SetTabIcon({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "~/MenuIcons/Notifications/eye_search.png")

	-- self.alternative_show_illusion = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Illusion"}, "Enable", false)

	-- self.alternative_show_hidden_spells = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More"}, "Show Hidden Spells", false)
	-- self.alternative_show_linear_projectiles = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More"}, "Show Linear Projectiles", false)

	-- self.alternative_tower_radius = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More"}, "Tower Radius", false)
	-- self.alternative_watcher_radius = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More"}, "Watchers Radius", false)

	self.alternative_vbs_localhero = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More", "Visible By Sentry"}, "Local hero", false)
	self.alternative_vbs_localhero:SetIcon("~/MenuIcons/Enable/enable_ios.png")
	self.alternative_vbs_allies = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More", "Visible By Sentry"}, "Allies", false)
	self.alternative_vbs_allies:SetIcon("~/MenuIcons/Enable/enable_ios.png")
	self.alternative_vbs_creeps = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More", "Visible By Sentry"}, "Creeps", false)
	self.alternative_vbs_creeps:SetIcon("~/MenuIcons/Enable/enable_ios.png")
	self.alternative_vbs_wards = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More", "Visible By Sentry"}, "Wards", false)
	self.alternative_vbs_wards:SetIcon("~/MenuIcons/Enable/enable_ios.png")

	UILib:SetTabIcon({self.path, "Alternative", "Info Screen", "Show Me More"}, "~/MenuIcons/eye_scan.png")
	UILib:SetTabIcon({self.path, "Alternative", "Info Screen", "Show Me More", "Visible By Sentry"}, "~/MenuIcons/Dota/eye_sentry.png")

	UILib:SetTabIcon({self.path, "Alternative", "Info Screen"}, "~/MenuIcons/sys_stats.png")

	UILib:SetTabIcon({self.path, "Alternative"}, "~/MenuIcons/ichange_v1.png")

	UILib:SetTabIcon(self.path, "~/Menuicons/anon.png")

	self.listeners = {}

	self.vbe_info = {}
	self.vbs_info = {}

	self.options_cache = json:decode(CConfig:ReadString("magma_obsbypass", "cache", "{}"))
end

local function GetNPCInfo(npc)
	return {
		["local"]=npc:RecursiveGetOwner() == CPlayer:GetLocal() and npc:IsHero(),
		["ally"]=npc:IsHero(),
		["creep"]=npc:IsLaneCreep(),
		["ward"]=npc:IsWard(),
		["courier"]=npc:IsCourier(),
	}
end

function OBSBypass:OnUpdate()
	local tick = self:GetTick()
	if self.alternative:Get() then
		local localplayer = CPlayer:GetLocal()
		local localteam = localplayer:GetTeamNum()
		self.vbe_info = {}
		self.vbs_info = {}
		for _, npc in pairs(CNPC:GetAll()) do
			if npc:GetTeamNum() == localteam and npc:IsAlive() then
				local info = GetNPCInfo(npc)
				local vbe_pass = false
				if self.alternative_vbe_localhero:Get() and info["local"] then
					vbe_pass = true
				elseif self.alternative_vbe_allies:Get() and info["ally"] then
					vbe_pass = true
				elseif self.alternative_vbe_creeps:Get() and info["creep"] then
					vbe_pass = true
				elseif self.alternative_vbe_wards:Get() and info["ward"] then
					vbe_pass = true
				elseif self.alternative_vbe_courier:Get() and info["courier"] then
					vbe_pass = true
				end
				if self.alternative_vbe:Get() and vbe_pass then
					if self.vbe_info[npc:GetIndex()] == nil then
						self.vbe_info[npc:GetIndex()] = {}
					end
					self.vbe_info[npc:GetIndex()][1] = npc:GetAbsOrigin() - Vector(0, npc:GetHullRadius() * 2 + 64, 0)
					if self.vbe_info[npc:GetIndex()][2] == nil or tick % 5 == 0 then
						self.vbe_info[npc:GetIndex()][2] = npc:IsVisibleToEnemies()
					end
				end
				local vbs_pass = false
				if self.alternative_vbs_localhero:Get() and info["local"] then
					vbs_pass = true
				elseif self.alternative_vbs_allies:Get() and info["ally"] then
					vbs_pass = true
				elseif self.alternative_vbs_creeps:Get() and info["creep"] then
					vbs_pass = true
				elseif self.alternative_vbe_wards:Get() and info["ward"] then
					vbs_pass = true
				end
				if vbs_pass then
					if self.vbs_info[npc:GetIndex()] == nil then
						self.vbs_info[npc:GetIndex()] = {}
					end
					self.vbs_info[npc:GetIndex()][1] = npc:GetAbsOrigin() + Vector(0, 0, npc:GetHealthBarOffset())
					if self.vbs_info[npc:GetIndex()][2] == nil or tick % 5 == 0 then
						self.vbs_info[npc:GetIndex()][2] = npc:IsTrueSight()
					end
				end
			end
		end
	end
end

function OBSBypass:OnDraw()
	if not self.enable:Get() then return end
	if self.alternative:Get() then
		if self.alternative_vbe:Get() then
			for _, vbe in pairs(self.vbe_info) do
				if vbe[2] then
					local x, y, visible = CRenderer:WorldToScreen(vbe[1])
					if visible then
						CRenderer:SetDrawColor(255, 255, 255, 255)
						CRenderer:DrawImageCentered(CRenderer:GetOrLoadImage("~/MenuIcons/eye_dashed.png"), x, y, 24, 24)
					end
				end
			end
			for _, vbs in pairs(self.vbs_info) do
				if vbs[2] then
					local x, y, visible = CRenderer:WorldToScreen(vbs[1])
					if visible then
						CRenderer:SetDrawColor(255, 255, 255, 255)
						CRenderer:DrawImageCentered(CRenderer:GetOrLoadImage("~/MenuIcons/Dota/eye_sentry.png"), x, y-64, 24, 24)
					end
				end
			end
		end
	end
end

function OBSBypass:SaveAndDisableOptions(list)
	if not self.enable:Get() then
		self:RestoreOptions(list)
		return
	end
	for _, info in pairs(list) do
		local category = table.copy(info[1])
		table.remove(category, #category)
		local name = info[1][#info[1]]
		local option = Menu.FindMenu(category, name, info[2])
		if option ~= nil then
			local option_key = table.concat(info[1], "/||/")
			local value = Menu.GetValue(option)
			if info[2] == Enum.MenuType.MENU_TYPE_BOOL then
				value = Menu.IsEnabled(option)
			elseif info[2] == Enum.MenuType.MENU_TYPE_MULTI_SELECT then
				value = table.values(table.filter(Menu.GetItems(option), function(_, item) return Menu.IsSelected(option, item) end))
			end
			if self.options_cache[option_key] == nil then
				self.options_cache[option_key] = value
			end
			local new_value = (type(info[3]) == "function" and {info[3](option)} or {info[3]})[1]
			if value ~= new_value then
				if name == "Show Hidden Spells" then
					Timers:CreateTimer(0.01, function()
						Menu.SetEnabled(option, new_value, true)
						Timers:CreateTimer(0.01, function()
							Menu.SetEnabled(option, not new_value, true)
							Timers:CreateTimer(0.1, function()
								Menu.SetEnabled(option, new_value, true)
							end, self)
						end, self)
					end, self)
				else
					if info[2] == Enum.MenuType.MENU_TYPE_BOOL then
						Menu.SetEnabled(option, new_value, true)
					elseif info[2] == Enum.MenuType.MENU_TYPE_MULTI_SELECT then
						for _, item in pairs(Menu.GetItems(option)) do
							Menu.SetSelected(option, item, table.contains(new_value, item), true)
						end
					else
						Menu.SetValue(option, new_value, true)
					end
				end
			end
		else
			print("CANNOT FIND OPTION", name)
			DeepPrintTable(category)
			DeepPrintTable(info[1])
		end
	end
	CConfig:WriteString("magma_obsbypass", "cache", json:encode(self.options_cache))
end

function OBSBypass:RestoreOptions(list)
	if table.length(self.options_cache) <= 0 then return end
	for _, info in pairs(list) do
		local category = table.copy(info[1])
		table.remove(category, #category)
		local name = info[1][#info[1]]
		local option = Menu.FindMenu(category, name, info[2])
		if option ~= nil then
			local option_key = table.concat(info[1], "/||/")
			local old_value = self.options_cache[option_key]
			if old_value ~= nil then
				if info[2] == Enum.MenuType.MENU_TYPE_BOOL then
					Menu.SetEnabled(option, old_value, true)
				elseif info[2] == Enum.MenuType.MENU_TYPE_MULTI_SELECT then
					for _, item in pairs(Menu.GetItems(option)) do
						Menu.SetSelected(option, item, table.contains(old_value, item), true)
					end
				else
					Menu.SetValue(option, old_value, true)
				end
				self.options_cache[option_key] = nil
			end
		else
			print("CANNOT FIND OPTION")
			DeepPrintTable(info[1])
		end
	end
	CConfig:WriteString("magma_obsbypass", "cache", json:encode(self.options_cache))
end

function OBSBypass:OnMenuOptionChange(option, oldValue, newValue)
	if option == Menu.FindMenu({"Info Screen", "Show Me More"}, "Show Hidden Spells", Enum.MenuType.MENU_TYPE_BOOL) then
		return
	end
	local kv = {
		[self.disable_visual] = self.visual_options,
		[self.disable_sound] = self.sound_options,
		[self.disable_camera] = {{{"Info Screen", "Camera", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false}},
		[self.disable_visual_minimap] = self.visual_minimap_options,
		[self.disable_skinchanger] = self.skinchanger_options,
		[self.disable_mainmenu] = self.mainmenu_options,
		[self.disable_scripts] = self.scripts_options,
	}
	for o, l in pairs(kv) do
		if o.menu_option == option or self.enable.menu_option == option then
			if o:Get() then
				Timers:CreateTimer(0.01, function()
					self:SaveAndDisableOptions(l)
				end, self)
			else
				Timers:CreateTimer(0.01, function()
					self:RestoreOptions(l)
				end, self)
			end
		end
	end
end

return BaseScriptAPI(OBSBypass)