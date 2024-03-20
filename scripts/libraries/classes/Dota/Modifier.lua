local CModifier = class("CModifier", DBase)

function CModifier.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetAbility"] = "CAbility",
	}
	return types[func_name] or DBase.GetType(self, func_name, val)
end

function CModifier:initialize(...)
	DBase.initialize(self, ...)
	self._original_modifier_name = self:GetName()
end

function CModifier:IsValid()
	return self:GetName() == self._original_modifier_name
end

_Classes_Inherite({"Modifier"}, CModifier)

return CModifier