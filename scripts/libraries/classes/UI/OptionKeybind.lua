UILibOptionKeybind = class("UILibOptionKeybind", UILibOptionBase)

function UILibOptionKeybind:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "key"
end

function UILibOptionKeybind:CreateOption(whereAt, name, defaultButton)
	return Menu.AddKeyOption(whereAt, name, defaultButton or Enum.ButtonCode.KEY_NONE)
end

function UILibOptionKeybind:IsActive()
	return Menu.IsKeyDown(self.menu_option)
end

function UILibOptionKeybind:IsActiveOnce()
	return Menu.IsKeyDownOnce(self.menu_option)
end

return UILibOptionKeybind