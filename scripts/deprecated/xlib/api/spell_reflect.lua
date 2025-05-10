---@class SpellReflect
local SpellReflect = {
	usage_options = {
		"Don't use",
		"Ignore",
		"Safe",
		"Safest",
	},
	absorb_abilities = {
		"antimage_counterspell",
	},
}

---@param parent CMenuGroup | CMenuGearAttachment
---@param gear? boolean
---@param return_parent? boolean
---@return table
function SpellReflect:CreateUI(parent, gear, return_parent)
	local modules = {}
	local spell_reflect = parent
	local returned_parent = spell_reflect
	if gear then
		local label = parent:Label("Spell Reflect")
		label:Icon("\u{f13a}")
		spell_reflect = label:Gear("Settings")
		returned_parent = label
	end
	local usage_option = parent:Combo("Mode", self.usage_options, 2)
	usage_option:ToolTip("[Don't use] - don't use abilities\n[Ignore] - use always\n[Safe] - use only if caster absorbs spells or is bkb protected from ability\n[Safest] - use only if caster is bkb protected from ability")
	table.insert(modules, usage_option)
	local absorb_usage_option = parent:MultiSelect("Auto spell absorb for safe use", table.map(self.absorb_abilities, function(ability) return {ability, Ability.GetAbilityNameIconPath(ability), false} end), false)
	absorb_usage_option:ToolTip("Has higher priority than Auto BKB usage\nOnly works on Safe, turn all off to disable auto spell absorb usage")
	table.insert(modules, absorb_usage_option)
	local bkb_usage_option = parent:MultiSelect("Auto BKB for safe use", table.values(table.map(Ability.GetBKBs(true), function(_, bkb) return {bkb, Ability.GetAbilityNameIconPath(bkb), false} end)), false)
	bkb_usage_option:ToolTip("Only works on Safe and Safest modes, turn all off to disable auto bkb usage")
	table.insert(modules, bkb_usage_option)
	if return_parent then
		table.insert(modules, returned_parent)
	end
	return modules
end

---@param ability userdata
---@param enemy userdata
---@param option CMenuComboBox
---@param absorb_option? CMenuMultiSelect
---@param bkb_option? CMenuMultiSelect
---@return boolean
function SpellReflect:CanUse(ability, enemy, option, absorb_option, bkb_option)
	if not Ability.IsTriggersReflect(ability) then
		return true
	end
	if not Entity.IsNPC(enemy) then
		return true
	end
	local behavior = option:Get()
	local caster = Ability.GetOwner(ability)
	if behavior == 0 then
		return not NPC.IsReflectsSpells(enemy)
	elseif behavior == 1 then
		return true
	elseif behavior == 2 then
		if not NPC.IsReflectsSpells(enemy) then
			return true
		end
		if NPC.GetLinkenProtects(caster) > NPC.GetLinkenProtects(enemy) or NPC.IsAbsorbsSpells(caster) then
			return true
		end
		if NPC.IsDebuffImmune(caster) and not Ability.PiercesBKB(ability) then
			return true
		end
		if absorb_option ~= nil and #self:GetUsableAbsorbs(ability, enemy, absorb_option) > 0 then
			return true
		end
		if bkb_option ~= nil and #self:GetUsableBKBs(ability, enemy, bkb_option) > 0 then
			return true
		end
		return false
	elseif behavior == 3 then
		if not NPC.IsReflectsSpells(enemy) then
			return true
		end
		if NPC.IsAbsorbsSpells(caster)then
			return true
		end
		if NPC.IsDebuffImmune(caster) and not Ability.PiercesBKB(ability) then
			return true
		end
		if bkb_option ~= nil and #self:GetUsableBKBs(ability, enemy, bkb_option) > 0 then
			return true
		end
	end
	return true
end

