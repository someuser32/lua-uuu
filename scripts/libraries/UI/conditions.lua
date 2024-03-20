local Conditions = class("Conditions")

function Conditions:initialize()
	self.invis_options = {
		"Always",
		"If visible",
		"If true sighted",
		"Never",
	}
end

function Conditions:CreateUI(whereAt, invis, channelings)
	local modules = {}
	if invis then
		local invisibility = UILib:CreateCombo({whereAt, "Conditions"}, "Invisibility", self.invis_options, 2)
		invisibility:SetIcon("~/MenuIcons/eye_dashed.png")
		table.insert(modules, invisibility)
	end
	if channelings then
		local channeling = UILib:CreateCheckbox({whereAt, "Conditions"}, "Interrupt channelings", false)
		channeling:SetIcon("~/MenuIcons/open_book.png")
		table.insert(modules, channeling)
	end
	UILib:SetTabIcon({whereAt, "Conditions"}, "~/MenuIcons/Lists/true_false.png")
	return modules
end

function Conditions:CanUse(caster, invis, channelings)
	if channelings and not channelings:Get() and caster:IsChannellingAbility() then
		return false
	end
	if invis and caster:IsInvisible() then
		local invis_option = invis:GetIndex()
		if invis_option == 2 then
			if not caster:IsVisibleToEnemies() then
				return false
			end
		elseif invis_option == 3 then
			if not caster:IsTrueSight() then
				return false
			end
		elseif invis_option == 4 then
			return false
		end
	end
	return true
end

return Conditions:new()