---@class WisdomInfo
---@field wisdom_shrines {origin: Vector, has: boolean, fx: number?}[]
---@field particle_indexes table<number, {entity: userdata, current: number, max: number}>
local WisdomInfo = {
	wisdom_initial = 7*60,
	wisdom_interval = 7*60,

	progress_thickness = 4,
	icon_size = 32,
	icon_bg_color = Color(60, 60, 100, 128),
	progress_bg_color = Color(15, 20, 20, 200),

	notification_sounds = {
		{"No Sound", nil},
		{"Ping (default)", "sounds/ui/ping.vsnd"},
		{"Ping (alternative)", "sounds/ui/ping_warning.vsnd"},
		{"Deny", "sounds/ui/last_hit.vsnd"},
		{"Maim", "sounds/items/maim.vsnd"},
		{"Yoink", "sounds/ui/yoink.vsnd"},
		{"Stacked", "sounds/ui/stacked.vsnd"},
	},

	wisdom_shrines = {},
	particle_indexes = {},
	wisdom_spawns = 0,
	last_notification = 0,
	last_cache_update = 0,

	match_id = GameRules.GetMatchID(),
}

---@return number
local function GetDOTATime()
	if GameRules.GetGameState() <= Enum.GameState.DOTA_GAMERULES_STATE_PRE_GAME then
		return 0
	end

	return GameRules.GetGameTime() - GameRules.GetGameStartTime()
end

function WisdomInfo:Init()
	self.menu = Menu.Create("Info Screen", "Main", "Show Me More")

	self.menu_main = self.menu:Create("Main")

	self.menu_script = self.menu_main:Create("World Settings")

	self.enable = self.menu_script:Find("Enable") --[[@as CMenuSwitch]]

	self.wisdom_info = self.menu_script:Switch("Wisdom Info", false, "~/Runes/wisdom.png")
	self.wisdom_info:Disabled(not self.enable:Get())

	self.menu_notifications = Menu.Create("Info Screen", "Main", "Notifications")

	self.menu_notifications_main = self.menu_notifications:Create("Main")

	self.menu_notifications_global_settings = self.menu_notifications_main:Create("Global Settings")
	self.menu_notifications_notification_settings = self.menu_notifications_main:Create("Notification Settings")

	self.enable_notifications = self.menu_notifications_global_settings:Find("Enable") --[[@as CMenuSwitch]]

	self.notifications = self.menu_notifications_notification_settings:MultiCombo("Wisdom Rune", {"Side", "Local Chat"}, {})
	self.notifications:Image("~/Runes/wisdom.png")
	self.notifications:Disabled(not self.enable_notifications:Get())
	self.notifications_gear = self.notifications:Gear("Sounds")
	self.notifications_gear_sound = self.notifications_gear:Combo("Wisdom Sound", table.map(self.notification_sounds, function(_, sound) return sound[1] end), 0)
	self.notifications_gear_sound:Icon("\u{f001}")

	local now = GameRules.GetGameTime()
	local dota_time = GetDOTATime()
	local cache_last_update = Config.ReadInt("xwisdom_info_cache", "last_update", 0)
	local is_valid_cache = Config.ReadInt("xwisdom_info_cache", "match_id", 0) == self.match_id and now > cache_last_update
	local is_up_to_date_cache = now > cache_last_update and now - cache_last_update < 30

	self.wisdom_spawns = dota_time > self.wisdom_initial and math.floor(math.floor(dota_time - self.wisdom_initial) / self.wisdom_interval) + 1 or 0

	for _, npc in pairs(NPCs.GetAll(Enum.UnitTypeFlags.TYPE_STRUCTURE)) do
		if NPC.GetUnitName(npc) == "npc_dota_xp_fountain" then
			self.wisdom_shrines[npc] = {origin=Entity.GetAbsOrigin(npc), has=false}
			if is_valid_cache then
				if is_up_to_date_cache then
					if Config.ReadInt("xwisdom_info_cache", "shrine_"..self:GetShrineSide(npc), 0) == 1 then
						self.wisdom_shrines[npc].has = true
					end
				end
			else
				if dota_time > self.wisdom_initial then
					self.wisdom_shrines[npc].has = true
				end
			end
		end
	end
end

