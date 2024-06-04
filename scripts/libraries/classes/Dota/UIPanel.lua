---@class CUIPanel: DBase
local CUIPanel = class("CUIPanel", DBase)

---@param func_name string
---@param val any
---@return string[] | any?
function CUIPanel.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local types = {
		["FindChild"] = "CUIPanel",
		["FindChildInLayoutFile"] = "CUIPanel",
		["FindPanelInLayoutFile"] = "CUIPanel",
		["FindChildTraverse"] = "CUIPanel",
		["GetChild"] = "CUIPanel",
		["GetChildByPath"] = "CUIPanel",
		["GetFirstChild"] = "CUIPanel",
		["GetLastChild"] = "CUIPanel",
		["GetParent"] = "CUIPanel",
		["GetRootParent"] = "CUIPanel",
	}
	return types[func_name] or DBase.GetType(self, func_name, val)
end

---@param path string[]
---@return CUIPanel?
function CUIPanel:FindChildByPathTraverse(path)
	local panel = self
	for _, p in pairs(path) do
		panel = panel:FindChildTraverse(p)
		if panel == nil then
			return nil
		end
	end
	return panel
end


---@return {x: number, y: number, w: number, h: number}
function CUIPanel:GetBounds()
	local x, y = 0, 0
	local temp_panel = self
	while temp_panel ~= nil do
		x = x + temp_panel:GetXOffset()
		y = y + temp_panel:GetYOffset()
		temp_panel = temp_panel:GetParent()
	end
	return {x=x, y=y, w=self:GetLayoutWidth(), h=self:GetLayoutHeight()}
end

_Classes_Inherite({getmetatable(UIPanel())}, CUIPanel)

return CUIPanel