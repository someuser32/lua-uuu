---@class UILibOptionColor: UILibOptionBase
UILibOptionColor = class("UILibOptionColor", UILibOptionBase)

---@return nil
function UILibOptionColor:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "color"
end

---@param whereAt string[]
---@param name string
---@param r number?
---@param g number?
---@param b number?
---@param a number?
---@return integer
function UILibOptionColor:CreateOption(whereAt, name, r, g, b, a)
	return Menu.AddOptionColorPicker(whereAt, name, r, g, b, a)
end

return UILibOptionColor