function WisdomInfo:OnWisdomCapturing(shrine)
	if self.enable_notifications:Get() then
		local localHero = Heroes.GetLocal()
		local localHeroPos = Entity.GetAbsOrigin(localHero)

		if not FogOfWar.IsPointVisible(self.wisdom_shrines[shrine].origin) or (localHeroPos - self.wisdom_shrines[shrine].origin):Length2D() > 1500 then
			local now = GameRules.GetGameTime()
			local side = self.wisdom_shrines[shrine].origin.x > 0 and "Right" or "Left"

			if self.notifications:Get("Side") then
				Notification({
					id="wisdom_info_capture_"..side,
					duration=5,
					timer=3,
					primary_text="Wisdom Rune",
					primary_image=Render.LoadImage("~/Runes/wisdom.png"),
					secondary_text="\a"..Menu.Style("primary"):ToHex():sub(2, 9).."F".. side .."\aDEFAULT shrine is capturing",
					position=self.wisdom_shrines[shrine].origin,
				})
			end

			if now - self.last_notification > 5 then
				if self.notifications:Get("Local Chat") then
					Chat.Print("ConsoleChat", "<font color=\"#FFFFFF\"><img class=\"CrestIcon\" src=\"s2r://panorama/images/emoticons/xp_rune_png.vtex\"/> <font color=\"" .. Menu.Style("primary"):ToHex() .. "\">".. side .."</font> shrine is capturing <img class=\"CrestIcon\" src=\"s2r://panorama/images/emoticons/xp_rune_png.vtex\"/></font>")
				end
			end

			local sound = self.notification_sounds[self.notifications_gear_sound:Get()+1][2]
			if sound then
				local volume = Menu.Find("SettingsHidden", "", "", "", "Visual", "Notifications", "Notifications", "Sound Volume") --[[@as CMenuSliderFloat]]
				Engine.PlayVol(sound, volume:Get())
			end

			self.last_notification = now
		end
	end
end

function WisdomInfo:OnWisdomCaptured(shrine)
	if self.enable_notifications:Get() then
		local localHero = Heroes.GetLocal()
		local localHeroPos = Entity.GetAbsOrigin(localHero)

		if not FogOfWar.IsPointVisible(self.wisdom_shrines[shrine].origin) or (localHeroPos - self.wisdom_shrines[shrine].origin):Length2D() > 1500 then
			local side = self.wisdom_shrines[shrine].origin.x > 0 and "Right" or "Left"

			if self.notifications:Get("Side") then
				Notification({
					id="wisdom_info_captured_"..side,
					duration=5,
					timer=3,
					primary_text="Wisdom Rune",
					primary_image=Render.LoadImage("~/Runes/wisdom.png"),
					secondary_text="\a"..Menu.Style("primary"):ToHex():sub(2, 9).."F".. side .."\aDEFAULT shrine captured",
					position=self.wisdom_shrines[shrine].origin,
				})
			end

			if self.notifications:Get("Local Chat") then
				Chat.Print("ConsoleChat", "<font color=\"#FFFFFF\"><img class=\"CrestIcon\" src=\"s2r://panorama/images/emoticons/xp_rune_png.vtex\"/> <font color=\"" .. Menu.Style("primary"):ToHex() .. "\">".. side .."</font> shrine captured <img class=\"CrestIcon\" src=\"s2r://panorama/images/emoticons/xp_rune_png.vtex\"/></font>")
			end

			local sound = self.notification_sounds[self.notifications_gear_sound:Get()+1][2]
			if sound then
				local volume = Menu.Find("SettingsHidden", "", "", "", "Visual", "Notifications", "Notifications", "Sound Volume") --[[@as CMenuSliderFloat]]
				Engine.PlayVol(sound, volume:Get())
			end
		end
	end
end

function WisdomInfo:OnUpdate()
	local now = GameRules.GetGameTime()
	local dota_time = GetDOTATime()

	if dota_time > self.wisdom_initial and dota_time - self.wisdom_initial < 1 and self.wisdom_spawns <= 0 then
		for entity, info in pairs(self.wisdom_shrines) do
			self.wisdom_shrines[entity].has = true
			self:UpdateWisdomShrine(entity, true)
		end

		self.wisdom_spawns = self.wisdom_spawns + 1
	elseif dota_time > self.wisdom_initial then
		local cycle = math.floor(math.floor(dota_time - self.wisdom_initial) / self.wisdom_interval) + 1
		if cycle > self.wisdom_spawns then
			for entity, info in pairs(self.wisdom_shrines) do
				self.wisdom_shrines[entity].has = true
				self:UpdateWisdomShrine(entity, true)
			end

			self.wisdom_spawns = cycle
		end
	end

	if now > 0 and now - self.last_cache_update > 5 then
		Config.WriteInt("xwisdom_info_cache", "last_update", math.floor(now))
		self.last_cache_update = now
	end
