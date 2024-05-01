---@class UILibOptionMultiselect: UILibOptionBase
UILibOptionMultiselect = class("UILibOptionMultiselect", UILibOptionBase)

---@return nil
function UILibOptionMultiselect:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "multiselect"
end

---@param whereAt string[]
---@param name string
---@param itemsTable [string, string, boolean][]
---@param singleSelectMode boolean?
---@return integer
function UILibOptionMultiselect:CreateOption(whereAt, name, itemsTable, singleSelectMode)
	return Menu.AddOptionMultiSelect(whereAt, name, itemsTable or {}, singleSelectMode or false)
end

---@return string[]
function UILibOptionMultiselect:GetItems()
	return Menu.GetItems(self.menu_option)
end

---@return string[]
function UILibOptionMultiselect:Get()
	return table.values(table.filter(self:GetItems(), function(_, name) return self:IsSelected(name) end))
end

---@param name string
---@return boolean
function UILibOptionMultiselect:IsSelected(name)
	return Menu.IsSelected(self.menu_option, name)
end

return UILibOptionMultiselect