UILibOptionCheckbox = class("UILibOptionCheckbox", UILibOptionBase)

function UILibOptionCheckbox:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "checkbox"
end

function UILibOptionCheckbox:CreateOption(whereAt, name, defaultBool)
	return Menu.AddOptionBool(whereAt, name, defaultBool or false)
end

function UILibOptionCheckbox:Get()
	return Menu.IsEnabled(self.menu_option)
end

return UILibOptionCheckbox