end

function WisdomInfo:GetShrineSide(shrine)
	return self.wisdom_shrines[shrine].origin.x > 0 and "Right" or "Left"
end

function WisdomInfo:UpdateWisdomShrine(shrine, has)
	local now = GameRules.GetGameTime()

	Config.WriteInt("xwisdom_info_cache", "shrine_"..self:GetShrineSide(shrine), has and 1 or 0)
	Config.WriteInt("xwisdom_info_cache", "last_update", math.floor(now))
	Config.WriteInt("xwisdom_info_cache", "match_id", self.match_id)

	self.last_cache_update = now
end

function WisdomInfo:OnDraw()
	if not self.enable:Get() then
		return
	end

	if self.wisdom_info:Get() then
		for entity, info in pairs(self.wisdom_shrines) do
			local xy, visible = Render.WorldToScreen(info.origin + Vector(0, 0, 450))

			if visible then
				local particle = self.particle_indexes[info.fx]
				local progress = particle ~= nil and particle.current / particle.max or 0

				Render.FilledCircle(xy, self.icon_size, self.icon_bg_color)
				Render.ImageCentered(Render.LoadImage("~/Runes/wisdom.png"), xy, Vec2(self.icon_size, self.icon_size), Color())
				if not info.has then
					Render.Line(xy + Vec2(-self.icon_size / 2, -self.icon_size / 2), xy + Vec2(self.icon_size / 2, self.icon_size / 2), Color(255, 0, 0), self.progress_thickness)
					Render.Line(xy + Vec2(self.icon_size / 2, -self.icon_size / 2), xy + Vec2(-self.icon_size / 2, self.icon_size / 2), Color(255, 0, 0), self.progress_thickness)
				end
				Render.Circle(xy, self.icon_size, self.progress_bg_color, self.progress_thickness)
				Render.Circle(xy, self.icon_size, Menu.Style("indication_active"), self.progress_thickness, 270, progress)
			end
		end
	end
end

---@param particle OnParticleCreateParticle
function WisdomInfo:OnParticleCreate(particle)
	if particle.fullName == "particles/base_static/experience_shrine_active.vpcf" then
		self.particle_indexes[particle.index] = {entity=particle.entity, max=0, current=0}

		if self.wisdom_shrines[particle.entity] == nil then
			self.wisdom_shrines[particle.entity] = {}
		end
		self.wisdom_shrines[particle.entity].fx = particle.index
		self.wisdom_shrines[particle.entity].has = true

		self:OnWisdomCapturing(particle.entity)
	end
end

---@param particle OnParticleUpdateParticle
function WisdomInfo:OnParticleUpdate(particle)
	if self.particle_indexes[particle.index] ~= nil then
		if particle.controlPoint == 0 then
			local entity = self.particle_indexes[particle.index].entity

			if self.wisdom_shrines[entity] == nil then
				self.wisdom_shrines[entity] = {}
			end
			if self.wisdom_shrines[entity].origin == nil then
				self.wisdom_shrines[entity].origin = particle.position
			end
		elseif particle.controlPoint == 1 then
			self.particle_indexes[particle.index].max = particle.position.x
			self.particle_indexes[particle.index].current= particle.position.y
		end
	end
end

---@param particle OnParticleDestroyParticle
function WisdomInfo:OnParticleDestroy(particle)
	if self.particle_indexes[particle.index] ~= nil then
		local entity = self.particle_indexes[particle.index].entity

		if self.particle_indexes[particle.index]["max"] - self.particle_indexes[particle.index]["current"] < 1 then
			self.wisdom_shrines[entity].has = false
			self:UpdateWisdomShrine(entity, false)
			self:OnWisdomCaptured(entity)
		else
			self.wisdom_shrines[entity].has = true
			self:UpdateWisdomShrine(entity, true)
		end

		self.wisdom_shrines[entity].fx = nil
		self.particle_indexes[particle.index] = nil
	end
end

local script = {}

setmetatable(script, {
	__index = function(_, key)
		local v = WisdomInfo[key]

		if type(v) == "function" then
			return function(firstArg, ...)
				if firstArg == script then
					return v(WisdomInfo, ...)
				else
					return v(WisdomInfo, firstArg, ...)
				end
			end
		else
			return v
		end
	end,

	__newindex = function(_, key, val)
		WisdomInfo[key] = val
	end,
})

if script.Init ~= nil then
	script:Init()
end

return script