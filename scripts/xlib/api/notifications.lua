---@class Notifications
local Notifications = {
	sounds = {
		{"Disabled", nil},
		{"Ping (default)", "sounds/ui/ping.vsnd"},
		{"Ping (alternative)", "sounds/ui/ping_warning.vsnd"},
		{"Deny", "sounds/ui/last_hit.vsnd"},
		{"Maim", "sounds/items/maim.vsnd"},
		{"Yoink", "sounds/ui/yoink.vsnd"},
	},
}

---@param parent CMenuGroup | CMenuGearAttachment
---@param gear? boolean
---@param text? boolean
---@param sound? boolean
---@return table
function Notifications:CreateUI(parent, gear, text, sound)
	local modules = {}
	local notifications = parent
	if gear then
		local label = parent:Label("Notifications")
		label:Icon("\u{f0f3}")
		notifications = label:Gear("Notifications")
	end
	if text then
		local text_notification = notifications:Switch("Text", false)
		text_notification:Icon("\u{f4a6}")
		table.insert(modules, text_notification)
	end
	if sound then
		local sound_notification = notifications:Combo("Sound", table.map(self.sounds, function(_, sound) return sound[1] end), 0)
		sound_notification:Icon("\u{f001}")
		table.insert(modules, sound_notification)
	end
	return modules
end

---@param text string
---@param duration number
---@param text_option? CMenuSwitch
---@param sound_option? CMenuComboBox
function Notifications:SendCenteredNotification(text, duration, text_option, sound_option)
	if text_option and text_option:Get() then
		Renderer.DrawCenteredNotification(text, duration)
	end
	if sound_option ~= nil then
		local sound = self.sounds[sound_option:Get()+1][2]
		if sound then
			local volume = Menu.Find("SettingsHidden", "", "", "", "Visual", "Notifications", "Notifications", "Sound Volume") --[[@as CMenuSliderFloat]]
			Engine.PlayVol(sound, volume:Get())
		end
	end
end

return Notifications