local abilities_owners = {}

---@param name string
---@param flags Enum.LocaleFlags?
---@return string | string[]
function GameLocalizer.LocalizeAbilityName(name, flags)
	flags = flags or Enum.LocaleFlags.UNKNOWN
	local ability_name = Ability.IsItemName(name) and GameLocalizer.FindItem(name) or GameLocalizer.FindAbility(name)
	if ability_name == "" then
		ability_name = string.capitalize(string.gsub(string.gsub(name, "item_", ""), "_", " "), true)
	end
	local include_owner = flags & Enum.LocaleFlags.OWNER == Enum.LocaleFlags.OWNER and Enum.LocaleFlags.OWNER or (flags & Enum.LocaleFlags.OWNER_TABLE == Enum.LocaleFlags.OWNER_TABLE and Enum.LocaleFlags.OWNER_TABLE or Enum.LocaleFlags.UNKNOWN)
	if include_owner ~= Enum.LocaleFlags.UNKNOWN then
		if Ability.IsItemName(name) then
			return include_owner == Enum.LocaleFlags.OWNER and ability_name or {ability_name, ""}
		end
		for owner, abilities in pairs(abilities_owners) do
			if table.contains(abilities, name) then
				return include_owner == Enum.LocaleFlags.OWNER and ability_name or {ability_name, owner}
			end
		end
	end
	return ability_name
end

---@param name string
---@return string
function GameLocalizer.LocalizeAttribute(name)
	local attributes = {["DOTA_ATTRIBUTE_STRENGTH"]="Strength", ["DOTA_ATTRIBUTE_AGILITY"]="Agility", ["DOTA_ATTRIBUTE_INTELLECT"]="Intellect", ["DOTA_ATTRIBUTE_ALL"]="Universal"}
	return attributes[name] or string.capitalize(string.gsub(string.sub(name, 16), "_", " "))
end

for owner, kv in pairs(table.merge(KVLib:GetKV("npc_heroes")["DOTAHeroes"], KVLib:GetKV("npc_units")["DOTAUnits"])) do
	abilities_owners[owner] = {}
	for i=1, 35 do
		local ability_name = kv["Ability"..tostring(i)]
		if ability_name ~= "" then
			table.insert(abilities_owners[owner], ability_name)
		end
	end
end