require("libraries/__init__")

local AutoDisablerExtended = class("AutoDisablerExtended")

function AutoDisablerExtended:initialize()
	self.path = {"Magma", "General", "Auto Disabler"}

	self.disable_abilities = {
		{"item_orchid", true, true},
		{"item_bloodthorn", true, true},
		{"item_sheepstick", true, true},
		{"item_cyclone", true, true},
		{"item_abyssal_blade", true, true},
		{"item_book_of_shadows", false, true},
		{"item_wind_waker", false, true},
		{"item_heavens_halberd", false, true},
		{"item_hurricane_pike", false, true},
		{"item_psychic_headband", false, true},
		{"item_rod_of_atos", false, true},
		{"item_gungir", false, false},
		{"lion_voodoo", true, true},
		{"shadow_shaman_voodoo", true, true},
		{"rubick_telekinesis", true, true},
		{"skywrath_mage_ancient_seal", true, true},
		{"dragon_knight_dragon_tail", true, true},
		{"invoker_cold_snap", true, true},
		{"invoker_tornado", true, false},
		{"obsidian_destroyer_astral_imprisonment", true, true},
		{"grimstroke_ink_creature", true, true},
		{"lich_sinister_gaze", true, true},
		{"bane_nightmare", false, true},
		{"disruptor_glimpse", true, true},
		{"shadow_demon_disruption", true, true},
		{"lone_druid_savage_roar", false, false},
	}

	self.trigger_abilities = {
		{"item_blink", true, false},
		{"axe_berserkers_call", true, true},
		{"tidehunter_ravage", true, true},
		{"enigma_black_hole", true, true},
		{"magnataur_reverse_polarity", true, true},
		{"legion_commander_duel", true, true},
		{"beastmaster_primal_roar", true, true},
		{"treant_overgrowth", true, true},
		{"faceless_void_chronosphere", true, true},
		{"batrider_flaming_lasso", true, true},
		{"doom_bringer_doom", true, true},
		{"juggernaut_omni_slash", true, true},
		{"bane_fiends_grip", true, true},
		{"nevermore_requiem", false, true},
		{"antimage_blink", false, nil},
		{"queenofpain_blink", true, nil},
		{"faceless_void_time_walk", true, nil},
		{"magnataur_skewer", true, true},
		{"phantom_assassin_phantom_strike", true, nil},
		{"riki_tricks_of_the_trade", true, true},
		{"void_spirit_astral_step", true, nil},
		{"storm_spirit_ball_lightning", true, true},
		{"void_spirit_dissimilate", true, true},
		{"weaver_time_lapse", true, true},
		{"life_stealer_infest", true, true},
		{"pangolier_gyroshell", true, true},
		{"naga_siren_song_of_the_siren", true, true},
		{"terrorblade_sunder", true, true},
		{"undying_tombstone", true, true},
		{"vengefulspirit_nether_swap", true, true},
		{"primal_beast_pulverize", false, nil},
		{"pudge_dismember", false, nil},
		{"winter_wyvern_winters_curse", true, true},
		{"centaur_hoof_stomp", false, nil},
		{"slardar_slithereen_crush", false, true},
	}

	self.anti_overwatch_delay_visible = 0.15
	self.anti_overwatch_delay_fow = 0.3

	self.auto_disabler_enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.auto_disabler_disable_abilities_order = UILib:CreateMultiselect(self.path, "Your abilities", table.map(self.disable_abilities, function(_, info) return {info[1], CAbility:GetAbilityNameIconPath(info[1]), info[2]} end), false)

	self.auto_disabler_legit_faker_key = UILib:CreateKeybind(self.path, "Legit imitation")
	self.auto_disabler_legit_faker_key:SetIcon("~/MenuIcons/left_click.png")
	self.auto_disabler_legit_faker_key:SetTip("Cursor will randomly move around your hero to create fake visibility of spamming disable ability\nFunction has \"safe check\" to prevent imitating if your cursor is too far from hero\n[WARNING] May increase delay before disable due to order spam\n[WARNING] Highly not recommended to execute other orders while legit imitation, it might be non-legit for Overwatch!")

	self.auto_disabler_aggressive_key = UILib:CreateKeybind({self.path, "Aggressive Disabler"}, "Key")
	self.auto_disabler_aggressive_key:SetTip("[Rage mode]\n- Disables selected enemies (in abilities options) within disable ability range\n- Ignores any randomization\n- Warning! This option ignores Anti-Overwatch\n[OVERWATCH RISK]")
	self.auto_disabler_aggressive_always = UILib:CreateCheckbox({self.path, "Aggressive Disabler"}, "Always on", false)
	self.auto_disabler_aggressive_always:SetIcon("~/MenuIcons/Enable/enable_ios.png")
	self.auto_disabler_aggressive_always:SetTip("Enables aggressive disabler without holding key\nHighly not recommended to use this option!\n[OVERWATCH RISK]")
	self.auto_disabler_aggressive_disable_abilities_order = UILib:CreateMultiselect({self.path, "Aggressive Disabler"}, "Your abilities", table.map(self.disable_abilities, function(_, info) return {info[1], CAbility:GetAbilityNameIconPath(info[1]), info[2]} end), false)
	self.auto_disabler_aggressive_enemies = UILib:CreateMultiselectFromEnemies({self.path, "Aggressive Disabler"}, "Aggressive enemies", false, false, true)
	UILib:SetTabIcon({self.path, "Aggressive Disabler"}, "~/MenuIcons/enemy_evil.png")

	local function CreateDisableAbilitySettings(whereAt, name, triggers_linken, icon)
		if name ~= "global" then
			self.auto_disabler_disable_abilities[name.."_use_global"] = UILib:CreateCheckbox(whereAt, "Ignore global settings", false)
		end

		self.auto_disabler_disable_abilities[name.."_trigger"] = UILib:CreateMultiselect(whereAt, "Enemy's abilities", table.map(self.trigger_abilities, function(_, info) return {info[1], CAbility:GetAbilityNameIconPath(info[1]), info[2]} end), false)
		self.auto_disabler_disable_abilities[name.."_trigger_enemies"] = {}
		for _, enemy_ability in pairs(self.trigger_abilities) do
			if string.startswith(enemy_ability[1], "item_") then
				self.auto_disabler_disable_abilities[name.."_trigger_enemies"][enemy_ability[1]] = UILib:CreateMultiselectFromEnemies(whereAt, LocaleLib:LocalizeAbilityName(enemy_ability[1]).." Enemies", false, true, true)
				self.auto_disabler_disable_abilities[name.."_trigger_enemies"][enemy_ability[1]]:SetIcon(CAbility:GetAbilityNameIconPath(enemy_ability[1]))
			end
		end

		if triggers_linken then
			self.auto_disabler_disable_abilities[name.."_linken_breaker"] = LinkenBreaker:CreateUI(whereAt, nil, true, name)
			self.auto_disabler_disable_abilities[name.."_spell_reflect"] = SpellReflect:CreateUI(whereAt)
		end
		self.auto_disabler_disable_abilities[name.."_range_buffer"] = UILib:CreateSlider(whereAt, "Range buffer", 0, 125, 50)
		self.auto_disabler_disable_abilities[name.."_range_buffer"]:SetIcon("~/MenuIcons/radius.png")
		self.auto_disabler_disable_abilities[name.."_instant_mode"] = UILib:CreateCheckbox(whereAt, "Instant mode", false)
		self.auto_disabler_disable_abilities[name.."_instant_mode"]:SetIcon("~/MenuIcons/red_square.png")
		self.auto_disabler_disable_abilities[name.."_instant_mode"]:SetTip("[Rage mode]\n- Ignores any delays for this ability\n- Warning! This option ignores Anti-Overwatch\n[OVERWATCH RISK]")
		self.auto_disabler_disable_abilities[name.."_allies"] = UILib:CreateMultiselectFromAlliesOnly(whereAt, "Allies", false, false, true)
		self.auto_disabler_disable_abilities[name.."_allies"]:SetIcon("~/MenuIcons/add_user.png")
		self.auto_disabler_disable_abilities[name.."_allies"]:SetTip("Ally must give shared control access")

		UILib:SetTabIcon(whereAt, icon)
	end

	self.auto_disabler_disable_abilities = {}

	CreateDisableAbilitySettings({self.path, "Settings", "Abilities", "Global"}, "global", true, "~/MenuIcons/globe_world.png")

	for _, disable_ability in pairs(self.disable_abilities) do
		CreateDisableAbilitySettings({self.path, "Settings", "Abilities", LocaleLib:LocalizeAbilityName(disable_ability[1], "true")}, disable_ability[1], disable_ability[3], CAbility:GetAbilityNameIconPath(disable_ability[1]))
	end

	UILib:SetTabIcon({self.path, "Settings", "Abilities"}, "~/MenuIcons/Dota/spell_book.png")

	self.conditions_invis, self.conditions_channeling = table.unpack(Conditions:CreateUI({self.path, "Settings"}, true, true))

	self.auto_disabler_trigger_chance = UILib:CreateSlider({self.path, "Settings", "Randomization"}, "Trigger chance", 1, 100, 100)
	self.auto_disabler_trigger_chance:SetIcon("~/MenuIcons/counter_simple.png")
	self.auto_disabler_min_delay = UILib:CreateSlider({self.path, "Settings", "Randomization"}, "Minimal delay", 0, 0.5, 0)
	self.auto_disabler_min_delay:SetIcon("~/MenuIcons/Time/timer_def.png")
	self.auto_disabler_max_delay = UILib:CreateSlider({self.path, "Settings", "Randomization"}, "Maximum delay", 0, 0.5, 0)
	self.auto_disabler_max_delay:SetIcon("~/MenuIcons/Time/timer_def.png")
	self.auto_disabler_delay_less_than_cast = UILib:CreateCheckbox({self.path, "Settings", "Randomization"}, "Always delay < castpoint", true)
	self.auto_disabler_delay_less_than_cast:SetIcon("~/MenuIcons/Time/sand_time.png")
	self.auto_disabler_delay_less_than_cast:SetTip("Ignore delay if enemy ability's cast point is less than delay + your abiltiy cast point\nWarning! This option ignores Anti-Overwatch!\n[OVERWATCH RISK]")
	self.auto_disabler_instant_enemies = UILib:CreateMultiselectFromEnemies({self.path, "Settings", "Randomization"}, "Instant enemies", false, false, true)
	self.auto_disabler_instant_enemies:SetIcon("~/MenuIcons/Time/time_meet.png")
	self.auto_disabler_instant_enemies:SetTip("[Rage mode]\n- Selected enemies will be disabled instantly ignoring any delays\n- Warning! This option ignores Anti-Overwatch\n[OVERWATCH RISK]")
	self.auto_disabler_legit_faker_cooldown = UILib:CreateSlider({self.path, "Settings", "Randomization"}, "Legit imitation cooldown", 0, 3, 2.2)
	self.auto_disabler_legit_faker_cooldown:SetIcon("~/MenuIcons/Time/time_span.png")
	self.auto_disabler_legit_faker_cooldown:SetTip("Delay for legit imitation after disabling enemy")
	self.auto_disabler_legit_faker_linger = UILib:CreateSlider({self.path, "Settings", "Randomization"}, "Legit imitation linger", 0, 1, 0.5)
	self.auto_disabler_legit_faker_linger:SetIcon("~/MenuIcons/Time/time_span.png")
	self.auto_disabler_legit_faker_linger:SetTip("Legit imitation duration before cooldown after disabling enemy")
	UILib:SetTabIcon({self.path, "Settings", "Randomization"}, "~/MenuIcons/ichange_v1.png")

	self.additional_usage = UILib:CreateAdditionalControllableUnits({self.path, "Settings"}, "Use on", false, true, false)

	self.anti_overwatch_camera = table.unpack(AntiOverwatch:CreateUI({self.path, "Settings"}, 1))

	self.anti_overwatch_delay = UILib:CreateCheckbox({self.path, "Settings", "Anti-Overwatch"}, "Delay", true)
	self.anti_overwatch_delay:SetIcon("~/MenuIcons/Time/time_span.png")
	self.anti_overwatch_delay:SetTip("[Legit mode]\n- "..tostring(self.anti_overwatch_delay_visible).."s delay if enemy triggered NOT from Fog of War\n- "..tostring(self.anti_overwatch_delay_fow).."s delay if enemy triggered from Fog of War\n- Disabling this might trigger Auto-Overwatch algorithm\n[OVERWATCH RISK]")

	self.auto_disabler_notifications = UILib:CreateCheckbox({self.path, "Settings", "Notification"}, "Text", true)
	self.auto_disabler_notifications:SetIcon("~/MenuIcons/Notifications/inotification_def.png")

	UILib:SetTabIcon({self.path, "Settings", "Notification"}, "~/MenuIcons/Notifications/alarm.png")

	UILib:SetTabIcon({self.path, "Settings"}, "~/MenuIcons/utils_wheel.png")

	UILib:SetTabIcon(self.path, "~/MenuIcons/silent.png")

	self.disabling = 0
	self.faker_position = Vector(0, 0, 0)
	self.current_faker_position = Vector(0, 0, 0)
	self.faker_max_range = 0

	self.listeners = {}

	if self.auto_disabler_enable:Get() then
		self.listeners["AbilityUsageHeroEnemy"] = true
		self.listeners["HeroVisibilityEnemy"] = true
	end
