local SpellReflect = class("SpellReflect")

function SpellReflect:initialize()
	self.usage_options = {
		"Don't use",
		"Ignore",
		"Safe",
		"Safest",
	}
end

function SpellReflect:CreateUI(whereAt)
	local modules = {}
	local usage_option = UILib:CreateCombo({whereAt, "Spell Reflect"}, "Mode", self.usage_options, 3)
	usage_option:SetTip("[Don't use] - don't use abilities\n[Ignore] - use always\n[Safe] - use only if caster absorbs spells or is bkb protected from ability\n[Safest] - use only if caster is bkb protected from ability")
	table.insert(modules, usage_option)
	local absorb_usage_option = UILib:CreateMultiselect({whereAt, "Spell Reflect"}, "Auto spell absorb for safe use", {{"antimage_counterspell", CAbility:GetAbilityNameIconPath("antimage_counterspell"), false}}, false)
	absorb_usage_option:SetIcon(CAbility:GetAbilityNameIconPath("antimage_counterspell"))
	absorb_usage_option:SetTip("Has higher priority than Auto BKB usage\nOnly works on Safe, turn all off to disable auto spell absorb usage")
	table.insert(modules, absorb_usage_option)
	local bkb_usage_option = UILib:CreateMultiselect({whereAt, "Spell Reflect"}, "Auto BKB for safe use", table.values(table.map(CAbility:GetBKBs(true), function(_, bkb) return {bkb, CAbility:GetAbilityNameIconPath(bkb), false} end)), false)
	bkb_usage_option:SetIcon(CAbility:GetAbilityNameIconPath("item_black_king_bar"))
	bkb_usage_option:SetTip("Only works on Safe and Safest modes, turn all off to disable auto bkb usage")
	table.insert(modules, bkb_usage_option)
	UILib:SetTabIcon({whereAt, "Spell Reflect"}, CAbility:GetAbilityNameIconPath("item_lotus_orb"))
	return modules
end

function SpellReflect:CanUse(ability, enemy, option, absorb_option, bkb_option)
	local behavior = option:GetIndex()
	local caster = ability:GetCaster()
	if behavior == 1 then
		return not enemy:IsReflectsSpells()
	elseif behavior == 2 then
		return true
	elseif behavior == 3 then
		if not enemy:IsReflectsSpells() then
			return true
		end
		if caster:GetLinkenProtects() > enemy:GetLinkenProtects() or caster:IsAbsorbsSpells() then
			return true
		end
		if caster:IsDebuffImmune() and not ability:PiercesBKB() then
			return true
		end
		if absorb_option ~= nil and #self:GetUsableAbsorbs(ability, enemy, absorb_option) > 0 then
			return true
		end
		if bkb_option ~= nil and #self:GetUsableBKBs(ability, enemy, bkb_option) > 0 then
			return true
		end
		return false
	elseif behavior == 4 then
		if not enemy:IsReflectsSpells() then
			return true
		end
		if caster:IsAbsorbsSpells() then
			return true
		end
		if caster:IsDebuffImmune() and not ability:PiercesBKB() then
			return true
		end
		if bkb_option ~= nil and #self:GetUsableBKBs(ability, enemy, bkb_option) > 0 then
			return true
		end
	end
	return true
end

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

function SpellReflect:UseSaveAbility(save, enemy)
	local caster = save:GetCaster()
	if caster:IsChannellingAbility() then
		caster:Stop()
	end
	if save:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
		save:Cast(caster)
		return {save, save:GetCastPoint()}
	elseif save:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
		local target_team = save:GetTargetTeam()
		if target_team == Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_FRIENDLY then
			save:Cast(caster)
			return {save, save:GetCastPoint()}
		elseif target_team == Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_ENEMY then
			local target_type = save:GetTargetType()
			for _, enemy in pairs(CNPC:FindInRadius(caster:GetAbsOrigin(), save:GetCastRange(), caster:GetTeamNum(), target_team)) do
				if (target_type & Enum.TargetType.DOTA_UNIT_TARGET_BASIC) == Enum.TargetType.DOTA_UNIT_TARGET_BASIC then
					if enemy:IsCreep() or enemy:IsHero() then
						save:Cast(enemy)
						return {save, save:GetCastPoint() + caster:GetTimeToFacePosition(enemy:GetAbsOrigin())}
					end
				elseif (target_type & Enum.TargetType.DOTA_UNIT_TARGET_HERO) == Enum.TargetType.DOTA_UNIT_TARGET_HERO then
					if enemy:IsHero() then
						save:Cast(enemy)
						return {save, save:GetCastPoint() + caster:GetTimeToFacePosition(enemy:GetAbsOrigin())}
					end
				end
			end
		elseif target_team == Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_BOTH then
			save:Cast(caster)
			return {save, save:GetCastPoint()}
		end
	elseif save:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_POINT) then
		save:Cast(caster:GetAbsOrigin() + (enemy:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * 25)
		return {save, save:GetCastPoint() + caster:GetTimeToFacePosition(enemy:GetAbsOrigin())}
	end
end

function SpellReflect:GetUsableAbsorbs(ability, enemy, absorb_option)
	local caster = ability:GetCaster()
	local usable_absorbs_names = table.map(caster:GetUsableSpellAbsorbs(), function(_, ability) return ability:GetName() end)
	return table.map(table.values(table.filter(absorb_option:Get(), function(_, ability_name) return table.contains(usable_absorbs_names, ability_name) end)), function(_, ability_name) return caster:GetAbilityOrItemByName(ability_name) end)
end

function SpellReflect:GetUsableBKBs(ability, enemy, bkb_option)
	local caster = ability:GetCaster()
	local usable_bkbs_names = table.map(caster:GetUsableBKBs(true, ability, enemy:GetAbsOrigin()), function(_, bkb) return bkb:GetName() end)
	return table.map(table.values(table.filter(bkb_option:Get(), function(_, bkb) return table.contains(usable_bkbs_names, bkb) end)), function(_, bkb) return caster:GetAbilityOrItemByName(bkb) end)
end

return SpellReflect:new()