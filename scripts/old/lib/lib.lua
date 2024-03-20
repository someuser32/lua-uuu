math.randomseed(os.time())

_G.json = require("lib/JSON")

require("lib/deepprint")

function math.randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function string.split(str, sep)
	if sep == nil then sep = "%s" end
	local match = sep ~= "" and "([^"..sep.."]+)" or "."
	local t = {}
	for s in string.gmatch(str, match) do
		table.insert(t, s)
	end
	return t
end

function string.startswith(str, find)
	return string.sub(str, 1, string.len(find)) == find
end

function string.endswith(str, find)
	return string.sub(str, string.len(str)-string.len(find)+1, string.len(str)) == find
end

function table.copy(t)
	if type(t) ~= "table" then return {} end
	local result = {}
	for k,v in pairs(t) do
		result[k] = v
	end
	return result
end

function table.any(t)
	if type(t) ~= "table" then return false end
	for k,v in pairs(t) do
		if v == true then
			return true
		end
	end
	return false
end

function table.all(t)
	if type(t) ~= "table" then return false end
	for k,v in pairs(t) do
		if v == false then
			return false
		end
	end
	return #table.values(t) > 0
end

-- function table.copy(o)
-- 	if o == nil then return nil end
-- 	if type(o) == "table" and o.class ~= nil and o.class.name ~= nil then return o end
-- 	local no = {}
-- 	for k, v in next, o, nil do
-- 		k = (type(k) == 'table') and table.copy(k) or k
-- 		v = (type(v) == 'table') and table.copy(v) or v
-- 		no[k] = v
-- 	end
-- 	return no
-- end

function table.removeElement(t, el)
	local pos = table.find(t, el)
	table.remove(t, pos)
	return pos
end

function table.find(t, e)
	for k,v in pairs(t) do
		if v == e then
			return k
		end
	end
end

function table.finddeep(t, e)
	for k,v in pairs(t) do
		if (type(v) ~= "table" or type(e) ~= "table") and v == e then
			return k
		elseif type(v) == "table" and type(e) == "table" and table.equals(v, e) then
			return k
		end
	end
end

function table.containsdeep(t, e)
	for k,v in pairs(t) do
		if (type(v) ~= "table" or type(e) ~= "table") and v == e then
			return true
		elseif type(v) == "table" and type(e) == "table" and table.equals(v, e) then
			return true
		end
	end
	return false
end

function table.contains(t, e)
	for k, v in pairs(t) do
		if v == e then
			return true
		end
	end
	return false
end

