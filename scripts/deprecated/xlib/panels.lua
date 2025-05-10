---@class Panel
---@field name string
---@field position Vec2
---@field visible boolean
---@field draw_callback function
---@field can_move_callback function
Panel = {}
Panel.__index = Panel

function Panel.new(name, draw_callback, can_move_callback, default_position)
	local screen_size = Render.ScreenSize()
	default_position = default_position or Vec2(math.floor(screen_size.x/2), math.floor(screen_size.y/2))
	local panel = setmetatable({}, Panel)
	panel.name = name
	panel.position = Vec2(Config.ReadInt("xlib_panels", panel.name.."_x", default_position.x), Config.ReadInt("xlib_panels", panel.name.."_y"), default_position.y)
	panel.visible = false
	panel.draw_callback = draw_callback
	panel.can_move_callback = can_move_callback
	panel.__size_cache = Vec2(0, 0)
	panel.__is_moving = false
	panel.__is_moving_cache = false
	Panels:AddPanel(panel)
	return panel
end

---@return Vec2
function Panel:ApproximateSize()
	return self.__size_cache
end

---@return boolean
function Panel:CanMove()
	return Input.IsKeyDown(Enum.ButtonCode.KEY_MOUSE1) and self.can_move_callback(self)
end

---@param position Vec2
function Panel:Move(position)
	self.position = position
	Config.WriteInt("xlib_panels", self.name.."_x", math.floor(position.x))
	Config.WriteInt("xlib_panels", self.name.."_y", math.floor(position.y))
	self.__is_moving = true
	self.__is_moving_cache = false
end

---@param visible boolean
function Panel:SetVisible(visible)
	self.visible = visible
	self.__is_moving = false
	self.__is_moving_cache = false
end

---@return Vec2
function Panel:Draw()
	local size = self.draw_callback(self)
	self.__size_cache = size
	if self.__is_moving then
		if not self.__is_moving_cache then
			self.__is_moving_cache = true
		else
			self.__is_moving = false
			self.__is_moving_cache = false
		end
	end
	return size
end

---@class Panels
Panels = {
	panels={},
	mouse_position_cache=Vec2(0,0),
}

---@param panel Panel
function Panels:AddPanel(panel)
	table.insert(self.panels, panel)
end

---@param panel Panel
---@param screen_size Vec2
---@param cursor_position Vec2
---@param cursor_position_delta Vec2
function Panels:DrawPanel(panel, screen_size, cursor_position, cursor_position_delta)
	local size = panel:ApproximateSize()
	if panel:CanMove() then
		local panel_bounds_min, panel_bounds_max = panel.position, Vec2(panel.position.x+size.x, panel.position.y+size.y)
		if ((cursor_position.x > panel_bounds_min.x and cursor_position.x < panel_bounds_max.x) and (cursor_position.y > panel_bounds_min.y and cursor_position.y < panel_bounds_max.y)) or panel.__is_moving then
			panel:Move(Vec2(math.floor(math.min(math.max(panel.position.x+cursor_position_delta.x, 0), screen_size.x-size.x)), math.floor(math.min(math.max(panel.position.y+cursor_position_delta.y, 0), screen_size.y-size.y))))
		end
	end
	panel:Draw()
end

function Panels:DrawPanels()
	local screen_size = Render.ScreenSize()
	local cursor_position = Vec2(Input.GetCursorPos())
	local cursor_position_delta = Vec2(cursor_position.x - self.mouse_position_cache.x, cursor_position.y - self.mouse_position_cache.y)
	for _, panel in pairs(self.panels) do
		if panel.visible then
			self:DrawPanel(panel, screen_size, cursor_position, cursor_position_delta)
		end
	end
	self.mouse_position_cache = cursor_position
end