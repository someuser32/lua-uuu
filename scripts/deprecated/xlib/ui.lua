---@class UILib
local UILib = {}

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param expanded boolean?
---@param selectAll boolean?
---@param useHeroNames boolean?
---@return CMenuMultiSelect
function UILib:CreateMultiselectFromEnemies(parent, name, expanded, selectAll, useHeroNames)
	local itemsTable = {}
	if GameRules.GetGameState() >= 4 then
		local localteam = Players.GetLocalTeam()
		for playerID, hero in pairs(Heroes.GetAllPlayers()) do
			if Entity.GetTeamNum(hero) ~= localteam then
				local hero_name = NPC.GetUnitName(hero)
				table.insert(itemsTable, {useHeroNames and hero_name or tostring(playerID), "panorama/images/heroes/icons/"..hero_name.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return parent:MultiSelect(name, itemsTable, expanded)
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param expanded boolean?
---@param selectAll boolean?
---@param useHeroNames boolean?
---@return CMenuMultiSelect
function UILib:CreateMultiselectFromAllies(parent, name, expanded, selectAll, useHeroNames)
	local itemsTable = {}
	if GameRules.GetGameState() >= 4 then
		local localteam = Players.GetLocalTeam()
		for playerID, hero in pairs(Heroes.GetAllPlayers()) do
			if Entity.GetTeamNum(hero) == localteam then
				local hero_name = NPC.GetUnitName(hero)
				table.insert(itemsTable, {useHeroNames and hero_name or tostring(playerID), "panorama/images/heroes/icons/"..hero_name.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return parent:MultiSelect(name, itemsTable, expanded)
end

---@param parent CMenuGroup | CMenuGearAttachment
---@param name string
---@param selectAll boolean?
---@param useHeroNames boolean?
---@return CMenuMultiSelect
function UILib:CreateMultiselectFromAlliesOnly(parent, name, expanded, selectAll, useHeroNames)
	local itemsTable = {}
	if GameRules.GetGameState() >= 4 then
		local localplayerid = Player.GetPlayerID(Players.GetLocal())
		local localteam = Players.GetLocalTeam()
		for playerID, hero in pairs(Heroes.GetAllPlayers()) do
			if Entity.GetTeamNum(hero) == localteam and playerID ~= localplayerid then
				local hero_name = NPC.GetUnitName(hero)
				table.insert(itemsTable, {useHeroNames and hero_name or tostring(playerID), "panorama/images/heroes/icons/"..hero_name.."_png.vtex_c", selectAll ~= nil and selectAll or false})
			end
		end
	end
	return parent:MultiSelect(name, itemsTable, expanded)
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
	local option = parent:MultiSelect(name or "Include units", unitsTable, true)
	option:Icon("\u{f509}")
	return option
end

return UILib