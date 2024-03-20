UILibOptionButton = class("UILibOptionButton", UILibOptionBase)

function UILibOptionButton:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "button"
end

function UILibOptionButton:Callback()
end

function UILibOptionButton:CreateOption(whereAt, name, callback)
	return Menu.AddButtonOption(whereAt, name, callback or function() return self:Callback() end)
end

return UILibOptionButton