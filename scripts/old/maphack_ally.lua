require("lib")

local MaphackAlly = {}

local minimap_ally_enable = Menu.AddOptionBool({"Info Screen", "Map Hack (ally)"}, "Enabled", false)
Menu.AddOptionIcon(minimap_ally_enable, "~/MenuIcons/Enable/enable_ios.png")

local minimap_ally_map_teleports = Menu.AddOptionBool({"Info Screen", "Map Hack (ally)", "Minimap"}, "Teleports", false)
Menu.AddOptionIcon(minimap_ally_map_teleports, "~/MenuIcons/line_dashed.png")
local minimap_ally_map_scan = Menu.AddOptionBool({"Info Screen", "Map Hack (ally)", "Minimap"}, "Scan", false)
Menu.AddOptionIcon(minimap_ally_map_scan, "~/MenuIcons/radius.png")
local minimap_ally_map_wisp = Menu.AddOptionBool({"Info Screen", "Map Hack (ally)", "Minimap"}, "IO position", false)
Menu.AddOptionIcon(minimap_ally_map_wisp, "~/heroes_circle/wisp.png")

local minimap_ally_chat_language = Menu.AddOptionCombo({"Info Screen", "Map Hack (ally)", "Chat"}, "Language", {"English", "Русский"}, 0)
Menu.AddOptionIcon(minimap_ally_chat_language, "~/MenuIcons/google_translate.png")
local minimap_ally_chat_teleports = Menu.AddOptionBool({"Info Screen", "Map Hack (ally)", "Chat"}, "Teleports", false)
Menu.AddOptionIcon(minimap_ally_chat_teleports, "~/MenuIcons/Dota/tp_scroll.png")
local minimap_ally_chat_scan = Menu.AddOptionBool({"Info Screen", "Map Hack (ally)", "Chat"}, "Scan", false)
Menu.AddOptionIcon(minimap_ally_chat_scan, "~/MenuIcons/radar_scan.png")
-- local minimap_ally_chat_vbe = Menu.AddOptionBool({"Info Screen", "Map Hack (ally)", "Chat"}, "Visible by Enemy", false)
-- Menu.AddOptionIcon(minimap_ally_chat_vbe, "~/MenuIcons/Notifications/eye_search.png")

Menu.AddMenuIcon({"Info Screen", "Map Hack (ally)"}, "~/MenuIcons/eye_scan.png")
Menu.AddMenuIcon({"Info Screen", "Map Hack (ally)", "Minimap"}, "~/MenuIcons/google_maps.png")
Menu.AddMenuIcon({"Info Screen", "Map Hack (ally)", "Chat"}, "~/MenuIcons/chat.png")

function MaphackAlly.OnLoad()
	MaphackAlly.teleport = {
		["start_particle"]="teleport_start",
		["end_particle"]="teleport_end",
		["start"]={},
		["end"]={},
		["teleports"]={},
		["chat"]={
			[0]={
				["use_teleport"]="is using teleport!",
			},
			[1]={
				["use_teleport"]="использует телепорт!",
			},
		},
	}
	MaphackAlly.scan = {
		["modifier"]="modifier_radar_thinker",
		["radius"]=900,
		["chat"]={
			[0]={
				["use_scan"]="Enemies are scaning!",
			},
			[1]={
				["use_scan"]="Враги используют скан!",
			},
		},
	}
end

function MaphackAlly.DrawTeleport(entity, start_pos, end_pos)
	if Menu.IsEnabled(minimap_ally_map_teleports) then
		local direction = (end_pos-start_pos):Normalized()
		local end_pos_line = end_pos+direction:Scaled(-300)
		local arrow_size = math.min(math.max(300, (end_pos-start_pos):Length()/10), 1000)
		local arrow_left = end_pos_line+(direction:Rotated(Angle(0, -30, 0)):Scaled(arrow_size*-1))
		local arrow_right = end_pos_line+(direction:Rotated(Angle(0, 30, 0)):Scaled(arrow_size*-1))
		local circle_end = getcircle(end_pos:GetX(), end_pos:GetY(), 275, 275/5)
		for i, xy in pairs(circle_end) do
			MiniMap.SendLine(Vector(xy[1], xy[2]), i==1)
		end
		MiniMap.SendLine(end_pos_line, true)
		MiniMap.SendLine(arrow_left, false)
		MiniMap.SendLine(end_pos_line, true)
		MiniMap.SendLine(arrow_right, false)
		MiniMap.SendLine(start_pos, true)
		MiniMap.SendLine(end_pos_line, false)
		MiniMap.Ping(start_pos, Enum.PingType.PINGTYPE_LOCATION)
	end
	if Menu.IsEnabled(minimap_ally_chat_teleports) then
		Engine.ExecuteCommand("say_team "..localize_hero(NPC.GetUnitName(entity)).." "..MaphackAlly.teleport["chat"][Menu.GetValue(minimap_ally_chat_language)]["use_teleport"])
	end
