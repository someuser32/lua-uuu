UILibOptionTextbox = class("UILibOptionTextbox", UILibOptionBase)

function UILibOptionTextbox:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "textbox"
end

function UILibOptionTextbox:CreateOption(whereAt, name, defaultString)
	return Menu.AddOptionInputText(whereAt, name, defaultString)
end

function UILibOptionTextbox:Get()
	return Menu.GetInputText(self.menu_option)
end

return UILibOptionTextbox