end

function AutoDisablerExtended:OnMenuOptionChange(option, oldValue, newValue)
	if option == self.auto_disabler_enable.menu_option then
		if self.auto_disabler_enable:Get() then
			self.listeners["AbilityUsageHeroEnemy"] = true
			self.listeners["HeroVisibilityEnemy"] = true
		else
			self.listeners["AbilityUsageHeroEnemy"] = nil
			self.listeners["HeroVisibilityEnemy"] = nil
		end
	elseif option == self.auto_disabler_min_delay.menu_option or option == self.auto_disabler_max_delay.menu_option then
		if self.auto_disabler_min_delay:Get() > self.auto_disabler_max_delay:Get() then
			self.auto_disabler_min_delay:Set(self.auto_disabler_max_delay:Get())
		end
	end
end

function AutoDisablerExtended:OnUpdate()
	if not self.auto_disabler_enable:Get() then return end
	local tick = self:GetTick()
	if tick % 5 == 0 then
		if self.auto_disabler_aggressive_key:IsActive() or self.auto_disabler_aggressive_always:Get() then
			if self.disabling ~= true then
				for _, hero in pairs(CHero:GetEnemies()) do
					if self.auto_disabler_aggressive_enemies:IsSelected(hero:GetUnitName()) and hero:IsVisible() then
						self:Trigger(nil, nil, hero)
					end
				end
			end
		end
	end
	if tick % 5 == 0 then
		local usable_abilities = table.filter(self:GetAnyLocalUsableAbilities(), function(_, ability) return ability:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) end)
		table.sort(usable_abilities, function(a, b)
			return a:GetCastRange() > b:GetCastRange()
		end)
		local hero_pos = CHero:GetLocal():GetAbsOrigin()
		local cursor_pos = CInput:GetWorldCursorPos()
		if (hero_pos - cursor_pos):Length2D() > 1000 then
			self.faker_max_range = -1
		else
			self.faker_max_range = usable_abilities[1] ~= nil and usable_abilities[1]:GetCastRange() or -1
		end
	end
	if self.auto_disabler_legit_faker_key:IsActive() then
		if self.faker_max_range ~= -1 then
			local queue = CHumanizer:GetOrderQueue() or {}
			if #queue < 3 and type(self.disabling) == "number" and (os.time() - self.disabling > self.auto_disabler_legit_faker_cooldown:Get() or os.time() - self.disabling < self.auto_disabler_legit_faker_linger:Get()) then
				self.current_faker_position = self.faker_position
				CHumanizer:MoveCursorTo(self.faker_position)
			end
			if tick % 4 == 0 then
				local pos = CHero:GetLocal():GetAbsOrigin()
				local max_distance = math.min(475, math.max(self.faker_max_range, 150))
				if self.faker_position == Vector(0, 0, 0) then
					self.faker_position = pos
				end
				local distance = (pos - self.faker_position):Length2D()
				if max_distance - distance < 200 or RollPercentage(35) then
					self.faker_position = pos + vector.random_vector(max_distance > 300 and math.random(125, 225) or math.random(50, math.max(50, math.floor(max_distance / 2))))
					distance = 0
				end
				self.faker_position = self.faker_position + vector.random_vector(math.random(75, math.min(90, math.max(125, math.floor((max_distance - distance) / 2)))))
			end
		end
	end
