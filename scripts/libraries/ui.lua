local function parseWhereAt(whereAt)
	if type(whereAt) == "string" then
		whereAt = {whereAt}
	end
	return table.unzip(whereAt)
end

local UILib = class("UILib")

function UILib:initialize()
	Timers:CreateTimer({useGameTime=false, delay=0.01, callback=function()
		self:SetTabIcon("Magma", "~/MenuIcons/Dota/quas-wex-exort.png")
		self:SetTabIcon({"Magma", "General"}, "~/MenuIcons/globe_world.png")
		self:SetTabIcon({"Magma", "General", "Items manager"}, "~/MenuIcons/keypad-1.png")
		self:SetTabIcon({"Magma", "Info Screen"}, "~/MenuIcons/sys_stats.png")
		self:SetTabIcon({"Magma", "Info Screen", "Show Me More"}, "~/MenuIcons/eye_scan.png")
		self:SetTabIcon({"Magma", "Utility"}, "~/MenuIcons/utils_wheel.png")
		self:SetTabIcon({"Magma", "Hero Specific"}, "~/MenuIcons/helmet_g.png")
		self:SetTabIcon({"Magma", "Hero Specific", "Strength"}, "panorama/images/primary_attribute_icons/primary_attribute_icon_strength_psd.vtex_c")
		self:SetTabIcon({"Magma", "Hero Specific", "Agility"}, "panorama/images/primary_attribute_icons/primary_attribute_icon_agility_psd.vtex_c")
		self:SetTabIcon({"Magma", "Hero Specific", "Intelligence"}, "panorama/images/primary_attribute_icons/primary_attribute_icon_intelligence_psd.vtex_c")
		self:SetTabIcon({"Magma", "Hero Specific", "Universal"}, "panorama/images/primary_attribute_icons/primary_attribute_icon_all_psd.vtex_c")
		local npc_heroes = KVLib:GetKV("npc_heroes")
		for heroname, kv in pairs(npc_heroes["DOTAHeroes"]) do
			if type(kv) == "table" then
				self:SetTabIcon({"Magma", "Hero Specific", LocaleLib:LocalizeAttribute(KVLib:GetHeroAttribute(heroname)), LocaleLib:LocalizeHeroName(heroname)}, GetHeroIconPath(heroname))
			end
		end
	end}, self)
end

function UILib:CreateButton(whereAt, name, callback)
	local option = UILibOptionButton:new(parseWhereAt(whereAt), name, callback)
	return option
end

function UILib:CreateCheckbox(whereAt, name, defaultBool)
	local option = UILibOptionCheckbox:new(parseWhereAt(whereAt), name, defaultBool)
	option:SetIcon("~/MenuIcons/Enable/enable_check_boxed.png")
	return option
end

function UILib:CreateColor(whereAt, name, r, g, b, a)
	local option = UILibOptionColor:new(parseWhereAt(whereAt), name, r, g, b, a)
	option:SetIcon("~/MenuIcons/palette.png")
	return option
end

function UILib:CreateCombo(whereAt, name, items, defaultIndex)
	local option = UILibOptionCombo:new(parseWhereAt(whereAt), name, items, defaultIndex)
	option:SetIcon("~/MenuIcons/Lists/list_combo.png")
	return option
end

function UILib:CreateKeybind(whereAt, name, defaultButton)
	local option = UILibOptionKeybind:new(parseWhereAt(whereAt), name, defaultButton)
	option:SetIcon("~/MenuIcons/status.png")
	return option
end

function UILib:CreateMultiselect(whereAt, name, itemsTable, singleSelectMode)
	local option = UILibOptionMultiselect:new(parseWhereAt(whereAt), name, itemsTable, singleSelectMode)
	option:SetIcon("~/MenuIcons/ellipsis.png")
	return option
end

function UILib:CreateSlider(whereAt, name, min, max, default, force_float)
	local option = UILibOptionSlider:new(parseWhereAt(whereAt), name, min, max, default, force_float)
	option:SetIcon("~/MenuIcons/edit.png")
	return option
end

function UILib:CreateTextbox(whereAt, name, defaultString)
	local option = UILibOptionTextbox:new(parseWhereAt(whereAt), name, defaultString)
	return option
end

function UILib:SetTabIcon(whereAt, icon_path)
	if icon_path == nil then
		return Menu.RemoveMenuIcon(parseWhereAt(whereAt))
	end
	return Menu.AddMenuIcon(parseWhereAt(whereAt), icon_path)
end

function UILib:CreateMultiselectFromEnemies(whereAt, name, singleSelectMode, selectAll, useHeroNames)
	local itemsTable = {}
	if CGameRules:GetGameState() >= 4 then
		local heroes = CHero:GetEnemiesHeroNames()
		for playerID, enemy in pairs(heroes) do
			if table.find(heroes, enemy) == playerID then
				table.insert(itemsTable, {useHeroNames and enemy or tostring(playerID), "panorama/images/heroes/icons/"..enemy.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return self:CreateMultiselect(whereAt, name, itemsTable, singleSelectMode)
end

function UILib:CreateMultiselectFromAllies(whereAt, name, singleSelectMode, selectAll, useHeroNames)
	local itemsTable = {}
	if CGameRules:GetGameState() >= 4 then
		local heroes = CHero:GetAlliesHeroNames()
		for playerID, enemy in pairs(heroes) do
			if table.find(heroes, enemy) == playerID then
				table.insert(itemsTable, {useHeroNames and enemy or tostring(playerID), "panorama/images/heroes/icons/"..enemy.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return self:CreateMultiselect(whereAt, name, itemsTable, singleSelectMode)
end

function UILib:CreateMultiselectFromAlliesOnly(whereAt, name, singleSelectMode, selectAll, useHeroNames)
	local itemsTable = {}
	if CGameRules:GetGameState() >= 4 then
		local heroes = CHero:GetAlliesOnlyHeroNames()
		for playerID, enemy in pairs(heroes) do
			if table.find(heroes, enemy) == playerID then
				table.insert(itemsTable, {useHeroNames and enemy or tostring(playerID), "panorama/images/heroes/icons/"..enemy.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return self:CreateMultiselect(whereAt, name, itemsTable, singleSelectMode)
end

function UILib:CreateAdditionalControllableUnits(whereAt, name, use_abilities, use_items, exclude_non_heroes)
	local units = {
		{"spirit_bear", "panorama/images/spellicons/lone_druid_spirit_bear_png.vtex_c", true, true, false},
		{"tempest_double", "panorama/images/spellicons/arc_warden_tempest_double_png.vtex_c", true, true, true},
		{"parting_shot", "panorama/images/spellicons/muerta_parting_shot_png.vtex_c", true, false, true},
	}
	local unitsTable = {}
	for _, unit in pairs(units) do
		if (not use_abilities or unit[3]) and (not use_items or unit[4]) and (not exclude_non_heroes or unit[5]) then
			table.insert(unitsTable, {unit[1], unit[2], false})
		end
	end
	return self:CreateMultiselect(whereAt, name or "Additional usage", unitsTable)
end

return UILib:new()