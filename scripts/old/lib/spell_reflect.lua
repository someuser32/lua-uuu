local class = require("lib/middleclass")

SpellReflect = class("SpellReflect")

function SpellReflect:initialize()
	self.options = {
		"Don't use",
		"Ignore",
		"Safe",
		"Safest",
	}
end

function SpellReflect:create_option(whereAt)
	local option = UI_LIB:create_combo(whereAt, "Spell Reflect", self.options, 3)
	option:set_icon("panorama/images/items/lotus_orb_png.vtex_c")
	option:set_tip("[Don't use] - don't use abilities\n[Ignore] - use always\n[Safe] - use only if caster absorbs spells or is bkb protected from ability\n[Safest] - use only if caster is bkb protected from ability")
	return option
end

function SpellReflect:can_use(ability, enemy, option)
	local behavior = option:get_selected_index()
	local caster = ability:GetCaster()
	if behavior == 1 then
		return not enemy:IsReflectsSpells()
	elseif behavior == 2 then
		return true
	elseif behavior == 3 then
		if not enemy:IsReflectsSpells() then
			return true
		end
		if caster:IsLinkensProtected() or caster:IsMirrorProtected() or caster:IsAbsorbsSpells() then
			return true
		end
		if caster:IsDebuffImmune() and not ability:PiercesBKB() then
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
	end
	return true
end

return SpellReflect:new()