end

function AutoDisablerExtended:GetHeroTexts()
	local texts = {}
	if self.auto_disabler_legit_faker_key:IsActive() and self.faker_max_range ~= -1 then
		if type(self.disabling) == "number" and (os.time() - self.disabling > self.auto_disabler_legit_faker_cooldown:Get() or os.time() - self.disabling < self.auto_disabler_legit_faker_linger:Get()) then
			table.insert(texts, {"[Auto Disabler Imitation]"})
		end
	end
	if self.auto_disabler_aggressive_key:IsActive() then
		table.insert(texts, {"[Aggressive Auto Disabler]"})
	end
	return texts
end

function AutoDisablerExtended:OnDraw()
	if self.auto_disabler_legit_faker_key:IsActive() and self.faker_max_range ~= -1 then
		if type(self.disabling) == "number" and (os.time() - self.disabling > self.auto_disabler_legit_faker_cooldown:Get() or os.time() - self.disabling < self.auto_disabler_legit_faker_linger:Get()) then
			local fake_x, fake_y, fake_visible = CRenderer:WorldToScreen(self.current_faker_position)
			if fake_visible then
				CRenderer:SetDrawColor(5, 245, 245, 255)
				CRenderer:DrawOutlineCircle(fake_x-4, fake_y-4, 8, 16)
			end
		end
	end
