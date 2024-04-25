require("libraries/__init__")

local OBSBypass = class("OBSBypass")

function OBSBypass:initialize()
	self.path = {"Magma", "OBS bypass"}

	self.visual_options = {
		{{"Creeps", "Creep Blocker", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Creeps", "Auto lasthit", "Draw attack radius"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"General", "Radius", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Hero Specific", "General settings", "Target selector", "Draw particle"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Wards Tracker", "Ward render type"}, Enum.MenuType.MENU_TYPE_COMBO, function(menu)
			local value = Menu.GetValue(menu)
			if value == 2 or value == 3 then
				return 1
			end
		end},
		{{"Info Screen", "Wards Tracker", "Render range particle"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Visible by Enemy", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Illusion", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Me More", "Show Hidden Spells"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Me More", "Show Linear Projectiles"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Me More", "Tower Radius"}, Enum.MenuType.MENU_TYPE_COMBO, 0},
		{{"Info Screen", "Show Me More", "Watchers Radius"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Info Screen", "Show Me More", "Show Linken/Mirror Shield"}, Enum.MenuType.MENU_TYPE_COMBO, function(menu)
			local value = Menu.GetValue(menu)
			if value == 2 then
				return 1
			end
		end},
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
	}

	self.skinchanger_options = {
		{{"Skins & Bundles", "Unlock DotaPlus"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Skins & Bundles", "Unlock Emoticons"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Skins & Bundles", "Unlock Labyrinth"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Skins & Bundles", "Effects"}, Enum.MenuType.MENU_TYPE_COMBO, 0},
		{{"Skins & Bundles", "River"}, Enum.MenuType.MENU_TYPE_COMBO, 0},
		{{"Skins & Bundles", "Skin Changer"}, Enum.MenuType.MENU_TYPE_BOOL, false},
		{{"Skins & Bundles", "Tree Changer", "Enabled"}, Enum.MenuType.MENU_TYPE_BOOL, false},
	}

	self.mainmenu_options = {
		{{"Utility", "MMR tracker", "Enable"}, Enum.MenuType.MENU_TYPE_BOOL, false},
	}

	self.

	--[[
		unknown:
		Info Screen Show Me More Bounty runes in world
	]]

	self.font = CRenderer:LoadFont("Verdana", 24, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.MEDIUM)

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.disable_visual = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Visual", false)
	self.disable_visual:SetTip("Disables visual that visible by capture programs")

	self.disable_camera = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Camera", false)
	self.disable_camera:SetIcon("~/MenuIcons/binoculars_filled.png")
	self.disable_camera:SetTip("Disables non-default camera distance")

	self.disable_visual_minimap = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Minimap visual", false)
	self.disable_visual_minimap:SetIcon("~/MenuIcons/google_maps.png")
	self.disable_visual_minimap:SetTip("Disables visual that visible only at minimap by capture programs")

	self.disable_skinchanger = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Skinchanger", false)
	self.disable_skinchanger:SetIcon("~/MenuIcons/palette.png")

	self.disable_mainmenu = UILib:CreateCheckbox({self.path, "Quick disablers"}, "Mainmenu visual", false)
	self.disable_mainmenu:SetTip("Disables visual that visible in main menu by capture programs")

	self.alternative = UILib:CreateCheckbox({self.path, "Alternative"}, "Enable", false)

	self.alternative_autolasthit_attack_radius = UILib:CreateCheckbox({self.path, "Alternative", "Creeps", "Auto lasthit"}, "Draw attack radius", false)

	-- self.alternative_ward_tracker_radius = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Wards Tracker"}, "Render range particle", false)

	self.alternative_vbe = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Enable", false)
	self.alternative_vbe_style = UILib:CreateCombo({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Style", {"Text", "Icon"}, 2)
	self.alternative_vbe_localhero = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Local hero", false)
	self.alternative_vbe_allies = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Allies", false)
	self.alternative_vbe_creeps = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Creeps", false)
	self.alternative_vbe_wards = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Wards", false)
	self.alternative_vbe_courier = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Visible By Enemy"}, "Courier", false)

	self.alternative_show_illusion = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Illusion"}, "Enable", false)
	self.alternative_show_illusion = UILib:CreateCombo({self.path, "Alternative", "Info Screen", "Show Illusion"}, "Style", {"Text", "Icon"}, 2)

	self.alternative_show_hidden_spells = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More"}, "Show Hidden Spells", false)
	self.alternative_show_linear_projectiles = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More"}, "Show Linear Projectiles", false)

	self.alternative_tower_radius = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More"}, "Tower Radius", false)
	self.alternative_watcher_radius = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More"}, "Watchers Radius", false)

	self.alternative_vbs_localhero = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More", "Visible By Sentry"}, "Local hero", false)
	self.alternative_vbs_style = UILib:CreateCombo({self.path, "Alternative", "Info Screen", "Show Me More", "Visible By Sentry"}, "Style", {"Text", "Icon"}, 2)
	self.alternative_vbs_allies = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More", "Visible By Sentry"}, "Allies", false)
	self.alternative_vbs_creeps = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More", "Visible By Sentry"}, "Creeps", false)
	self.alternative_vbs_wards = UILib:CreateCheckbox({self.path, "Alternative", "Info Screen", "Show Me More", "Visible By Sentry"}, "Wards", false)

	UILib:SetTabIcon(self.path, "~/Menuicons/anon.png")

	self.listeners = {}

	self.options_cache = {}
end

function OBSBypass:OnUpdate()
	local tick = self:GetTick()
end

function OBSBypass:OnDraw()
end

return BaseScriptAPI(OBSBypass)