end

function MaphackAlly.TryDrawTeleport(entity)
	local index = MaphackAlly.GetTeleportInfoIndex(entity)
	if index ~= nil then
		local info = MaphackAlly.teleport["teleports"][index]
		if info["start_pos"] ~= nil and info["end_pos"] ~= nil then
			MaphackAlly.DrawTeleport(entity, info["start_pos"], info["end_pos"])
			MaphackAlly.teleport["teleports"][index] = nil
		end
	end
end

function MaphackAlly.GetTeleportInfoIndex(entity)
	for i, info in pairs(MaphackAlly.teleport["teleports"]) do
		if info["entity"] == entity then
			return i
		end
	end
	return nil
end

function MaphackAlly.OnParticleCreate(particle)
    if Menu.IsEnabled(minimap_ally_enable) then
		local entity = particle.entityForModifiers
		local localentity = Heroes.GetLocal()
		if entity ~= nil and Entity.GetTeamNum(entity) ~= Entity.GetTeamNum(localentity) then
			if particle.name == MaphackAlly.teleport["start_particle"] then
				MaphackAlly.teleport["start"][particle.index] = entity
			elseif particle.name == MaphackAlly.teleport["end_particle"] then
				MaphackAlly.teleport["end"][particle.index] = entity
			end
		end
	end
end

function MaphackAlly.OnParticleUpdate(particle)
    if Menu.IsEnabled(minimap_ally_enable) then
		if MaphackAlly.teleport["start"][particle.index] ~= nil then
			local entity = MaphackAlly.teleport["start"][particle.index]
			local info_index = MaphackAlly.GetTeleportInfoIndex(entity)
			if info_index ~= nil then
				MaphackAlly.teleport["teleports"][info_index]["start_pos"] = particle.position
			else
				table.insert(MaphackAlly.teleport["teleports"], {entity=entity, start_pos=particle.position})
			end
			MaphackAlly.teleport["start"][particle.index] = nil
			MaphackAlly.TryDrawTeleport(entity)
		elseif MaphackAlly.teleport["end"][particle.index] ~= nil then
			local entity = MaphackAlly.teleport["end"][particle.index]
			local info_index = MaphackAlly.GetTeleportInfoIndex(entity)
			if info_index ~= nil then
				MaphackAlly.teleport["teleports"][info_index]["end_pos"] = particle.position
			else
				table.insert(MaphackAlly.teleport["teleports"], {entity=entity, end_pos=particle.position})
			end
			MaphackAlly.teleport["end"][particle.index] = nil
			MaphackAlly.TryDrawTeleport(entity)
		end
	end
end

function MaphackAlly.OnParticleUpdateEntity(particle)
    if Menu.IsEnabled(minimap_ally_enable) then
		if Menu.IsEnabled(minimap_ally_map_wisp) then
			local localhero = Heroes.GetLocal()
			for _, hero in pairs(Heroes.GetAll()) do
				if Entity.GetIndex(hero) == particle["entIdx"] and NPC.GetUnitName(hero) == "npc_dota_hero_wisp" and not Entity.IsSameTeam(hero, localhero) and not NPC.IsVisible(hero) then
					for i, xy in pairs(getcircle(particle["position"]:GetX(), particle["position"]:GetY(), 100, 100)) do
						MiniMap.SendLine(Vector(xy[1], xy[2]), i==1)
					end
					for i, xy in pairs(getcircle(particle["position"]:GetX(), particle["position"]:GetY(), 350, 15)) do
						if FogOfWar.IsPointVisible(Vector(xy[1], xy[2], World.GetGroundZ(xy[1], xy[1]))) then
							MiniMap.Ping(particle["position"], Enum.PingType.PINGTYPE_WARNING)
							break
						end
					end
					break
				end
			end
		end
	end
end

function MaphackAlly.OnModifierCreate(ent, mod)
    if Menu.IsEnabled(minimap_ally_enable) then
		local localhero = Heroes.GetLocal()
		if Modifier.GetName(mod) == MaphackAlly.scan["modifier"] and not Entity.IsSameTeam(ent, localhero) then
			if Menu.IsEnabled(minimap_ally_map_scan) then
				local position = Entity.GetAbsOrigin(ent)
				for i, xy in pairs(getcircle(position:GetX(), position:GetY(), MaphackAlly.scan["radius"], MaphackAlly.scan["radius"]/10)) do
					MiniMap.SendLine(Vector(xy[1], xy[2]), i==1)
				end
				MiniMap.Ping(position, Enum.PingType.PINGTYPE_INFO)
			end
			if Menu.IsEnabled(minimap_ally_chat_scan) then
				Engine.ExecuteCommand("say_team "..MaphackAlly.scan["chat"][Menu.GetValue(minimap_ally_chat_language)]["use_scan"])
			end
		end
	end
end

MaphackAlly:OnLoad()
return MaphackAlly