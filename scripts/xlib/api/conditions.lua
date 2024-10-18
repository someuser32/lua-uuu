---@class Conditions
local Conditions = {
	invis_options = {
		"Always",
		"If visible",
		"If true sighted",
		"Never",
	},
}

---@param parent CMenuGroup | CMenuGearAttachment
---@param gear? boolean
---@param invis? boolean
---@param channelings? boolean
---@param return_parent? boolean
---@return table
function Conditions:CreateUI(parent, gear, invis, channelings, return_parent)
	local modules = {}
	local conditions = parent
	local returned_parent = conditions
	if gear then
		local label = parent:Label("Conditions")
		label:Icon("\u{e47a}")
		conditions = label:Gear("Conditions")
		returned_parent = label
	end
	if invis then
		local invisibility = conditions:Combo("Invisibility", self.invis_options, 1)
		invisibility:Icon("\u{f2a8}")
		table.insert(modules, invisibility)
	end
	if channelings then
		local channeling = conditions:Switch("Interrupt channelings", false)
		channeling:Icon("\u{f6b8}")
		table.insert(modules, channeling)
	end
	if return_parent then
		table.insert(modules, returned_parent)
	end
	return modules
end

---@param caster userdata
---@param invis? CMenuComboBox
---@param channelings? CMenuSwitch
---@return boolean
function Conditions:CanUse(caster, invis, channelings)
	if channelings and not channelings:Get() and NPC.IsChannellingAbilityOrItem(caster) then
		return false
	end
	if invis and NPC.IsInvisible(caster) then
		local invis_option = invis:Get()
		if invis_option == 1 then
			if not NPC.IsVisibleToEnemies(caster) then
				return false
			end
		elseif invis_option == 2 then
			if not NPC.IsTrueSight(caster) then
				return false
			end
		elseif invis_option == 3 then
			return false
		end
	end
	return true
end

return Conditions