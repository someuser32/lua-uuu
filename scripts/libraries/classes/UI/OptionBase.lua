UILibOptionBase = class("UILibOptionBase")

function UILibOptionBase:initialize(whereAt, name, ...)
	self.type = self.type or "none"
	self.path = whereAt
	self.id = name
	self.full_path = table.combine(whereAt, name)
	self.menu_option = self:CreateOption(whereAt, name, ...)
end

function UILibOptionBase:__eq(option2)
	return self.menu_option == (option2.menu_option ~= nil and option2.menu_option or option2)
end

function UILibOptionBase:CreateOption(whereAt, name, ...)
	return nil
end

function UILibOptionBase:Get()
	return Menu.GetValue(self.menu_option)
end

function UILibOptionBase:Set(value)
	return Menu.SetValue(self.menu_option, value, true)
end

function UILibOptionBase:SetIcon(icon_path)
	if icon_path == nil then
		return Menu.RemoveOptionIcon(self.menu_option)
	end
	return Menu.AddOptionIcon(self.menu_option, icon_path)
end

function UILibOptionBase:SetTabIcon(icon_path)
	if icon_path == nil then
		return Menu.RemoveMenuIcon(self.path)
	end
	return Menu.AddMenuIcon(self.path, icon_path)
end

function UILibOptionBase:SetTip(text)
	return Menu.AddOptionTip(self.menu_option, text)
end

function UILibOptionBase:Remove()
	return Menu.RemoveOption(self.menu_option)
end

return UILibOptionBase