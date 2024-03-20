local class = require("lib/middleclass")

KVLib = class("KVLib")

function KVLib:initialize()
	-- self.VPK_BASE_URL = "https://raw.githubusercontent.com/spirit-bear-productions/dota_vpk_updates/main/"
	self:LoadNPCHeroes()
	self:LoadNPCAbilities()
	self:LoadItems()
end

function KVLib:LoadNPCHeroes()
	local f = assert(io.open("./././assets/data/npc_heroes.json", "r"))
	self.npc_heroes = json:decode(f:read("*a"))["DOTAHeroes"]
	f:close()
end

function KVLib:LoadNPCAbilities()
	local f = assert(io.open("./././assets/data/npc_abilities.json", "r"))
	self.npc_abilities = json:decode(f:read("*a"))["DOTAAbilities"]
	f:close()
end

function KVLib:LoadItems()
	local f = assert(io.open("./././assets/data/items.json", "r"))
	self.items = json:decode(f:read("*a"))["DOTAAbilities"]
	f:close()
end

function KVLib:GetKVAsync(path, callback)
	HTTP.Request("GET", self.VPK_BASE_URL..path, {}, callback)
end

function KVLib:HeroIDToName(id)
	if self.npc_heroes == nil then
		self:LoadNPCHeroes()
		return self:HeroIDToName(id)
	end
	for heroname, kv in pairs(self.npc_heroes) do
		if type(kv) == "table" then
			if kv["HeroID"] == tostring(id) then
				return heroname
			end
		end
	end
end

function KVLib:GetHeroAttribute(name)
	if self.npc_heroes == nil then
		self:LoadNPCHeroes()
		return self:GetHeroAttribute(name)
	end
	return self.npc_heroes[name]["AttributePrimary"] or self.npc_heroes["npc_dota_hero_base"]["AttributePrimary"]
end

function KVLib:GetAbilitySpecialKeys(name)
	if not string.startswith(name, "item_") and self.npc_abilities == nil then
		self:LoadNPCAbilities()
		return KVLib:GetAbilitySpecialKeys(name)
	end
	if string.startswith(name, "item_") and self.items == nil then
		self:LoadItems()
		return KVLib:GetAbilitySpecialKeys(name)
	end
	local file = string.startswith(name, "item_") and self.items or self.npc_abilities
	if file[name] == nil then
		return {}
	end
	local keys = {}
	if file[name]["AbilityValues"] ~= nil then
		table.combine(keys, file[name]["AbilityValues"])
	end
	if file[name]["AbilitySpecial"] ~= nil then
		for _, info in pairs(file[name]["AbilitySpecial"]) do
			table.combine(keys, table.values(info))
		end
	end
	return keys
end

return KVLib:new()