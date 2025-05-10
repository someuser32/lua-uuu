require("xlib/__init__")

local LotusPickup = {}

function LotusPickup:Init()
	self.menu = Menu.Create("General", "Main", "Snatcher")

	self.menu_main = self.menu:Create("xScripts")
	self.menu_main:Icon("\u{e12e}")

	self.menu_script = self.menu_main:Create("Lotus")

	self.enable = self.menu_script:Switch("Enable", false)
	self.enable:Icon("\u{f00c}")
	self.enable:ToolTip("Pickups only if time is near to spawn")

	self.lotus_catcher_auto = self.menu_script:Slider("Take before min", 0, 99, 0)
	self.lotus_catcher_auto:Icon("\u{e3d6}")
	self.lotus_catcher_auto:ToolTip("Set 0 for always")

	self.enable:SetCallback(function(widget)
		local enabled = widget:Get()
		self.lotus_catcher_auto:Disabled(not enabled)
	end, true)

	self.lotus_pools = {}
	for _, lotus_pool in pairs(NPCs.GetAll(Enum.UnitTypeFlags.TYPE_STRUCTURE)) do
		if Entity.IsLotusPool(lotus_pool) then
			self.lotus_pools[Entity.GetIndex(lotus_pool)] = {lotus_pool, Entity.GetAbsOrigin(lotus_pool), NPC.GetModifier(lotus_pool, "modifier_passive_mango_tree")}
		end
	end

	self.lotus_replenish_time = 3*60
end

function LotusPickup:CatcherActive()
	if not self.enable:Get() then return false end
	local auto_time = self.lotus_catcher_auto:Get()
	if auto_time == 0 then
		return true
	end
	return math.floor(GameRules.GetIngameTime() / 60) <= auto_time
end

function LotusPickup:OnUpdate()
	local tick = Tick()
	if tick % 100 == 0 then
		for _, lotus_pool in pairs(NPCs.GetAll(Enum.UnitTypeFlags.TYPE_STRUCTURE)) do
			if Entity.IsLotusPool(lotus_pool) then
				self.lotus_pools[Entity.GetIndex(lotus_pool)] = {lotus_pool, Entity.GetAbsOrigin(lotus_pool), NPC.GetModifier(lotus_pool, "modifier_passive_mango_tree")}
			end
		end
	end
	if tick % 3 == 0 then
		if self:CatcherActive() then
			local time = GameRules.GetIngameTime()
			local spawn_timing = time / self.lotus_replenish_time
			local should_catch = false
			if math.round(spawn_timing) == math.floor(spawn_timing) and time % self.lotus_replenish_time < 60 then
				should_catch = time % 60 < 3
			elseif math.round(spawn_timing) == math.ceil(spawn_timing) and time % self.lotus_replenish_time > (self.lotus_replenish_time-60) then
				should_catch = time % 60 > 58
			end
			if should_catch then
				local lotus_pools = table.values(self.lotus_pools)
				local localhero = Heroes.GetLocal()
				local hero_pos = Entity.GetAbsOrigin(localhero)
				table.sort(lotus_pools, function(a, b)
					return (a[2]-hero_pos):Length2D() < (b[2]-hero_pos):Length2D()
				end)
				local lotus_pool = lotus_pools[1]
				if lotus_pool ~= nil then
					local range = (lotus_pool[2]-hero_pos):Length2D()
					if range < 550 then
						local lotuses = Modifier.GetStackCount(lotus_pool[3])
						if lotuses > 0 and not NPC.IsChannellingAbility(localhero) then
							NPC.PickupLotus(localhero, lotus_pool[1])
						end
					end
				end
			end
		end
	end
end

return BaseScript(LotusPickup)