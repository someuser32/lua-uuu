---@class UILibOptionButton: UILibOptionBase
UILibOptionButton = class("UILibOptionButton", UILibOptionBase)

---@return nil
function UILibOptionButton:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "button"
end

---@return nil
function UILibOptionButton:Callback()
end

---@param whereAt string[]
---@param name string
---@param callback function?
---@return integer
function UILibOptionButton:CreateOption(whereAt, name, callback)
	return Menu.AddButtonOption(whereAt, name, callback or function() return self:Callback() end)
end

return UILibOptionButton