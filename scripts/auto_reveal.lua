require("libraries/__init__")

local AutoReveal = class("AutoReveal")

function AutoReveal:initialize()
	self.path = {"Magma", "General", "Items manager", "Auto Reveal"}

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.reveal_abilities = {
		{"item_dust", true},
		{"item_ward_sentry", false},
		{"item_gungir", false},
		{"item_seer_stone", false},
		{"zuus_lightning_bolt", false, true},
		-- {"meepo_earthbind", false, true}, -- NOTE: sometimes its impossible to predict position
		-- {"abyssal_underlord_pit_of_malice", false, true}, -- NOTE: too low duration
	}

	self.reveal_abilities_select = UILib:CreateMultiselect(self.path, "Reveal abilities", table.map(self.reveal_abilities, function(_, info) return {info[1], CAbility:GetAbilityNameIconPath(info[1]), info[2]} end))

	self.linken_breaker = LinkenBreaker:CreateUI(self.path, nil, true)
	self.spell_reflect = SpellReflect:CreateUI(self.path)

	self.allies_select = UILib:CreateMultiselectFromAlliesOnly(self.path, "Allies", false, false, true)
	self.allies_select:SetIcon("~/MenuIcons/add_user.png")
	self.allies_select:SetTip("Ally must give shared control access")

	self.conditions_invis, self.conditions_channeling = table.unpack(Conditions:CreateUI({self.path, "Settings"}, true, true))

	self.additional_usage = UILib:CreateAdditionalControllableUnits({self.path, "Settings"}, "Use on", false, true, false)

	self.anti_overwatch_camera = table.unpack(AntiOverwatch:CreateUI({self.path, "Settings"}, 1))

	self.auto_reveal_notifications = UILib:CreateCheckbox({self.path, "Settings", "Notification"}, "Text", true)
	self.auto_reveal_notifications:SetIcon("~/MenuIcons/Notifications/inotification_def.png")

	UILib:SetTabIcon({self.path, "Settings", "Notification"}, "~/MenuIcons/Notifications/alarm.png")

	UILib:SetTabIcon({self.path, "Settings"}, "~/MenuIcons/utils_wheel.png")

	UILib:SetTabIcon(self.path, "~/MenuIcons/Dota/eye_sentry.png")

	self.listeners = {}

	self.revealed_enemies = {}
	self.triggered_enemies = {}
end

function AutoReveal:OnUpdate()
	if not self.enable:Get() then return end
	local tick = self:GetTick()
	if tick % 2 == 0 then
		for _, enemy in pairs(CHero:GetEnemies()) do
			if self:CanEnemyBeRevealed(enemy) and not enemy:HasModifier("modifier_nyx_assassin_vendetta") then
				local entindex = enemy:GetIndex()
				if self.revealed_enemies[entindex] == nil and self.triggered_enemies[entindex] == nil then
					self:Trigger(enemy)
				end
			else
				self.triggered_enemies[enemy:GetIndex()] = nil
			end
		end
	end
end

function AutoReveal:OnParticle(particle)
	if particle["shortname"] == "nyx_assassin_vendetta_start" then
		if particle["control_points"][0] ~= nil then
			for _, enemy in pairs(CHero:GetEnemies()) do
				local ability = enemy:GetAbilityOrItemByName("nyx_assassin_vendetta")
				if ability ~= nil then
					if self:CanEnemyBeRevealed(enemy) then
						self:Trigger(enemy, particle["control_points"][0][1]["position"])
					end
					break
				end
			end
		end
	end
end

---@param enemy CNPC
---@return boolean
function AutoReveal:CanEnemyBeRevealed(enemy)
	return not enemy:IsTrueSight() and enemy:GetInvisibilityTime() > 0 and not enemy:IsTrueSightImmune()
end