end

function AutoDisablerExtended:OnNPCUsedAbility(ability)
	local caster = ability:GetCaster()
	local ability_name = ability:GetName(true)
	for _, ability_info in pairs(self.trigger_abilities) do
		if ability_info[1] == ability_name then
			if ability_info[3] == true then
				break
			end
			self:Trigger(ability, false, caster)
			break
		end
	end
end

function AutoDisablerExtended:OnNPCPhaseAbility(ability)
	local caster = ability:GetCaster()
	local ability_name = ability:GetName(true)
	for _, ability_info in pairs(self.trigger_abilities) do
		if ability_info[1] == ability_name then
			if ability_info[3] == false then
				break
			end
			self:Trigger(ability, true, caster)
			break
		end
	end
end

function AutoDisablerExtended:Trigger(ability, phase, caster)
	if not self.auto_disabler_enable:Get() then return false end
	local delay = 0
	if ability ~= nil then
		if not RollPercentage(self.auto_disabler_trigger_chance:Get()) then return false end
		delay = math.random_float(math.min(self.auto_disabler_min_delay:Get(), self.auto_disabler_max_delay:Get()), self.auto_disabler_max_delay:Get())
		if self.anti_overwatch_delay:Get() then
			delay = delay + (self:WasHeroVisible(caster) and self.anti_overwatch_delay_visible or self.anti_overwatch_delay_fow)
		end
		if phase and self.auto_disabler_delay_less_than_cast:Get() then
			delay = math.max(math.min(delay, ability:GetCastPoint()-CNetChannel:GetPingDelay()*2-0.175), 0)
		end
		if self.auto_disabler_instant_enemies:IsSelected(caster:GetUnitName()) then
			delay = 0
		end
	end
	if caster:IsDisabled() then return false end
	local caster_pos = caster:GetAbsOrigin()
	local local_hero = CHero:GetLocal()
	local search_range = 2500
	local enemy_is_bkb = caster:IsDebuffImmune()
	for _, unit in pairs(CNPC:GetControllableUnits(caster_pos, search_range, true)) do
		if (self.additional_usage:IsSelected("spirit_bear") or not unit:IsSpiritBear()) and (self.additional_usage:IsSelected("tempest_double") or not unit:IsTempestDouble()) then
			if AntiOverwatch:CanUseAtCamera(unit, caster_pos, self.anti_overwatch_camera) then
				if Conditions:CanUse(unit, self.conditions_invis, self.conditions_channeling) then
					local disable_ability = self:GetUsableAbilities(unit, ability, caster)[1]
					if disable_ability ~= nil then
						local ability_info = self:GetAbilityInfo(disable_ability:GetName())
						if ability_info["instant_mode"]:Get() then
							delay = 0
						end
						if delay <= 0 then
							if self:DisableEnemy(disable_ability, caster, ability) then
								return true
							end
						else
							Timers:CreateTimer(delay, function()
								self:DisableEnemy(disable_ability, caster, ability)
							end, self)
						end
					end
				end
			end
		end
	end
