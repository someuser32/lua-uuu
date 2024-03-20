function GetHeroIconPath(heroname)
	if string.startswith(heroname, "npc_dota_lone_druid_bear") then
		return "panorama/images/spellicons/lone_druid_spirit_bear_png.vtex_c"
	end
	return "panorama/images/heroes/icons/"..heroname.."_png.vtex_c"
end

function GetHeroTopbarIconPath(heroname)
	if string.startswith(heroname, "npc_dota_lone_druid_bear") then
		return "panorama/images/spellicons/lone_druid_spirit_bear_png.vtex_c"
	end
	return "panorama/images/heroes/"..heroname.."_png.vtex_c"
end

function GetHeroSelectionIconPath(heroname)
	if string.startswith(heroname, "npc_dota_lone_druid_bear") then
		return "panorama/images/spellicons/lone_druid_spirit_bear_png.vtex_c"
	end
	return "panorama/images/heroes/selection/"..heroname.."_png.vtex_c"
end