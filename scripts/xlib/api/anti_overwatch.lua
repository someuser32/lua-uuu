---@class AntiOverwatch
local AntiOverwatch = {
	camera_options = {
		"Always",
		"If controlled unit near camera",
		"If controlled unit and ally near camera",
		"If caster near camera",
	},
	default_camera_distance = 1200,
	camera_legit_threshold = 250,
}

---@enum Enum.AntiOverwatchCameraOption
Enum.AntiOverwatchCameraOption = {
	SIMPLE = 1,
	ADVANCED = 2,
}

---@param parent CMenuGroup | CMenuGearAttachment
---@param gear? boolean
---@param camera? Enum.AntiOverwatchCameraOption
---@return table
function AntiOverwatch:CreateUI(parent, gear, camera)
	local modules = {}
	local anti_overwatch = parent
	if gear then
		local label = parent:Label("Anti Overwatch")
		label:Icon("\u{e333}")
		anti_overwatch = label:Gear("Anti Overwatch")
	end
	if camera then
		if camera == Enum.AntiOverwatchCameraOption.ADVANCED then
			local camera = anti_overwatch:Combo("Camera options", self.camera_options, 1)
			camera:Icon("\u{e0da}")
			camera:ToolTip("[Always] - always usage\n[If controlled unit near camera] - if your controlled unit (Tempest Double etc) near server camera pos\n[If controlled unit and ally near camera] - if your controlled unit (Tempest Double etc) and ally near server camera pos\n[If caster near camera] - if your any caster (including you, controlling units and allies) near server camera pos")
			table.insert(modules, camera)
		elseif camera == Enum.AntiOverwatchCameraOption.SIMPLE then
			local camera = anti_overwatch:Switch("Use out of camera", true)
			camera:Icon("\u{e0da}")
			table.insert(modules, camera)
		end
	end
	return modules
end

---@param caster userdata
---@param position Vector
---@param camera_option CMenuSwitch|CMenuComboBox
function AntiOverwatch:CanUseAtCamera(caster, position, camera_option)
	local camera_behavior = camera_option:Get()
	local camera_position = Humanizer.GetServerCameraPos()

	local is_local_hero = Heroes.GetLocal() == caster
	local is_ally = Players.GetLocal() ~= Entity.RecursiveGetOwner(caster)

	if camera_behavior == 0 or camera_behavior == true then
		return true
	elseif camera_behavior == 1 then
		if is_local_hero or is_ally then
			return true
		end
	elseif camera_behavior == 2 then
		if is_local_hero then
			return true
		end
	elseif camera_behavior == 3 or camera_behavior == false then
	end
	return Humanizer.IsInServerCameraBounds(position) or (camera_position - position):Length2D() < self.default_camera_distance + self.camera_legit_threshold
end

return AntiOverwatch