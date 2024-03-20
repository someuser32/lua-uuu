local class = require("lib/middleclass")

UI_LIB_OPTION_BASE = class("UILibOptionBase")

function UI_LIB_OPTION_BASE:initialize(whereAt, name, ...)
	self.type = self.type or "none"
	self.path = whereAt
	self.id = name
	self.full_path = table.combine(whereAt, name)
	self.menu_option = self:create_option(whereAt, name, ...)
end

function UI_LIB_OPTION_BASE:__eq(option2)
	return self.menu_option == (option2.menu_option ~= nil and option2.menu_option or option2)
end

function UI_LIB_OPTION_BASE:create_option(whereAt, name, ...)
	return nil
end

function UI_LIB_OPTION_BASE:get_value()
	return Menu.GetValue(self.menu_option)
end

function UI_LIB_OPTION_BASE:set_icon(icon_path)
	if icon_path == nil then
		return Menu.RemoveOptionIcon(self.menu_option)
	end
	return Menu.AddOptionIcon(self.menu_option, icon_path)
end

function UI_LIB_OPTION_BASE:set_tab_icon(icon_path)
	if icon_path == nil then
		return Menu.RemoveMenuIcon(self.path)
	end
	return Menu.AddMenuIcon(self.path, icon_path)
end

function UI_LIB_OPTION_BASE:set_tip(text)
	return Menu.AddOptionTip(self.menu_option, text)
end

function UI_LIB_OPTION_BASE:remove()
	return Menu.RemoveOption(self.menu_option)
end

function UI_LIB_OPTION_BASE:set_value(value)
	return Menu.SetValue(self.menu_option, value, true)
end

UI_LIB_OPTION_BOOL = class("UILibOptionBool", UI_LIB_OPTION_BASE)

function UI_LIB_OPTION_BOOL:initialize(...)
	UI_LIB_OPTION_BASE.initialize(self, ...)
	self.type = "bool"
end

function UI_LIB_OPTION_BOOL:create_option(whereAt, name, defaultBool)
	return Menu.AddOptionBool(whereAt, name, defaultBool or false)
end

function UI_LIB_OPTION_BOOL:get_value()
	return Menu.IsEnabled(self.menu_option)
end

UI_LIB_OPTION_SLIDER = class("UILibOptionSlider", UI_LIB_OPTION_BASE)

function UI_LIB_OPTION_SLIDER:initialize(...)
	UI_LIB_OPTION_BASE.initialize(self, ...)
	self.type = "slider"
end

function UI_LIB_OPTION_SLIDER:create_option(whereAt, name, min, max, default)
	if min == math.floor(min) and max == math.floor(max) and default == math.floor(default) then
		return Menu.AddOptionSlider(whereAt, name, min or 0, max or 1, default or math.floor((min+max)/2))
	end
	return Menu.AddOptionSliderFloat(whereAt, name, min or 0, max or 1, default or (min+max)/2)
end

UI_LIB_OPTION_COMBO = class("UILibOptionCombo", UI_LIB_OPTION_BASE)

function UI_LIB_OPTION_COMBO:initialize(...)
	UI_LIB_OPTION_BASE.initialize(self, ...)
	self.type = "combo"
end

function UI_LIB_OPTION_COMBO:create_option(whereAt, name, items, defaultIndex)
	return Menu.AddOptionCombo(whereAt, name, items, (defaultIndex or 1) - 1)
end

function UI_LIB_OPTION_COMBO:get_items()
	return Menu.GetItems(self.menu_option)
end

function UI_LIB_OPTION_COMBO:get_value()
	return self:get_items()[self:get_selected_index()]
end

function UI_LIB_OPTION_COMBO:get_selected_index()
	return Menu.GetValue(self.menu_option) + 1
end

function UI_LIB_OPTION_COMBO:is_selected(index)
	return self:get_selected_index() == index
end

UI_LIB_OPTION_KEY = class("UILibOptionKey", UI_LIB_OPTION_BASE)

function UI_LIB_OPTION_KEY:initialize(...)
	UI_LIB_OPTION_BASE.initialize(self, ...)
	self.type = "key"
end

function UI_LIB_OPTION_KEY:create_option(whereAt, name, defaultButton)
	return Menu.AddKeyOption(whereAt, name, defaultButton or Enum.ButtonCode.KEY_NONE)
end

function UI_LIB_OPTION_KEY:is_active()
	return Menu.IsKeyDown(self.menu_option)
end

UI_LIB_OPTION_BUTTON = class("UILibOptionButton", UI_LIB_OPTION_BASE)

function UI_LIB_OPTION_BUTTON:initialize(...)
	UI_LIB_OPTION_BASE.initialize(self, ...)
	self.type = "button"
end

function UI_LIB_OPTION_BUTTON:callback()
end

function UI_LIB_OPTION_BUTTON:create_option(whereAt, name, callback)
	return Menu.AddButtonOption(whereAt, name, callback or function() return self:callback() end)
end

UI_LIB_OPTION_MULTISELECT = class("UILibOptionMultiSelect", UI_LIB_OPTION_BASE)

function UI_LIB_OPTION_MULTISELECT:initialize(...)
	UI_LIB_OPTION_BASE.initialize(self, ...)
	self.type = "multiselect"
end

function UI_LIB_OPTION_MULTISELECT:create_option(whereAt, name, itemsTable, singleSelectMode)
	return Menu.AddOptionMultiSelect(whereAt, name, itemsTable or {}, singleSelectMode or false)
end

function UI_LIB_OPTION_MULTISELECT:get_items()
	return Menu.GetItems(self.menu_option)
end

function UI_LIB_OPTION_MULTISELECT:get_value()
	return table.values(table.filter(self:get_items(), function(_, name) return self:is_selected(name) end))
end

function UI_LIB_OPTION_MULTISELECT:is_selected(name)
	return Menu.IsSelected(self.menu_option, name)
end

UI_LIB_OPTION_COLOR = class("UILibOptionColor", UI_LIB_OPTION_BASE)

function UI_LIB_OPTION_COLOR:initialize(...)
	UI_LIB_OPTION_BASE.initialize(self, ...)
	self.type = "color"
end

function UI_LIB_OPTION_COLOR:create_option(whereAt, name, r, g, b, a)
	return Menu.AddOptionColorPicker(whereAt, name, r, g, b, a)
end

UI_LIB_OPTION_INPUT = class("UILibOptionInput", UI_LIB_OPTION_BASE)

function UI_LIB_OPTION_INPUT:initialize(...)
	UI_LIB_OPTION_BASE.initialize(self, ...)
	self.type = "color"
end

function UI_LIB_OPTION_INPUT:create_option(whereAt, name, defaultString)
	return Menu.AddOptionInputText(whereAt, name, defaultString)
end

function UI_LIB_OPTION_INPUT:get_value()
	return Menu.GetInputText(self.menu_option)
end