require("lib")

local AntiInitiationAlly = {}

local antiinitiation_ally_enable = Menu.AddOptionBool({"General", "Auto Disabler"}, "Enabled (for allies)", false)
Menu.AddOptionIcon(antiinitiation_ally_enable, "~/MenuIcons/Enable/enable_ios.png")

function AntiInitiationAlly.OnLoad()
	AntiInitiationAlly.enemy_abilities = {
		"axe_berserkers_call",
		"tidehunter_ravage",
		"enigma_black_hole",
		"magnataur_reverse_polarity",
		"legion_commander_duel",
		"beastmaster_primal_roar",
		"treant_overgrowth",
		"faceless_void_chronosphere",
		"batrider_flaming_lasso",
		"dark_seer_wall_of_replica",
		"slardar_slithereen_crush",
		"queenofpain_sonic_wave",
		"centaur_hoof_stomp",
		"sven_storm_bolt",
		"bane_fiends_grip",
		"pudge_dismember",
		"crystal_maiden_freezing_field"
	}
	AntiInitiationAlly.enemy_items = {
		"item_blink",
		"item_arcane_blink",
		"item_overwhelming_blink",
		"item_swift_blink",
	}
	AntiInitiationAlly.ally_abilities = {
		["lion_voodoo"] = false,
		["shadow_shaman_voodoo"] = false,
		["rubick_telekinesis"] = false,
		["skywrath_mage_ancient_seal"] = false,
	}
	AntiInitiationAlly.ally_items = {
		["item_orchid"] = false,
		["item_bloodthorn"] = false,
		["item_sheepstick"] = false,
		["item_cyclone"] = false,
		["item_wind_waker"] = false,
		["item_abyssal_blade"] = true,
	}
	AntiInitiationAlly.ignore_abilities = {}
	AntiInitiationAlly.OnGameStart()
end

function AntiInitiationAlly.OnGameStart()
	if GameRules.GetGameState() >= 4 then
		local localhero = Heroes.GetLocal()
		local allies = {}
		for _, hero in pairs(Heroes.GetAll()) do
			if hero ~= localhero and Entity.IsSameTeam(hero, localhero) then
				table.insert(allies, {tostring(Hero.GetPlayerID(hero)), "panorama/images/heroes/icons/"..NPC.GetUnitName(hero).."_png.vtex_c", false})
			end
		end
		AntiInitiationAlly.allies_selector = Menu.AddOptionMultiSelect({"General", "Auto Disabler"}, "Allies (with shared control)", allies, false)
		Menu.AddOptionIcon(AntiInitiationAlly.allies_selector, "~/MenuIcons/ellipsis.png")
	end
end

function AntiInitiationAlly.OnGameEnd()
	Menu.RemoveOption(AntiInitiationAlly.allies_selector)
end

function AntiInitiationAlly.OnUpdate()
	if Menu.IsEnabled(antiinitiation_ally_enable) then
		local localhero = Heroes.GetLocal()
		for _, hero in pairs(Heroes.GetAll()) do
			if not Entity.IsSameTeam(hero, localhero) then
				local skip = false
				for _, item_name in pairs(AntiInitiationAlly.enemy_items) do
					local item = NPC.GetItem(hero, item_name)
					if item ~= nil then
						local last_used = Ability.SecondsSinceLastUse(item)
						if last_used ~= -1 and last_used <= 1.5 then
							if not table.contains(AntiInitiationAlly.ignore_abilities, item) then
								if AntiInitiationAlly.TriggerEnemy(hero) then
									table.insert(AntiInitiationAlly.ignore_abilities, item)
								end
								skip = true
								break
							end
						elseif table.contains(AntiInitiationAlly.ignore_abilities, item) then
							table.removeElement(AntiInitiationAlly.ignore_abilities, item)
						end
					end
				end
				if not skip then
					for _, ability_name in pairs(AntiInitiationAlly.enemy_abilities) do
						local ability = NPC.GetAbility(hero, ability_name)
						if ability ~= nil and Ability.IsInAbilityPhase(ability) then
							if not table.contains(AntiInitiationAlly.ignore_abilities, ability) then
								if AntiInitiationAlly.TriggerEnemy(hero) then
									table.insert(AntiInitiationAlly.ignore_abilities, ability)
								end
								break
							end
						elseif table.contains(AntiInitiationAlly.ignore_abilities, ability) then
							table.removeElement(AntiInitiationAlly.ignore_abilities, ability)
						end
					end
				end
			end
		end
	end
end

function AntiInitiationAlly.TriggerEnemy(enemy)
	local enemypos = Entity.GetAbsOrigin(enemy)
	local localpid = Player.GetPlayerID(Players.GetLocal())
	for _, ally in pairs(Heroes.InRadius(enemypos, 900, Entity.GetTeamNum(Heroes.GetLocal()), Enum.TeamType.TEAM_FRIEND)) do
		if Menu.IsSelected(AntiInitiationAlly.allies_selector, tostring(Hero.GetPlayerID(ally))) and Entity.IsControllableByPlayer(ally, localpid) then
			for ability_name, pierce_bkb in pairs(AntiInitiationAlly.ally_abilities) do
				local ability = NPC.GetAbility(ally, ability_name)
				if ability ~= nil and Ability.GetCooldown(ability) <= 0 and (pierce_bkb or not IsDebuffImmune(enemy)) and NPC.IsPositionInRange(ally, enemypos, Ability.GetCastRange(ability) + 75) then
					Ability.CastTarget(ability, enemy, false, false)
					return true
				end
			end
			for item_name, pierce_bkb in pairs(AntiInitiationAlly.ally_items) do
				local ability = NPC.GetItem(ally, item_name)
				if ability ~= nil and Ability.GetCooldown(ability) <= 0 and (pierce_bkb or not IsDebuffImmune(enemy)) and NPC.IsPositionInRange(ally, enemypos, Ability.GetCastRange(ability) + 75) then
					Ability.CastTarget(ability, enemy, false, false)
					return true
				end
			end
		end
	end
	return false
end

AntiInitiationAlly:OnLoad()
return AntiInitiationAlly