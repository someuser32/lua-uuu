require("lib")

local Griefing = {}
local update_tick = 0

function Griefing.OnLoad()
	Griefing.griefing_enable = Menu.AddOptionBool({"Utility", "Griefing"}, "Enabled", false)
	Menu.AddOptionIcon(Griefing.griefing_enable, "~/MenuIcons/Enable/enable_ios.png")


	Griefing.griefing_buybot = Menu.AddOptionMultiSelect({"Utility", "Griefing"}, "Buy spam", {
		{"42|item_ward_observer,item_ward_dispenser", "panorama/images/items/ward_observer_png.vtex_c", false},
		{"43|item_ward_sentry,item_ward_dispenser", "panorama/images/items/ward_sentry_png.vtex_c", false},
		{"40|item_dust", "panorama/images/items/dust_png.vtex_c", false},
	}, false)
	Menu.AddOptionIcon(Griefing.griefing_buybot, "~/MenuIcons/ellipsis.png")

	Griefing.minimap_spam_enable = Menu.AddOptionBool({"Utility", "Griefing"}, "Minimap draw spam", false)
	Menu.AddOptionIcon(Griefing.minimap_spam_enable, "~/MenuIcons/block_wall.png")

	Griefing.ping_types = {
		{"INFO", "default"},
		{"WARNING", "alternative"},
		{"LOCATION", "location"},
		{"DANGER", "danger"},
		{"ATTACK", "attack"},
		{"ENEMY_VISION", "enemy vision"},
		{"OWN_VISION", "ally vision"},
	}
	Griefing.ping_type = Menu.AddOptionCombo({"Utility", "Griefing"}, "Ping type", table.map(Griefing.ping_types, function(k,v) return v[2] end), 0)
	Menu.AddOptionIcon(Griefing.ping_type, "~/MenuIcons/Lists/single_choice.png")


	Menu.AddMenuIcon({"Utility", "Griefing"}, "~/MenuIcons/enemy_evil.png")

	Griefing.OnGameStart()
end

function Griefing.OnGameStart()
	if GameRules.GetGameState() >= 4 then
		local localhero = Heroes.GetLocal()
		local localplayerID = Player.GetPlayerID(Players.GetLocal())
		local allies = {}
		for _, hero in pairs(Heroes.GetAll()) do
			local playerID = Hero.GetPlayerID(hero)
			if playerID ~= localplayerID and Entity.IsSameTeam(hero, localhero) then
				table.insert(allies, {tostring(playerID), "panorama/images/heroes/icons/"..NPC.GetUnitName(hero).."_png.vtex_c", false})
			end
		end

		Griefing.ping_selector = Menu.AddOptionMultiSelect({"Utility", "Griefing"}, "Ping", allies, false)
		Menu.AddOptionIcon(Griefing.ping_selector, "~/MenuIcons/ellipsis.png")


		Griefing.movetarget_selector = Menu.AddOptionMultiSelect({"Utility", "Griefing"}, "Move target", allies, true)
		Menu.AddOptionIcon(Griefing.movetarget_selector, "~/MenuIcons/ellipsis.png")
	end
end

function Griefing.OnGameEnd()
	Menu.RemoveOption(Griefing.ping_selector)
	Menu.RemoveOption(Griefing.movetarget_selector)
end

function Griefing.OnUpdate()
	if GameRules.GetGameState() >= 4 then
		if Menu.IsEnabled(Griefing.griefing_enable) then
			update_tick = update_tick + 1
			local localhero = Heroes.GetLocal()
			local localplayer = Players.GetLocal()
			local heroes = Heroes.GetAll()
			if update_tick % 60 == 0 then
				for _, hero in pairs(heroes) do
					local playerID = Hero.GetPlayerID(hero)
					if Menu.IsSelected(Griefing.movetarget_selector, tostring(playerID)) then
						Player.PrepareUnitOrders(localplayer, Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET, hero, nil, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, localhero, false, true, false)
					end
				end
			end
			if update_tick % 20 == 0 then
				for _, _item_info in pairs(Menu.GetItems(Griefing.griefing_buybot)) do
					if Menu.IsSelected(Griefing.griefing_buybot, _item_info) then
						local item_info = string.split(_item_info, "|")
						local item_id = tonumber(item_info[1])
						local item_names = string.split(item_info[2], ",")
						for _, item_name in pairs(item_names) do
							local item = NPC.GetItem(localhero, item_name) or GetItemInStash(localhero, item_name)
							if item ~= nil then
								Player.PrepareUnitOrders(localplayer, Enum.UnitOrder.DOTA_UNIT_ORDER_SELL_ITEM, nil, nil, item, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, localhero, false, true, false)
							end
						end
						Player.PrepareUnitOrders(localplayer, Enum.UnitOrder.DOTA_UNIT_ORDER_PURCHASE_ITEM, nil, nil, item_id, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, localhero, false, true, false)
					end
				end
				for _, hero in pairs(heroes) do
					if Menu.IsSelected(Griefing.ping_selector, tostring(Hero.GetPlayerID(hero))) then
						MiniMap.Ping(Entity.GetAbsOrigin(hero), Enum.PingType["PINGTYPE_"..table.map(Griefing.ping_types, function(k,v) return v[1] end)[Menu.GetValue(Griefing.ping_type)+1]])
						if not Entity.IsAlive(hero) then
							Player.PrepareUnitOrders(localplayer, Enum.UnitOrder.DOTA_UNIT_ORDER_PING_ABILITY, hero, nil, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, localhero, false, true, false)
						end
					end
				end
			end
			if update_tick % 120 == 0 then
				if Menu.IsEnabled(Griefing.minimap_spam_enable) then
					for i=-7000, 7000, 100 do
						MiniMap.SendLine(Vector(-7000, i, 0), true)
						MiniMap.SendLine(Vector(7000, i, 0), false)
					end
				end
			end
		end
	end
end

Griefing:OnLoad()
return Griefing