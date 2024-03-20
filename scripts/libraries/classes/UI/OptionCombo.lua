UILibOptionCombo = class("UILibOptionCombo", UILibOptionBase)

function UILibOptionCombo:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "combo"
end

function UILibOptionCombo:CreateOption(whereAt, name, items, defaultIndex)
	return Menu.AddOptionCombo(whereAt, name, items, (defaultIndex or 1) - 1)
end

function UILibOptionCombo:GetItems()
	return Menu.GetItems(self.menu_option)
end

function UILibOptionCombo:Get()
	return self:get_items()[self:GetIndex()]
end

function UILibOptionCombo:GetIndex()
	return Menu.GetValue(self.menu_option) + 1
end

function UILibOptionCombo:IsSelected(index)
	return self:GetIndex() == index
end

return UILibOptionCombo