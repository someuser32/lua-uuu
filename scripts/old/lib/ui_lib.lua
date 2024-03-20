local class = require("lib/middleclass")
require("lib/ui_lib_util")

UI_LIB = class("UILib")

function UI_LIB:initialize()
end

function UI_LIB:create_bool(whereAt, name, defaultBool)
	local option = UI_LIB_OPTION_BOOL:new(whereAt, name, defaultBool)
	option:set_icon("~/MenuIcons/Enable/enable_check_boxed.png")
	return option
end

function UI_LIB:create_slider(whereAt, name, min, max, default)
	local option = UI_LIB_OPTION_SLIDER:new(whereAt, name, min, max, default)
	option:set_icon("~/MenuIcons/edit.png")
	return option
end

function UI_LIB:create_combo(whereAt, name, items, defaultIndex)
	local option = UI_LIB_OPTION_COMBO:new(whereAt, name, items, defaultIndex)
	option:set_icon("~/MenuIcons/Lists/list_combo.png")
	return option
end

function UI_LIB:create_key(whereAt, name, defaultButton)
	local option = UI_LIB_OPTION_KEY:new(whereAt, name, defaultButton)
	option:set_icon("~/MenuIcons/status.png")
	return option
end

function UI_LIB:create_button(whereAt, name, callback)
	local option = UI_LIB_OPTION_BUTTON:new(whereAt, name, callback)
	return option
end

function UI_LIB:create_multiselect(whereAt, name, itemsTable, singleSelectMode)
	local option = UI_LIB_OPTION_MULTISELECT:new(whereAt, name, itemsTable, singleSelectMode)
	option:set_icon("~/MenuIcons/ellipsis.png")
	return option
end

function UI_LIB:create_enemymultiselect(whereAt, name, singleSelectMode, selectAll, useHeroNames)
	local itemsTable = {}
	if GameRules.GetGameState() >= 4 then
		local heroes = CHeroes.GetEnemiesHeroNames()
		for playerID, enemy in pairs(heroes) do
			if table.find(heroes, enemy) == playerID then
				table.insert(itemsTable, {useHeroNames and enemy or tostring(playerID), "panorama/images/heroes/icons/"..enemy.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return self:create_multiselect(whereAt, name, itemsTable, singleSelectMode)
end

function UI_LIB:create_allymultiselect(whereAt, name, singleSelectMode, selectAll, useHeroNames)
	local itemsTable = {}
	if GameRules.GetGameState() >= 4 then
		local heroes = CHeroes.GetAlliesHeroNames()
		for playerID, enemy in pairs(heroes) do
			if table.find(heroes, enemy) == playerID then
				table.insert(itemsTable, {useHeroNames and enemy or tostring(playerID), "panorama/images/heroes/icons/"..enemy.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return self:create_multiselect(whereAt, name, itemsTable, singleSelectMode)
end

function UI_LIB:create_onlyallymultiselect(whereAt, name, singleSelectMode, selectAll, useHeroNames)
	local itemsTable = {}
	if GameRules.GetGameState() >= 4 then
		local heroes = CHeroes.GetAlliesOnlyHeroNames()
		for playerID, enemy in pairs(heroes) do
			if table.find(heroes, enemy) == playerID then
				table.insert(itemsTable, {useHeroNames and enemy or tostring(playerID), "panorama/images/heroes/icons/"..enemy.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return self:create_multiselect(whereAt, name, itemsTable, singleSelectMode)
end

function UI_LIB:create_color(whereAt, name, r, g, b, a)
	local option = UI_LIB_OPTION_COLOR:new(whereAt, name, r, g, b, a)
	return option
end

function UI_LIB:create_input(whereAt, name, defaultString)
	local option = UI_LIB_OPTION_INPUT:new(whereAt, name, defaultString)
	return option
end

function UI_LIB:set_tab_icon(whereAt, icon_path)
	if icon_path == nil then
		return Menu.RemoveMenuIcon(whereAt)
	end
	return Menu.AddMenuIcon(whereAt, icon_path)
end

return UI_LIB:new()