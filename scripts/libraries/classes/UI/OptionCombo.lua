UILibOptionCombo = class("UILibOptionCombo", UILibOptionBase)

function UILibOptionCombo:initialize(...)
	self.items = {}
	UILibOptionBase.initialize(self, ...)
	self.type = "combo"
end

function UILibOptionCombo:CreateOption(whereAt, name, items, defaultIndex)
	self.items = items
	return Menu.AddOptionCombo(whereAt, name, items, (defaultIndex or 1) - 1)
end

function UILibOptionCombo:GetItems()
	return self.items
end

function UILibOptionCombo:Get()
	return self:GetItems()[self:GetIndex()]
end

function UILibOptionCombo:GetIndex()
	return Menu.GetValue(self.menu_option) + 1
end

function UILibOptionCombo:IsSelected(index)
	return self:GetIndex() == index
end

return UILibOptionCombo