end

function AutoDisablerExtended:DisableEnemy(ability, enemy, enemy_ability, ignore_spell_reflect)
	local hero = ability:GetCaster()
	local ability_name = ability:GetName()
	local ability_info = self:GetAbilityInfo(ability_name)
	local old_disabling = self.disabling
	self.disabling = true
	if not ignore_spell_reflect and ability_info["spell_reflect"] ~= nil then
		local used_save = SpellReflect:UseSaveIfNeed(ability, enemy, table.unpack(ability_info["spell_reflect"]))
		if used_save == false then
			return false
		else
			if type(used_save) ~= "boolean" then
				Timers:CreateTimer(used_save[2] + 0.05 + (used_save[2] > 0 and CNetChannel:GetPingDelay() or 0), function()
					hero:Stop()
					self:DisableEnemy(ability, enemy, enemy_ability, true)
				end, self)
				return true
			end
		end
	end
	if hero:IsChannellingAbility() then
		hero:Stop()
	end
	local this = self
	local function callback(isLinkenFree)
		if not isLinkenFree then
			this.disabling = old_disabling
			return
		end
		ability:Cast(enemy)
		this:SendNotification(ability, enemy_ability, enemy)
		this.disabling = os.time()
	end
	if ability_info["linken_breaker"] ~= nil then
		LinkenBreaker:BreakLinken(hero, enemy, ability_info["linken_breaker"], nil, ability_name, callback)
	else
		callback(true)
	end
	return true
