UILibOptionMultiselect = class("UILibOptionMultiselect", UILibOptionBase)

function UILibOptionMultiselect:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "multiselect"
end

function UILibOptionMultiselect:CreateOption(whereAt, name, itemsTable, singleSelectMode)
	return Menu.AddOptionMultiSelect(whereAt, name, itemsTable or {}, singleSelectMode or false)
end

function UILibOptionMultiselect:GetItems()
	return Menu.GetItems(self.menu_option)
end

function UILibOptionMultiselect:Get()
	return table.values(table.filter(self:GetItems(), function(_, name) return self:IsSelected(name) end))
end

function UILibOptionMultiselect:IsSelected(name)
	return Menu.IsSelected(self.menu_option, name)
end

return UILibOptionMultiselect