---@param enemy CNPC
---@param enemy_pos Vector?
---@return boolean
function AutoReveal:Trigger(enemy, enemy_pos)
	if not self.enable:Get() then return false end
	self.triggered_enemies[enemy:GetIndex()] = true
	enemy_pos = enemy_pos or enemy:GetAbsOrigin()
	local search_range = 2500
	local local_player = CPlayer:GetLocal()
	local abilities = table.combine(table.map(self.reveal_abilities_select:Get(), function(_, ability_name)
		return {ability_name, nil, self:IsPiercesBKBOverride(ability_name)}
	end), {{"item_ward_dispenser", nil, true}})
	local abilities_filter = self:UsableAbilitiesFilter(enemy)
	for _, unit in pairs(CNPC:GetControllableUnits(enemy_pos, search_range, true)) do
		if unit:RecursiveGetOwner() == local_player or self.allies_select:IsSelected(unit:GetUnitName()) and unit:IsAlive() then
			if (self.additional_usage:IsSelected("spirit_bear") or not unit:IsSpiritBear()) and (self.additional_usage:IsSelected("tempest_double") or not unit:IsTempestDouble()) then
				if AntiOverwatch:CanUseAtCamera(unit, enemy_pos, self.anti_overwatch_camera) then
					if Conditions:CanUse(unit, self.conditions_invis, self.conditions_channeling) then
						local reveal_ability = unit:GetUsableAbilities(abilities, enemy, self.linken_breaker, self.spell_reflect, abilities_filter)[1]
						if reveal_ability ~= nil then
							if self:Reveal(enemy, enemy_pos, reveal_ability) then
								return true
							end
						end
					end
				end
			end
		end
	end
end

---@param enemy CNPC
---@param enemy_pos Vector
---@param ability CAbility | CItem
function AutoReveal:Reveal(enemy, enemy_pos, ability)
	self.revealed_enemies[enemy:GetIndex()] = true
	return ability:CastAndCheck(enemy, false, false, true, self.spell_reflect, self.linken_breaker, function(isLinkenFree)
		self.revealed_enemies[enemy:GetIndex()] = nil
		if not isLinkenFree then
			return
		end
		if ability:GetName() == "item_ward_dispenser" then
			if ability:GetToggleState() then
				ability:Toggle()
			end
		end
		if ability:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_POINT) then
			local aoe_radius = ability:GetAOERadius()
			if aoe_radius > 0 then
				local position = enemy_pos
				local cast_range = ability:GetCastRange()
				local casterpos = ability:GetCaster():GetAbsOrigin()
				local distance = (position-casterpos):Length2D()
				if cast_range < distance and (cast_range+(aoe_radius/1.5)) >= distance then
					local direction = (position-casterpos):Normalized()
					direction.z = 0
					position = CWorld:GetGroundPosition(casterpos + direction * (cast_range-(ability:GetCaster():GetHullRadius()*2)))
					enemy_pos = position
				end
			end
			ability:Cast(enemy_pos)
		else
			ability:Cast(enemy)
		end
		self:SendNotification(ability, enemy, invis_ability ~= nil and invis_ability:GetName() or nil)
		Timers:CreateTimer(ability:GetCastPoint() + ability:GetCaster():GetTimeToFacePosition(enemy_pos) + CNetChannel:GetPingDelay() + 3, function()
			self.revealed_enemies[enemy:GetIndex()] = nil
		end, self)
	end, true)
end

---@param reveal_ability CAbility | CItem
---@param enemy CNPC
---@param invis_ability CAbility?
---@return nil
function AutoReveal:SendNotification(reveal_ability, enemy, invis_ability)
	if self.auto_reveal_notifications:Get() then
		local enemy_image = CRenderer:GetOrLoadImage(GetHeroIconPath(enemy:GetUnitName()))
		local invis_image = invis_ability ~= nil and CRenderer:GetOrLoadImage(CAbility:GetAbilityNameIconPath(invis_ability)) or CRenderer:GetOrLoadImage("~/MenuIcons/eye_dashed.png")
		local caster_image = CRenderer:GetOrLoadImage(GetHeroIconPath(reveal_ability:GetCaster():GetUnitName()))
		local reveal_image = CRenderer:GetOrLoadImage(CAbility:GetAbilityNameIconPath(reveal_ability:GetName()))
		CRenderer:DrawCenteredNotification("{#FF0000}[{&"..enemy_image.."}{#FF0000}]{&"..invis_image.."}{#FFFFFF} reveal by {#00FF00}[{&"..caster_image.."}{#00FF00}]{&"..reveal_image.."}", 2)
	end
end

---@param ability_name string
---@return boolean?
function AutoReveal:IsPiercesBKBOverride(ability_name)
	for _, info in pairs(self.reveal_abilities) do
		if info[1] == ability_name then
			if info[3] ~= nil then
				return info[3]
			end
		end
	end
	return nil
end

---@param target CNPC
---@return function
function AutoReveal:UsableAbilitiesFilter(target)
	---@param ability CAbility
	---@return boolean | number | nil
	return function(ability)
		if ability:GetName() == "item_ward_dispenser" then
			return self.reveal_abilities_select:IsSelected("item_ward_sentry")
		end
	end
end

return BaseScriptAPI(AutoReveal)