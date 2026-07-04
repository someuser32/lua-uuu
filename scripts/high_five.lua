local AutoHighFive = {
	radius = 900,

	modifier_name = "modifier_plus_high_five_requested",
}

function AutoHighFive:Init()
	self.menu = Menu.Create("Miscellaneous", "In Game", "Auto High Five")
	self.menu:Icon("\u{e1a7}")

	self.menu_main = self.menu:Create("Main")

	self.menu_script = self.menu_main:Create("General")

	self.enable = self.menu_script:Switch("Enable", false, "\u{f00c}")

	self.high_five_tick = nil
end

function AutoHighFive:OnUpdate()
	if not self.enable:Get() then
		return
	end

	local tick = XHelpers.UpdateTick()

	if tick % 5 == 0 and (self.high_five_tick == nil or math.abs(tick - self.high_five_tick) > 15) then
		local local_hero = LIB_HEROES_DATA.my_hero.ref
		local selected_unit = LIB_HEROES_DATA.my_hero.selected_units[1]

		if local_hero == selected_unit then
			local origin = LIB_HEROES_DATA.my_hero.pos
			local local_team = LIB_HEROES_DATA.my_hero.team

			for _, hero in pairs(Heroes.InRadius(origin, self.radius, local_team, Enum.TeamType.TEAM_BOTH)) do
				if hero ~= local_hero then
					if LIB_HEROES_DATA.modifier[hero][self.modifier_name] ~= nil then
						local high_five = NPC.GetAbility(local_hero, "plus_high_five")

						if high_five ~= nil then
							Engine.RunScript("Game.PrepareUnitOrders({OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex: "..tostring(Entity.GetIndex(high_five))..", OrderIssuer: PlayerOrderIssuer_t.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, UnitIndex: "..tostring(Entity.GetIndex(local_hero))..", QueueBehavior: false, ShowEffects: false});");
						end

						self.high_five_tick = tick

						break
					end
				end
			end
		end
	end
end

return XHelpers.WrapCallbacks(AutoHighFive)