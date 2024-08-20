---@class UILib
local UILib = {}

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param callback function
---@param altStyle boolean?
---@return CMenuButton
function UILib:CreateButton(parent, name, callback, altStyle)
	return parent:Button(name, callback, altStyle)
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param defaultBool boolean?
---@param imageIcon string?
---@return CMenuSwitch
function UILib:CreateCheckbox(parent, name, defaultBool, imageIcon)
	return parent:Switch(name, defaultBool, imageIcon or "")
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param color Color?
---@param imageIcon string?
---@return CMenuColorPicker
function UILib:CreateColor(parent, name, color, imageIcon)
	return parent:ColorPicker(name, color or Color(255, 255, 255, 255), imageIcon)
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param items string[]
---@param defaultIndex number?
---@param imageIcon string?
---@return CMenuComboBox
function UILib:CreateCombo(parent, name, items, defaultIndex, imageIcon)
	local option = parent:Combo(name, items, defaultIndex)
	if imageIcon then
		option:Icon(imageIcon)
	end
	return option
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param items string[]
---@param enabledItems string[]?
---@param imageIcon string?
---@return CMenuMultiComboBox
function UILib:CreateMultiCombo(parent, name, items, enabledItems, imageIcon)
	local option = parent:MultiCombo(name, items, enabledItems or {})
	if imageIcon then
		option:Icon(imageIcon)
	end
	return option
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param defaultButton Enum.ButtonCode?
---@param imageIcon string?
---@return CMenuBind
function UILib:CreateKeybind(parent, name, defaultButton, imageIcon)
	return parent:Bind(name, defaultButton or Enum.ButtonCode.KEY_NONE, imageIcon or "")
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param itemsTable [string, string, boolean][]
---@param expanded boolean?
---@param imageIcon string?
---@return CMenuMultiSelect
function UILib:CreateMultiselect(parent, name, itemsTable, expanded, imageIcon)
	local option = parent:MultiSelect(name, itemsTable, expanded)
	if imageIcon then
		option:Icon(imageIcon)
	end
	return option
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param min number
---@param max number
---@param default number?
---@param format string | function?
---@param imageIcon string?
---@return CMenuSliderInt | CMenuSliderFloat
function UILib:CreateSlider(parent, name, min, max, default, format, imageIcon)
	local option = parent:Slider(name, min, max, default or min, format)
	if imageIcon then
		option:Icon(imageIcon)
	end
	return option
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param defaultString string?
---@param imageIcon string?
---@return CMenuInputBox
function UILib:CreateTextbox(parent, name, defaultString, imageIcon)
	return parent:Input(name, defaultString, imageIcon)
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param singleSelectMode boolean?
---@param selectAll boolean?
---@param useHeroNames boolean?
---@return CMenuMultiSelect
function UILib:CreateMultiselectFromEnemies(parent, name, singleSelectMode, selectAll, useHeroNames)
	local itemsTable = {}
	if GameRules.GetGameState() >= 4 then
		local heroes = CHero:GetEnemiesHeroNames()
		for playerID, enemy in pairs(heroes) do
			if table.find(heroes, enemy) == playerID then
				table.insert(itemsTable, {useHeroNames and enemy or tostring(playerID), "panorama/images/heroes/icons/"..enemy.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return self:CreateMultiselect(parent, name, itemsTable, singleSelectMode)
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param singleSelectMode boolean?
---@param selectAll boolean?
---@param useHeroNames boolean?
---@return CMenuMultiSelect
function UILib:CreateMultiselectFromAllies(parent, name, singleSelectMode, selectAll, useHeroNames)
	local itemsTable = {}
	if GameRules.GetGameState() >= 4 then
		local heroes = CHero:GetAlliesHeroNames()
		for playerID, enemy in pairs(heroes) do
			if table.find(heroes, enemy) == playerID then
				table.insert(itemsTable, {useHeroNames and enemy or tostring(playerID), "panorama/images/heroes/icons/"..enemy.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return self:CreateMultiselect(parent, name, itemsTable, singleSelectMode)
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param selectAll boolean?
---@param useHeroNames boolean?
---@return CMenuMultiSelect
function UILib:CreateMultiselectFromAlliesOnly(parent, name, singleSelectMode, selectAll, useHeroNames)
	local itemsTable = {}
	if GameRules.GetGameState() >= 4 then
		local heroes = CHero:GetAlliesOnlyHeroNames()
		for playerID, enemy in pairs(heroes) do
			if table.find(heroes, enemy) == playerID then
				table.insert(itemsTable, {useHeroNames and enemy or tostring(playerID), "panorama/images/heroes/icons/"..enemy.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return self:CreateMultiselect(parent, name, itemsTable, singleSelectMode)
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param use_abilities boolean?
---@param use_items boolean?
---@param exclude_non_heroes boolean?
---@return CMenuMultiSelect
function UILib:CreateAdditionalControllableUnits(parent, name, use_abilities, use_items, exclude_non_heroes)
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
	return self:CreateMultiselect(parent, name or "Additional usage", unitsTable)
end

return UILib