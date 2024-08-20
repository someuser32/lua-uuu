---@class KVLib
local KVLib = class("KVLib")

function KVLib:initialize()
	self.loaded_kvs = {}
	self.VPK_BASE_URL = "https://raw.githubusercontent.com/spirit-bear-productions/dota_vpk_updates/main/"
	self:GetKV("npc_heroes")
	self:GetKV("npc_abilities")
	self:GetKV("items")
end

---@param name string
---@return nil
function KVLib:LoadKVfromAssetsJSON(name)
	local f = assert(io.open("./././assets/data/"..name..".json", "r"))
	self.loaded_kvs[name] = json:decode(f:read("*a"))
	f:close()
end

---@param name string
---@return nil
function KVLib:LoadKVfromVPK(name)
	-- local data = nil
	-- local t = HTTP.Request("GET", self.VPK_BASE_URL..name, {
	-- 	headers={
	-- 		["authority"] = "raw.githubusercontent.com",
	-- 		["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
	-- 		["accept-language"] = "en-US,en;q=0.9",
	-- 		["dnt"] = "1",
	-- 		["sec-ch-ua"] = "\"Not_A Brand\";v=\"8\", \"Chromium\";v=\"120\", \"Google Chrome\";v=\"120\"",
	-- 		["sec-ch-ua-mobile"] = "?0",
	-- 		["sec-ch-ua-platform"] = "\"Windows\"",
	-- 		["sec-fetch-dest"] = "document",
	-- 		["sec-fetch-mode"] = "navigate",
	-- 		["sec-fetch-site"] = "cross-site",
	-- 		["sec-fetch-user"] = "?1",
	-- 		["upgrade-insecure-requests"] = "1",
	-- 		["Referer"] = self.VPK_BASE_URL,
	-- 		["Referrer-Policy"] = "no-referrer-when-downgrade",
	-- 		["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
	-- 	}
	-- }, function(r)
	-- 	if r.code ~= 200 then
	-- 		data = "nil"
	-- 		return
	-- 	end
	-- 	data = r.response
	-- end)
	-- while data == nil do
	-- end
	-- if data == "nil" then
	-- 	return nil
	-- end
end

---@param name string
---@return table
function KVLib:GetKV(name)
	if self.loaded_kvs[name] ~= nil then
		return self.loaded_kvs[name]
	end
	local f = io.open("./././assets/data/"..name..".json", "r")
	if f ~= nil then
		f:close()
		self:LoadKVfromAssetsJSON(name)
		return self:GetKV(name)
	end
	return {}
end

---@param id integer
---@return string?
function KVLib:HeroIDToName(id)
	local npc_heroes = self:GetKV("npc_heroes")
	for heroname, kv in pairs(npc_heroes["DOTAHeroes"]) do
		if type(kv) == "table" then
			if kv["HeroID"] == tostring(id) then
				return heroname
			end
		end
	end
end

---@param name string
---@return string
function KVLib:GetHeroAttribute(name)
	local npc_heroes = self:GetKV("npc_heroes")
	return npc_heroes["DOTAHeroes"][name]["AttributePrimary"] or self.npc_heroes["DOTAHeroes"]["npc_dota_hero_base"]["AttributePrimary"]
end

---@param name string
---@return string[]
function KVLib:GetAbilitySpecialKeys(name)
	local kv = not CAbility:IsItemName(name) and self:GetKV("npc_abilities") or self:GetKV("items")
	local ability = kv["DOTAAbilities"][name]
	if not ability then
		return {}
	end
	local keys = {}
	if ability["AbilityValues"] ~= nil then
		keys = table.combine(keys, table.keys(ability["AbilityValues"]))
	end
	if ability["AbilitySpecial"] ~= nil then
		for _, info in pairs(ability["AbilitySpecial"]) do
			keys = table.combine(keys, table.values(info))
		end
	end
	return keys
end

---@param name string
---@return Enum.AbilityBehavior
function KVLib:GetAbilityBehavior(name)
	local kv = not CAbility:IsItemName(name) and self:GetKV("npc_abilities") or self:GetKV("items")
	local ability = kv["DOTAAbilities"][name]
	if not ability or ability["AbilityBehavior"] == nil then
		return Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NONE
	end
	return table.sum(table.map(string.split(ability["AbilityBehavior"], " | "), function(_, behavior)
		return Enum.AbilityBehavior[behavior] or Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NONE
	end))
end

---@param name string
---@return table
function KVLib:GetUnitKV(name)
	local npc_heroes = self:GetKV("npc_heroes")
	local npc_units = self:GetKV("npc_units")
	local kv = npc_heroes["DOTAHeroes"][name]
	local base_kv = npc_heroes["DOTAHeroes"]["npc_dota_hero_base"]
	if kv == nil then
		kv = npc_units["DOTAUnits"][name]
		base_kv = npc_units["DOTAUnits"]["npc_dota_base"]
	end
	if kv == nil then
		return nil
	end
	return table.merge(base_kv, kv)
end

return KVLib:new()