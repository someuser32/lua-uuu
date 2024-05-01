---@class UILibOptionBase
UILibOptionBase = class("UILibOptionBase")

---@param whereAt string[]
---@param name string
---@return nil
function UILibOptionBase:initialize(whereAt, name, ...)
	self.type = self.type or "none"
	self.path = whereAt
	self.id = name
	self.full_path = table.combine(whereAt, name)
	self.menu_option = self:CreateOption(whereAt, name, ...)
end

---@param option2 UILibOptionBase | any?
---@return boolean
function UILibOptionBase:__eq(option2)
	return self.menu_option == (option2.menu_option ~= nil and option2.menu_option or option2)
end

---@param whereAt string[]
---@param name string
---@return nil
function UILibOptionBase:CreateOption(whereAt, name, ...)
	return nil
end

---@return any
function UILibOptionBase:Get()
	return Menu.GetValue(self.menu_option)
end

---@param value any
---@return nil
function UILibOptionBase:Set(value)
	return Menu.SetValue(self.menu_option, value, true)
end

---@param icon_path string
---@return nil
function UILibOptionBase:SetIcon(icon_path)
	if icon_path == nil then
		return Menu.RemoveOptionIcon(self.menu_option)
	end
	return Menu.AddOptionIcon(self.menu_option, icon_path)
end

---@param icon_path string
---@return nil
function UILibOptionBase:SetTabIcon(icon_path)
	if icon_path == nil then
		return Menu.RemoveMenuIcon(self.path)
	end
	return Menu.AddMenuIcon(self.path, icon_path)
end

---@param text string
---@return nil
function UILibOptionBase:SetTip(text)
	return Menu.AddOptionTip(self.menu_option, text)
end

---@return nil
function UILibOptionBase:Remove()
	return Menu.RemoveOption(self.menu_option)
end

return UILibOptionBase