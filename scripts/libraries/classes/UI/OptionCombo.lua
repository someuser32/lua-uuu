---@class UILibOptionCombo: UILibOptionBase
UILibOptionCombo = class("UILibOptionCombo", UILibOptionBase)

---@return nil
function UILibOptionCombo:initialize(...)
	self.items = {}
	UILibOptionBase.initialize(self, ...)
	self.type = "combo"
end

---@param whereAt string[]
---@param name string
---@param items string[]
---@param defaultIndex number?
---@return integer
function UILibOptionCombo:CreateOption(whereAt, name, items, defaultIndex)
	self.items = items
	return Menu.AddOptionCombo(whereAt, name, items, (defaultIndex or 1) - 1)
end

---@return string[]
function UILibOptionCombo:GetItems()
	return self.items
end

---@return string
function UILibOptionCombo:Get()
	return self:GetItems()[self:GetIndex()]
end

---@return integer
function UILibOptionCombo:GetIndex()
	return Menu.GetValue(self.menu_option) + 1
end

---@param index integer
---@return boolean
function UILibOptionCombo:IsSelected(index)
	return self:GetIndex() == index
end

return UILibOptionCombo