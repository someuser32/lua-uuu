---@param heroname string
---@return string
function GetHeroIconPath(heroname)
	if string.startswith(heroname, "npc_dota_lone_druid_bear") then
		return "panorama/images/spellicons/lone_druid_spirit_bear_png.vtex_c"
	end
	return "panorama/images/heroes/icons/"..heroname.."_png.vtex_c"
end

---@param heroname string
---@return string
function GetHeroTopbarIconPath(heroname)
	if string.startswith(heroname, "npc_dota_lone_druid_bear") then
		return "panorama/images/spellicons/lone_druid_spirit_bear_png.vtex_c"
	end
	return "panorama/images/heroes/"..heroname.."_png.vtex_c"
end

---@param heroname string
---@return string
function GetHeroTopbarIconPathRounded(heroname)
	if string.startswith(heroname, "npc_dota_lone_druid_bear") then
		return "panorama/images/spellicons/lone_druid_spirit_bear_png.vtex_c"
	end
	return "~/heroes_circle/"..string.sub(heroname, #"npc_dota_hero_"+1)..".png"
end

---@param heroname string
---@return string
function GetHeroSelectionIconPath(heroname)
	if string.startswith(heroname, "npc_dota_lone_druid_bear") then
		return "panorama/images/spellicons/lone_druid_spirit_bear_png.vtex_c"
	end
	return "panorama/images/heroes/selection/"..heroname.."_png.vtex_c"
end

---@param v boolean
---@return number
function BoolToNum(v)
	return (v == true and {1} or {0})[1]
end

---@param v number
---@return boolean
function NumToBool(v)
	return v == 1
end

---@param time number
---@param delimeter string?
function format_clock(time, delimeter)
	local min, sec = math.floor(time/60), math.floor(time%60)
	if min < 10 then
		min = "0"..min
	end
	if sec < 10 then
        sec = "0"..sec
	end
	return tostring(min..(delimeter or ":")..sec)
end