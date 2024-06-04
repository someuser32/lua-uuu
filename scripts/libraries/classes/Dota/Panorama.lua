---@class CPanorama: DBase
local CPanorama = class("CPanorama", DBase)

---@return boolean
function CPanorama.static:StaticAPIs()
	return true
end

---@param func_name string
---@param val any
---@return string[] | any?
function CPanorama.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["GetPanelByPath"] = "CUIPanel",
		["GetPanelByName"] = "CUIPanel",
	}
	return types[func_name] or DBase.GetType(self, func_name, val)
end

_Classes_Inherite({"Panorama"}, CPanorama)

return CPanorama