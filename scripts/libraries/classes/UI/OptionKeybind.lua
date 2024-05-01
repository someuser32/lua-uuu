---@class UILibOptionKeybind: UILibOptionBase
UILibOptionKeybind = class("UILibOptionKeybind", UILibOptionBase)

---@return nil
function UILibOptionKeybind:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "key"
end

---@param whereAt string[]
---@param name string
---@param defaultButton Enum.ButtonCode?
---@return integer
function UILibOptionKeybind:CreateOption(whereAt, name, defaultButton)
	return Menu.AddKeyOption(whereAt, name, defaultButton or Enum.ButtonCode.KEY_NONE)
end

---@return boolean
function UILibOptionKeybind:IsActive()
	return Menu.IsKeyDown(self.menu_option)
end

---@return boolean
function UILibOptionKeybind:IsActiveOnce()
	return Menu.IsKeyDownOnce(self.menu_option)
end

return UILibOptionKeybind