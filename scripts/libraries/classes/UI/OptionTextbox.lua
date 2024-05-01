---@class UILibOptionTextbox: UILibOptionBase
UILibOptionTextbox = class("UILibOptionTextbox", UILibOptionBase)

---@return nil
function UILibOptionTextbox:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "textbox"
end

---@param whereAt string[]
---@param name string
---@param defaultString string
---@return integer
function UILibOptionTextbox:CreateOption(whereAt, name, defaultString)
	return Menu.AddOptionInputText(whereAt, name, defaultString)
end

---@return string
function UILibOptionTextbox:Get()
	return Menu.GetInputText(self.menu_option)
end

return UILibOptionTextbox