-- local localhero = Heroes.GetLocal()

-- for k, v in pairs(getmetatable(Vector(0, 0, 0))) do
-- 	Log.Write(k, v)
-- end
-- local entindex = tostring(Entity.GetIndex(localhero))
-- Engine.RunScript("$.Msg(Entities.GetNumBuffs("..entindex.."));")
-- print("buy")
-- Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_PURCHASE_ITEM, nil, nil, 64, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, localhero, false, true, false, false)

-- Renderer.DrawSideNotification()

-- print(Notification({
-- 	id = "test",
-- 	duration = 3,
-- 	timer = 3,
-- 	hero = "npc_dota_hero_invoker",
-- 	primary_text = "Sunstrike",
-- 	primary_image = Render.LoadImage("panorama/images/spellicons/invoker_sun_strike_png.vtex_c"),
-- 	secondary_image = "panorama/images/spellicons/invoker_sun_strike_png.vtex_c",
-- 	secondary_text = "\aDEFAULTCast \a{primary}Sunstrike \aBBAA0033 123",
-- 	-- active = false,
-- 	position = Vector(1, 0, 0),
-- 	sound = "sounds/ui/yoink"
--   }))

return {}