---@param ability userdata
---@param enemy userdata
---@param option CMenuComboBox
---@param absorb_option? CMenuMultiSelect
---@param bkb_option? CMenuMultiSelect
---@return boolean | table
function SpellReflect:UseSaveIfNeed(ability, enemy, option, absorb_option, bkb_option)
	if self:CanUse(ability, enemy, option) then
		return true
	end
	local absorb = self:GetUsableAbsorbs(ability, enemy, absorb_option)[1]
	if absorb ~= nil then
		local use = self:UseSaveAbility(absorb, enemy)
		if use then
			return use
		end
	end
	local bkb = self:GetUsableBKBs(ability, enemy, bkb_option)[1]
	if bkb ~= nil then
		local use = self:UseSaveAbility(bkb, enemy)
		if use then
			return use
		end
	end
	return false
end

---@param save userdata
---@param enemy userdata
---@return table | nil
function SpellReflect:UseSaveAbility(save, enemy)
	local caster = Ability.GetOwner(save)
	if NPC.IsChannellingAbilityOrItem(caster) then
		NPC.Stop(caster)
	end
	if Ability.HasBehavior(save, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
		Ability.Cast(save, caster)
		return {save, Ability.GetCastPoint(save)}
	elseif Ability.HasBehavior(save, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
		local target_team = Ability.GetTargetTeam(save)
		if target_team == Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_FRIENDLY then
			Ability.Cast(save, caster)
			return {save, Ability.GetCastPoint(save)}
		elseif target_team == Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_ENEMY then
			local target_type = Ability.GetTargetType(save)
			for _, enemy in pairs(NPCs.InRadius(Entity.GetAbsOrigin(caster), Ability.GetEffectiveCastRange(save), Entity.GetTeamNum(caster), target_team)) do
				if (target_type & Enum.TargetType.DOTA_UNIT_TARGET_BASIC) == Enum.TargetType.DOTA_UNIT_TARGET_BASIC then
					if NPC.IsCreep(enemy) or NPC.IsHero(enemy) then
						Ability.Cast(save, enemy)
						return {save, Ability.GetCastPoint(save) + NPC.GetTimeToFacePosition(caster, Entity.GetAbsOrigin(enemy))}
					end
				elseif (target_type & Enum.TargetType.DOTA_UNIT_TARGET_HERO) == Enum.TargetType.DOTA_UNIT_TARGET_HERO then
					if NPC.IsHero(enemy) then
						Ability.Cast(save, enemy)
						return {save, Ability.GetCastPoint(save) + NPC.GetTimeToFacePosition(caster, Entity.GetAbsOrigin(enemy))}
					end
				end
			end
		elseif target_team == Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_BOTH then
			Ability.Cast(save, caster)
			return {save, Ability.GetCastPoint(save)}
		end
	elseif Ability.HasBehavior(save, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_POINT) then
		Ability.Cast(save, Entity.GetAbsOrigin(caster) + (Entity.GetAbsOrigin(enemy) - Entity.GetAbsOrigin(caster)):Normalized() * 25)
		return {save, Ability.GetCastPoint(save) + NPC.GetTimeToFacePosition(caster, Entity.GetAbsOrigin(enemy))}
	end
end

---@param ability userdata
---@param enemy userdata
---@param absorb_option CMenuMultiSelect
---@return userdata[]
function SpellReflect:GetUsableAbsorbs(ability, enemy, absorb_option)
	local caster = Ability.GetOwner(ability)
	local usable_absorbs_names = table.map(NPC.GetUsableSpellAbsorbs(caster), function(_, ability) return Ability.GetName(ability) end)
	return table.map(table.values(table.filter(absorb_option:ListEnabled(), function(_, ability_name) return table.contains(usable_absorbs_names, ability_name) end)), function(_, ability_name) return NPC.GetAbilityOrItemByName(caster, ability_name) end)
end

---@param ability userdata
---@param enemy userdata
---@param bkb_option CMenuMultiSelect
---@return userdata[]
function SpellReflect:GetUsableBKBs(ability, enemy, bkb_option)
	local caster = Ability.GetOwner(ability)
	local usable_bkbs_names = table.map(NPC.GetUsableBKBs(caster, true, ability, Entity.GetAbsOrigin(enemy)), function(_, bkb) return bkb:GetName() end)
	return table.map(table.values(table.filter(bkb_option:ListEnabled(), function(_, bkb) return table.contains(usable_bkbs_names, bkb) end)), function(_, bkb) return NPC.GetAbilityOrItemByName(caster, bkb) end)
end

return SpellReflect