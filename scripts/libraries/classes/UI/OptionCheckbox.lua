---@class UILibOptionCheckbox: UILibOptionBase
UILibOptionCheckbox = class("UILibOptionCheckbox", UILibOptionBase)

---@return nil
function UILibOptionCheckbox:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "checkbox"
end

---@param whereAt string[]
---@param name string
---@param defaultBool boolean?
---@return integer
function UILibOptionCheckbox:CreateOption(whereAt, name, defaultBool)
	return Menu.AddOptionBool(whereAt, name, defaultBool or false)
end

---@return boolean
function UILibOptionCheckbox:Get()
	return Menu.IsEnabled(self.menu_option)
end

return UILibOptionCheckbox