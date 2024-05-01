---@class UILibOptionSlider: UILibOptionBase
UILibOptionSlider = class("UILibOptionSlider", UILibOptionBase)

---@return nil
function UILibOptionSlider:initialize(...)
	UILibOptionBase.initialize(self, ...)
	self.type = "slider"
end

---@param whereAt string[]
---@param name string
---@param min number
---@param max number
---@param default number?
---@param force_float boolean?
---@return integer
function UILibOptionSlider:CreateOption(whereAt, name, min, max, default, force_float)
	if not force_float and min == math.floor(min) and max == math.floor(max) and (not default or default == math.floor(default)) then
		return Menu.AddOptionSlider(whereAt, name, min or 0, max or 1, default or math.floor((min+max)/2))
	end
	return Menu.AddOptionSliderFloat(whereAt, name, min or 0, max or 1, default or (min+max)/2)
end

return UILibOptionSlider