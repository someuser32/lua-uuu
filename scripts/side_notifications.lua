require("libraries/__init__")

local SideNotifications = class("SideNotifications")

function SideNotifications:initialize()
	self.path = {"Magma", "Info Screen", "Side Notifications"}

	self.twin_gate_enable = UILib:CreateCheckbox(self.path, "Twin Gate", false)
	self.twin_gate_enable:SetIcon("panorama/images/spellicons/twin_gate_portal_warp_png.vtex_c")
	self.twin_gate_enable:SetTip("Does not work for IO")

	self.side_notifications_sound = UILib:CreateCheckbox(self.path, "Sound", true)
	self.side_notifications_sound:SetIcon("~/MenuIcons/Notifications/sound_notification.png")

	UILib:SetTabIcon(self.path, "~/MenuIcons/Notifications/send_comment_revert.png")

	self.minimap_icons = {}
	self.twin_gate_info = {}
	self.twin_gate_channel_duration = 4

	self.listeners = {}
end

function SideNotifications:OnDraw()
	local now = CGameRules:GetGameTime()
	for icon_type, icons in pairs(self.minimap_icons) do
		for owner, icon in pairs(icons) do
			if icon[1] > now then
				if icon_type == "twin_gate" then
					CMiniMap:DrawHeroIcon(owner, icon[2], 255, 255, 255, 180, 700)
					CMiniMap:DrawHeroIcon(owner, icon[3], 255, 255, 255, 255, 900)
				end
			end
		end
	end
end

function SideNotifications:OnParticleCreate(particle)
	if particle["name"] == "team_portal_active" or particle["name"] == "team_portal_dire_active" then
		local modified = false
		for _, info in pairs(self.twin_gate_info) do
			if info["end_index"] == nil then
				self.twin_gate_info[_]["end_index"] = particle["index"]
				modified = true
				break
			end
		end
		if not modified then
			table.insert(self.twin_gate_info, {time=CGameRules:GetGameTime(), start_index=particle["index"], start_pos=nil, end_index=nil, end_pos=nil})
		end
	end
end

function SideNotifications:OnParticleUpdateEntity(particle)
	for _, info in pairs(self.twin_gate_info) do
		if particle["index"] == info["start_index"] then
			if particle["controlPoint"] == 0 then
				self.twin_gate_info[_]["start_pos"] = particle["position"]
			end
		elseif particle["index"] == info["end_index"] then
			if particle["controlPoint"] == 0 then
				self.twin_gate_info[_]["end_pos"] = particle["position"]
			end
		end
	end
end

function SideNotifications:OnParticleDestroy(particle)
	for _, info in pairs(self.twin_gate_info) do
		if particle["index"] == info["start_index"] or particle["index"] == info["end_index"] then
			if self.minimap_icons["twin_gate"] ~= nil and self.minimap_icons["twin_gate"][info["caster"]] ~= nil then
				self.minimap_icons["twin_gate"][info["caster"]] = nil
			end
			if info["time"]+self.twin_gate_channel_duration - CGameRules:GetGameTime() > 0.1 then
				self:SendNotification("twin_gate_cancel", {info["caster"], info["start_pos"], info["end_pos"]})
			end
			table.remove(self.twin_gate_info, _)
			break
		end
	end
end

function SideNotifications:OnUnitAnimation(animation)
	if string.find(animation["sequenceName"], "channel") ~= nil then
		local now = CGameRules:GetGameTime()
		for _, gate in pairs(table.copy(self.twin_gate_info)) do
			if math.abs(now-gate["time"]) > 0.1 then
				table.remove(self.twin_gate_info, _)
			end
		end
		if #self.twin_gate_info > 0 then
			local unit = CNPC:new(animation["unit"])
			if unit:GetTeamNum() ~= CPlayer:GetLocalTeam() then
				self.twin_gate_info[#self.twin_gate_info]["caster"] = unit
				if unit:IsHero() then
					local gate_info = self.twin_gate_info[#self.twin_gate_info]
					self:SendNotification("twin_gate", {gate_info["caster"], gate_info["start_pos"], gate_info["end_pos"]})
				end
			end
		end
	end
end

function SideNotifications:SendNotification(notification_type, notification_info)
	if notification_type == "twin_gate" then
		if table.length(notification_info) < 3 then return end
		if self.twin_gate_enable:Get() then
			local position = notification_info[3].y < 0 and "BOT" or "TOP"
			if not notification_info[1]:IsVisible() then
				CRenderer:DrawSideNotification({
					image1={
						path=GetHeroTopbarIconPath(notification_info[1]:GetUnitName()),
					},
					image2={
						path="panorama/images/spellicons/twin_gate_portal_warp_png.vtex_c",
						text={position},
					},
					type=CRenderer.SIDE_NOTIFICATION_MESSAGE_TELEPORT,
					sound=self.side_notifications_sound:Get() and CRenderer.SIDE_NOTIFICATION_SOUND_ALERT or CRenderer.SIDE_NOTIFICATION_SOUND_NONE,
					duration=self.twin_gate_channel_duration,
					unique_key="twin_gate_"..notification_info[1]:GetUnitName(),
				})
			end
			if self.minimap_icons["twin_gate"] == nil then
				self.minimap_icons["twin_gate"] = {}
			end
			self.minimap_icons["twin_gate"][notification_info[1]:GetUnitName()] = {CGameRules:GetGameTime() + self.twin_gate_channel_duration, notification_info[2], notification_info[3]}
		end
	elseif notification_type == "twin_gate_cancel" then
		if table.length(notification_info) < 3 then return end
		if self.twin_gate_enable:Get() then
			local position = notification_info[3].y < 0 and "BOT" or "TOP"
			CRenderer:DrawSideNotification({
				image1={
					path=GetHeroTopbarIconPath(notification_info[1]:GetUnitName()),
					text={"❌"},
					border=true,
				},
				image2={
					path="panorama/images/spellicons/twin_gate_portal_warp_png.vtex_c",
					text={position},
				},
				type=CRenderer.SIDE_NOTIFICATION_MESSAGE_TELEPORT,
				sound=CRenderer.SIDE_NOTIFICATION_SOUND_NONE,
				duration=3,
				unique_key="twin_gate_cancel"..notification_info[1]:GetUnitName(),
			})
		end
	end
end

return BaseScriptAPI(SideNotifications)