function table.equals(t1, t2, ignore_mt)
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not table.equals(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not table.equals(v1,v2) then return false end
	end
	return true
end

function table.merge(t1, t2)
	local t = table.copy(t1)
	if type(t2) == "table" then
		for k, v in pairs(t2) do
			t[k] = v
		end
	end
	return t
end

function table.combine(t1, t2)
	local t = table.copy(t1)
	for k, v in pairs(type(t2) == "table" and t2 or {t2}) do
		table.insert(t, v)
	end
	return t
end

function table.filter(t, fc)
	local tt = {}
	for k,v in pairs(t) do
		-- if pcall(fc, k, v) == true and fc(k, v) == true then
		if fc(k, v) == true then
			tt[k] = v
		end
	end
	return tt
end

function table.keys(t)
	local keys = {}
	for k,v in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

function table.values(t)
	local values = {}
	for k,v in pairs(t) do
		table.insert(values, v)
	end
	return values
end

function table.length(t)
	return #table.values(t)
end

function table.map(t, fc)
	local tt = {}
	for k,v in pairs(t) do
		-- if pcall(fc, k, v) == true then
			tt[k] = fc(k, v)
		-- end
	end
	return tt
end

function table.alltypeof(t, typ)
	for k, v in pairs(t) do
		if type(v) ~= typ then
			return false
		end
	end
	return table.length(t) > 0
end

function positionIsBetween(position, v1, v2, tolerance)
	tolerance = tolerance or 50;
	if (position:GetX() >= math.max(v1:GetX(), v2:GetX()) + tolerance) or (position:GetX() <= math.min(v1:GetX(), v2:GetX()) - tolerance) or (position:GetY() <= math.min(v1:GetY(), v2:GetY()) - tolerance) or (position:GetY() >= math.max(v1:GetY(), v2:GetY()) + tolerance) then
		return false;
	elseif v1:GetX() == v2:GetX() then
		return math.abs(v1:GetX() - position:GetX()) < tolerance;
	elseif v1:GetY() == v2:GetY() then
		return math.abs(v1:GetY() - position:GetY()) < tolerance;
	end
	return math.abs(((v2:GetX() - v1:GetX()) * (v1:GetY() - position:GetY())) - ((v1:GetX() - position:GetX()) * (v2:GetY() - v1:GetY()))) / math.sqrt((v2:GetX() - v1:GetX()) * (v2:GetX() - v1:GetX()) + (v2:GetY() - v1:GetY()) * (v2:GetY() - v1:GetY())) < tolerance;
end

function string.capitalize(str, every)
	if every then
		return string.sub(string.gsub(" "..str, "%W%l", string.upper), 2)
	end
    return string.gsub(str, "^%l", string.upper)
end

function LocalizeHeroName(name)
	local t = {["npc_dota_hero_queenofpain"]="Queen of Pain",["npc_dota_hero_antimage"]="Anti-Mage",["npc_dota_hero_kunkka"]="Kunkka",["npc_dota_hero_lina"]="Lina",["npc_dota_hero_mirana"]="Mirana",["npc_dota_hero_slardar"]="Slardar",["npc_dota_hero_lion"]="Lion",["npc_dota_hero_phantom_assassin"]="Phantom Assassin",["npc_dota_hero_tidehunter"]="Tidehunter",["npc_dota_hero_witch_doctor"]="Witch Doctor",["npc_dota_hero_vengefulspirit"]="Vengeful Spirit",["npc_dota_hero_juggernaut"]="Juggernaut",["npc_dota_hero_earthshaker"]="Earthshaker",["npc_dota_hero_pudge"]="Pudge",["npc_dota_hero_bane"]="Bane",["npc_dota_hero_crystal_maiden"]="Crystal Maiden",["npc_dota_hero_sven"]="Sven",["npc_dota_hero_skeleton_king"]="Wraith King",["npc_dota_hero_storm_spirit"]="Storm Spirit",["npc_dota_hero_sand_king"]="Sand King",["npc_dota_hero_nevermore"]="Shadow Fiend",["npc_dota_hero_drow_ranger"]="Drow Ranger",["npc_dota_hero_axe"]="Axe",["npc_dota_hero_bloodseeker"]="Bloodseeker",["npc_dota_hero_phantom_lancer"]="Phantom Lancer",["npc_dota_hero_razor"]="Razor",["npc_dota_hero_morphling"]="Morphling",["npc_dota_hero_zuus"]="Zeus",["npc_dota_hero_tiny"]="Tiny",["npc_dota_hero_puck"]="Puck",["npc_dota_hero_windrunner"]="Windranger",["npc_dota_hero_lich"]="Lich",["npc_dota_hero_shadow_shaman"]="Shadow Shaman",["npc_dota_hero_riki"]="Riki",["npc_dota_hero_enigma"]="Enigma",["npc_dota_hero_tinker"]="Tinker",["npc_dota_hero_sniper"]="Sniper",["npc_dota_hero_necrolyte"]="Necrophos",["npc_dota_hero_warlock"]="Warlock",["npc_dota_hero_beastmaster"]="Beastmaster",["npc_dota_hero_venomancer"]="Venomancer",["npc_dota_hero_faceless_void"]="Faceless Void",["npc_dota_hero_death_prophet"]="Death Prophet",["npc_dota_hero_pugna"]="Pugna",["npc_dota_hero_templar_assassin"]="Templar Assassin",["npc_dota_hero_viper"]="Viper",["npc_dota_hero_luna"]="Luna",["npc_dota_hero_dragon_knight"]="Dragon Knight",["npc_dota_hero_dazzle"]="Dazzle",["npc_dota_hero_rattletrap"]="Clockwerk",["npc_dota_hero_leshrac"]="Leshrac",["npc_dota_hero_furion"]="Nature's Prophet",["npc_dota_hero_life_stealer"]="Lifestealer",["npc_dota_hero_dark_seer"]="Dark Seer",["npc_dota_hero_clinkz"]="Clinkz",["npc_dota_hero_omniknight"]="Omniknight",["npc_dota_hero_enchantress"]="Enchantress",["npc_dota_hero_huskar"]="Huskar",["npc_dota_hero_night_stalker"]="Night Stalker",["npc_dota_hero_broodmother"]="Broodmother",["npc_dota_hero_bounty_hunter"]="Bounty Hunter",["npc_dota_hero_weaver"]="Weaver",["npc_dota_hero_jakiro"]="Jakiro",["npc_dota_hero_batrider"]="Batrider",["npc_dota_hero_chen"]="Chen",["npc_dota_hero_spectre"]="Spectre",["npc_dota_hero_doom_bringer"]="Doom",["npc_dota_hero_ancient_apparition"]="Ancient Apparition",["npc_dota_hero_ursa"]="Ursa",["npc_dota_hero_spirit_breaker"]="Spirit Breaker",["npc_dota_hero_gyrocopter"]="Gyrocopter",["npc_dota_hero_alchemist"]="Alchemist",["npc_dota_hero_invoker"]="Invoker",["npc_dota_hero_silencer"]="Silencer",["npc_dota_hero_obsidian_destroyer"]="Outworld Destroyer",["npc_dota_hero_lycan"]="Lycan",["npc_dota_hero_brewmaster"]="Brewmaster",["npc_dota_hero_shadow_demon"]="Shadow Demon",["npc_dota_hero_lone_druid"]="Lone Druid",["npc_dota_hero_chaos_knight"]="Chaos Knight",["npc_dota_hero_treant"]="Treant Protector",["npc_dota_hero_meepo"]="Meepo",["npc_dota_hero_ogre_magi"]="Ogre Magi",["npc_dota_hero_undying"]="Undying",["npc_dota_hero_rubick"]="Rubick",["npc_dota_hero_disruptor"]="Disruptor",["npc_dota_hero_nyx_assassin"]="Nyx Assassin",["npc_dota_hero_naga_siren"]="Naga Siren",["npc_dota_hero_keeper_of_the_light"]="Keeper of the Light",["npc_dota_hero_visage"]="Visage",["npc_dota_hero_wisp"]="Io",["npc_dota_hero_slark"]="Slark",["npc_dota_hero_medusa"]="Medusa",["npc_dota_hero_troll_warlord"]="Troll Warlord",["npc_dota_hero_centaur"]="Centaur Warrunner",["npc_dota_hero_magnataur"]="Magnus",["npc_dota_hero_shredder"]="Timbersaw",["npc_dota_hero_bristleback"]="Bristleback",["npc_dota_hero_tusk"]="Tusk",["npc_dota_hero_skywrath_mage"]="Skywrath Mage",["npc_dota_hero_abaddon"]="Abaddon",["npc_dota_hero_elder_titan"]="Elder Titan",["npc_dota_hero_legion_commander"]="Legion Commander",["npc_dota_hero_ember_spirit"]="Ember Spirit",["npc_dota_hero_earth_spirit"]="Earth Spirit",["npc_dota_hero_abyssal_underlord"]="Underlord",["npc_dota_hero_phoenix"]="Phoenix",["npc_dota_hero_terrorblade"]="Terrorblade",["npc_dota_hero_oracle"]="Oracle",["npc_dota_hero_techies"]="Techies",["npc_dota_hero_target_dummy"]="Target Dummy",["npc_dota_hero_winter_wyvern"]="Winter Wyvern",["npc_dota_hero_arc_warden"]="Arc Warden",["npc_dota_hero_monkey_king"]="Monkey King",["npc_dota_hero_pangolier"]="Pangolier",["npc_dota_hero_dark_willow"]="Dark Willow",["npc_dota_hero_grimstroke"]="Grimstroke",["npc_dota_hero_mars"]="Mars",["npc_dota_hero_snapfire"]="Snapfire",["npc_dota_hero_void_spirit"]="Void Spirit",["npc_dota_hero_hoodwink"]="Hoodwink",["npc_dota_hero_dawnbreaker"]="Dawnbreaker",["npc_dota_hero_marci"]="Marci",["npc_dota_hero_primal_beast"]="Primal Beast",["npc_dota_hero_muerta"]="Muerta"}
	return t[name] or string.capitalize(string.gsub(string.sub(name, 15), "_", " "), true)
end

function LocalizeAttribute(name)
	local t = {["DOTA_ATTRIBUTE_STRENGTH"]="Strength", ["DOTA_ATTRIBUTE_AGILITY"]="Agility", ["DOTA_ATTRIBUTE_INTELLECT"]="Intellect", ["DOTA_ATTRIBUTE_ALL"]="Universal"}
	return t[name] or string.capitalize(string.gsub(string.sub(name, 16), "_", " "))
end

function GetPingDelay()
	return NetChannel.GetLatency(Enum.Flow.MAX_FLOWS) * 2 + 0.1
end

function AngleBetweenVectors(v1, v2, min)
	local angle = math.deg(math.atan2(v2:GetY(), v2:GetX()) - math.atan2(v1:GetY(), v1:GetX()))
	if min then
		angle = math.abs(angle)
		if angle > 180 then
			return angle - 180
		end
	end
	return angle
end

function PlaySound(sound)
	return Engine.RunScript("Game.EmitSound('"..sound.."')")
end

function GetGroundPosition(position)
	return Vector(position:GetX(), position:GetY(), World.GetGroundZ(position))
end

function RollPercentage(chance)
	return math.random(0, 100) >= (100-chance)
end

function CalculateArc(start_height, max_height, duration)
	if max_height < start_height then
		max_height = start_height+0.01
	end
	if max_height <= 0 then
		max_height = 0.01
	end
	local duration_end = (1 + math.sqrt(1 - start_height/max_height))/2
	return {4*max_height*duration_end/duration, 4*max_height*duration_end*duration_end/(duration*duration)}
end

function CalculateArcForTime(start_height, max_height, duration, current)
	local const1, const2 = table.unpack(CalculateArc(start_height, max_height, duration))
	current = math.min(current, duration)
	local height = const1 * current - const2*current*current
	return math.max(start_height, height)
end

function CalculateArcMaxDuration(start_height, max_height, current_height, current, max_duration)
	local current_duration = math.max(0, current/2)
	-- local current_duration = 0
	local max_durations = {}
	while current_duration < max_duration do
		current_duration = current_duration + 0.01
		local height = CalculateArcForTime(start_height, max_height, current_duration, current)
		table.insert(max_durations, {current_duration, math.abs(height-current_height)})
	end
	table.sort(max_durations, function(a, b)
		return a[2] < b[2]
	end)
	return max_durations[1] ~= nil and max_durations[1][1] or nil
end

_G.KVLib = require("lib/kv_lib")

require("lib/object_lib")

_G.UI_LIB = require("lib/ui_lib")

_G.LinkenBreaker = require("lib/linken_breaker")
_G.SpellReflect = require("lib/spell_reflect")