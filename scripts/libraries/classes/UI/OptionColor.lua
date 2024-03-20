UILibOptionColor = class("UILibOptionColor", UILibOptionBase)

function UILibOptionColor:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "color"
end

function UILibOptionColor:CreateOption(whereAt, name, r, g, b, a)
	return Menu.AddOptionColorPicker(whereAt, name, r, g, b, a)
end

return UILibOptionColor