end

function AutoDisablerExtended:SendNotification(disable_ability, trigger_ability, enemy)
	if self.auto_disabler_notifications:Get() then
		local enemy_image = CRenderer:GetOrLoadImage(GetHeroIconPath(enemy:GetUnitName()))
		local trigger_image = trigger_ability ~= nil and CRenderer:GetOrLoadImage(CAbility:GetAbilityNameIconPath(trigger_ability:GetName())) or CRenderer:GetOrLoadImage("~/MenuIcons/enemy_evil.png")
		local caster_image = CRenderer:GetOrLoadImage(GetHeroIconPath(disable_ability:GetCaster():GetUnitName()))
		local disable_image = CRenderer:GetOrLoadImage(CAbility:GetAbilityNameIconPath(disable_ability:GetName()))
		CRenderer:DrawCenteredNotification("{#FF0000}[{&"..enemy_image.."}{#FF0000}]{&"..trigger_image.."}{#FFFFFF} disable by {#00FF00}[{&"..caster_image.."}{#00FF00}]{&"..disable_image.."}", 2)
	end
end

function AutoDisablerExtended:GetAbilityInfo(ability_name)
	if self.auto_disabler_disable_abilities[ability_name.."_use_global"] == nil then
		return
	end
	if not self.auto_disabler_disable_abilities[ability_name.."_use_global"]:Get() then
		ability_name = "global"
	end
	return {
		enemy_abilities=self.auto_disabler_disable_abilities[ability_name.."_trigger"],
		enemies=self.auto_disabler_disable_abilities[ability_name.."_trigger_enemies"],
		linken_breaker=self.auto_disabler_disable_abilities[ability_name.."_linken_breaker"],
		spell_reflect=self.auto_disabler_disable_abilities[ability_name.."_spell_reflect"],
		range_buffer=self.auto_disabler_disable_abilities[ability_name.."_range_buffer"],
		instant_mode=self.auto_disabler_disable_abilities[ability_name.."_instant_mode"],
		allies=self.auto_disabler_disable_abilities[ability_name.."_allies"],
	}
