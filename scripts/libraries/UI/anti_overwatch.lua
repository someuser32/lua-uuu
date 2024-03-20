local AntiOverwatch = class("AntiOverwatch")

function AntiOverwatch:initialize()
	self.camera_options = {
		"Always",
		"If controlled unit near camera",
		"If controlled unit and ally near camera",
		"If caster near camera",
	}
	self.default_camera_distance = 1200
end

function AntiOverwatch:CreateUI(whereAt, camera)
	local modules = {}
	if camera then
		if camera == 1 then
			local anti_overwatch_camera = UILib:CreateCombo({whereAt, "Anti-Overwatch"}, "Camera options", self.camera_options, 1)
			anti_overwatch_camera:SetTip("[Always] - always usage\n[If controlled unit near camera] - if your controlled unit (Tempest Double etc) near server camera pos\n[If controlled unit and ally near camera] - if your controlled unit (Tempest Double etc) and ally near server camera pos\n[If caster near camera] - if your any caster (including you, controlling units and allies) near server camera pos")
			anti_overwatch_camera:SetIcon("~/MenuIcons/binoculars_filled.png")
			table.insert(modules, anti_overwatch_camera)
		elseif camera == 2 then
			local anti_overwatch_camera = UILib:CreateCheckbox({whereAt, "Anti-Overwatch"}, "Use out of camera", true)
			anti_overwatch_camera:SetIcon("~/MenuIcons/binoculars_filled.png")
			table.insert(modules, anti_overwatch_camera)
		end
	end
	UILib:SetTabIcon({whereAt, "Anti-Overwatch"}, "~/MenuIcons/robot.png")
	return modules
end

function AntiOverwatch:CanUseAtCamera(caster, position, option)
	local camera_legit_threshold = 250
	local camera_behavior = option.type == "combo" and option:GetIndex() or option:Get()
	local camera_position = CHumanizer:GetServerCameraPos()

	local is_local_hero = CHero:GetLocal() == caster
	local is_ally = CPlayer:GetLocal() ~= caster:RecursiveGetOwner()

	if camera_behavior == 1 or camera_behavior == true then
		return true
	elseif camera_behavior == 2 then
		if is_local_hero or is_ally then
			return true
		end
	elseif camera_behavior == 3 then
		if is_local_hero then
			return true
		end
	elseif camera_behavior == 4 or camera_behavior == false then
	end
	return CHumanizer:IsInServerCameraBounds(enemy_position) or (camera_position - position):Length2D() < self.default_camera_distance + 300
end

return AntiOverwatch:new()