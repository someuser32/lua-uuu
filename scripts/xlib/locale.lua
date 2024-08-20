---@class LocaleLib
local LocaleLib = class("LocaleLib")

function LocaleLib:initialize()
	self.attributes = {["DOTA_ATTRIBUTE_STRENGTH"]="Strength", ["DOTA_ATTRIBUTE_AGILITY"]="Agility", ["DOTA_ATTRIBUTE_INTELLECT"]="Intellect", ["DOTA_ATTRIBUTE_ALL"]="Universal"}
end

---@param name string
---@param include_owner boolean?
---@return string | string[]
function LocaleLib:LocalizeAbilityName(name, include_owner)
	local ability_name = string.startswith("item_", name) and GameLocalizer.FindItem(name) or GameLocalizer.FindAbility(name)
	if ability_name == "" then
		ability_name = string.capitalize(string.gsub(string.gsub(name, "item_", ""), "_", " "), true)
	end
	if include_owner then
		if string.startswith(name, "item_") then
			if type(include_owner) == "string" then
				return ability_name
			end
			return {ability_name, ""}
		end
		for owner, abilities in pairs(self.ability_owners) do
			if table.contains(abilities, name) then
				if type(include_owner) == "string" then
					return ability_name.." ("..self:LocalizeHeroName(owner)..")"
				end
				return {ability_name, owner}
			end
		end
	end
	return ability_name
end

---@param name string
---@return string
function LocaleLib:LocalizeAttribute(name)
	return self.attributes[name] or string.capitalize(string.gsub(string.sub(name, 16), "_", " "))
end

return LocaleLib:new()