end

function AutoDisablerExtended:IsAbilityTriggersLinken(ability_name)
	for _, ability_info in pairs(self.disable_abilities) do
		if ability_info[1] == ability_name then
			return ability_info[3]
		end
	end
	return true
end

function AutoDisablerExtended:GetUsableAbilities(hero, enemy_ability, enemy)
	local is_local_hero = CPlayer:GetLocal() == hero:RecursiveGetOwner()
	local distance = (enemy:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
	local hero_name = hero:GetUnitName()
	local enemy_name = enemy:GetUnitName()
	local is_enemy_bkb = enemy:IsDebuffImmune()
	local is_enemy_silenced = enemy:IsSilenced()
	local usable_abilities = {}
	for _, ability_name in pairs(enemy_ability ~= nil and self.auto_disabler_disable_abilities_order:Get() or self.auto_disabler_aggressive_disable_abilities_order:Get()) do
		local ability_info = self:GetAbilityInfo(ability_name)
		if enemy_ability == nil or (ability_info["enemy_abilities"]:IsSelected(enemy_ability:GetName(true)) and (ability_info["enemies"][ability_name] == nil or ability_info["enemies"][ability_name]:IsSelected(enemy_name))) then
			if is_local_hero or ability_info["allies"]:IsSelected(hero_name) then
				local ability = hero:GetAbilityOrItemByName(ability_name)
				if ability ~= nil and ability:CanCast() and (not is_enemy_bkb or ability:PiercesBKB()) then
					if not ability:IsSilence() or not is_enemy_silenced then
						local is_triggers_linken = self:IsAbilityTriggersLinken(ability_name)
						if not is_triggers_linken or not enemy:IsAbsorbsSpells() then
							local cast_range = ability:GetCastRange()
							local range_buffer = ability_info["range_buffer"]:Get()
							if cast_range == 0 then
								cast_range = ability:GetRadius() - range_buffer
							end
							if cast_range + range_buffer >= distance then
								if not is_triggers_linken or ability_info["linken_breaker"] == nil or LinkenBreaker:CanUseAbility(hero, enemy, ability_info["linken_breaker"], nil, ability_name) then
									if not is_triggers_linken or ability_info["spell_reflect"] == nil or SpellReflect:CanUse(ability, enemy, ability_info["spell_reflect"][1], ability_info["spell_reflect"][2]) then
										table.insert(usable_abilities, ability)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return usable_abilities
end

function AutoDisablerExtended:GetAnyLocalUsableAbilities()
	local hero = CHero:GetLocal()
	local usable_abilities = {}
	for _, ability_name in pairs(self.auto_disabler_disable_abilities_order:Get()) do
		local ability = hero:GetAbilityOrItemByName(ability_name)
		if ability ~= nil and ability:CanCast() then
			table.insert(usable_abilities, ability)
		end
	end
	return usable_abilities
end

return BaseScriptAPI(AutoDisablerExtended)