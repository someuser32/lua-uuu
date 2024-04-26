require("libraries/__init__")

local LotusHelper = class("LotusHelper")

function LotusHelper:initialize()
	self.path = {"Magma", "Utility", "Lotus Helper"}
	self.visual_path = {"Magma", "Info Screen", "Show Me More"}

	self.font = CRenderer:LoadFont("Verdana", 24, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.MEDIUM)

	self.lotus_pool_count = UILib:CreateCheckbox(self.visual_path, "Show Lotus Count", false)
	self.lotus_pool_count:SetIcon(CAbility:GetAbilityNameIconPath("item_famango"))

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.lotus_catcher = UILib:CreateKeybind({self.path, "Auto Take Lotus"}, "Key")
	self.lotus_catcher_auto = UILib:CreateSlider({self.path, "Auto Take Lotus"}, "Auto before min", -1, 99, 0)
	self.lotus_catcher_auto:SetIcon("~/MenuIcons/Enable/enable_ios.png")
	self.lotus_catcher_auto:SetTip("Enables auto take lotus without holding key\n(works only if time is near to spawn)\n(-1 for always, 0 for disable)")

	UILib:SetTabIcon({self.path, "Auto Take Lotus"}, "~/MenuIcons/pick.png")
	UILib:SetTabIcon(self.path, CAbility:GetAbilityNameIconPath("item_famango"))

	self.lotus_pools = {}
	for _, lotus_pool in pairs(CNPC:GetAll()) do
		if lotus_pool:IsLotusPool() then
			self.lotus_pools[lotus_pool:GetIndex()] = {lotus_pool, lotus_pool:GetAbsOrigin(), lotus_pool:GetModifier("modifier_passive_mango_tree")}
		end
	end

	self.lotus_replenish_time = 3*60

	self.listeners = {}
end

function LotusHelper:CatcherActive()
	if self.lotus_catcher:IsActive() then
		return true
	end
	local auto_time = self.lotus_catcher_auto:Get()
	if auto_time == 0 then
		return false
	elseif auto_time == 1 then
		return true
	end
	return math.floor(CGameRules:GetIngameTime() / 60) <= auto_time
end

function LotusHelper:OnUpdate()
	local tick = self:GetTick()
	if tick % 15 == 0 then
		for _, lotus_pool in pairs(CNPC:GetAll()) do
			if lotus_pool:IsLotusPool() then
				self.lotus_pools[lotus_pool:GetIndex()] = {lotus_pool, lotus_pool:GetAbsOrigin(), lotus_pool:GetModifier("modifier_passive_mango_tree")}
			end
		end
	end
	if tick % 3 == 0 then
		local gametime = CGameRules:GetIngameTime()
		local catching_pool = nil
		if self.enable:Get() and self:CatcherActive() then
			local time = CGameRules:GetIngameTime()
			local spawn_timing = time / self.lotus_replenish_time
			local should_catch = false
			if math.round(spawn_timing) == math.floor(spawn_timing) and time % self.lotus_replenish_time < 60 then
				should_catch = time % 60 < 3
			elseif math.round(spawn_timing) == math.ceil(spawn_timing) and time % self.lotus_replenish_time > (self.lotus_replenish_time-60) then
				should_catch = time % 60 > 57
			end
			if should_catch then
				local lotus_pools = table.values(self.lotus_pools)
				local localhero = CHero:GetLocal()
				local hero_pos = localhero:GetAbsOrigin()
				table.sort(lotus_pools, function(a, b)
					return (a[2]-hero_pos):Length2D() < (b[2]-hero_pos):Length2D()
				end)
				local lotus_pool = lotus_pools[1]
				if lotus_pool ~= nil then
					local range = (lotus_pool[2]-hero_pos):Length2D()
					if range < 550 then
						local lotuses = lotus_pool[3]:GetStackCount()
						if lotuses > 0 and not localhero:IsChannellingAbility() then
							localhero:PickupLotus(lotus_pool[1])
						end
						catching_pool = lotus_pool[1]:GetIndex()
					end
				end
			end
		end
		for _, lotus_pool in pairs(self.lotus_pools) do
			self.lotus_pools[_][4] = _ == catching_pool
		end
	end
end

function LotusHelper:OnDraw()
	if self.lotus_pool_count:Get() then
		for _, lotus_info in pairs(self.lotus_pools) do
			local x, y, visible = CRenderer:WorldToScreen(lotus_info[2] + Vector(0, 0, 72))
			if visible then
				if lotus_info[4] then
					CRenderer:SetDrawColor(175, 255, 175, 255)
				else
					CRenderer:SetDrawColor(150, 150, 150, 255)
				end
				CRenderer:DrawImageCentered(CRenderer:GetOrLoadImage(CAbility:GetAbilityNameIconPath("item_famango")), x, y, 42, 42)
				local text = lotus_info[3] ~= nil and tostring(lotus_info[3]:GetStackCount()) or "1"
				local width, height = CRenderer:GetTextSize(self.font, text)
				CRenderer:SetDrawColor(255, 255, 255, 255)
				CRenderer:DrawText(self.font, x - width / 2, y - height / 2, text)
				-- CRenderer:SetDrawColor(255, 255, 255, 255)
				-- CRenderer:DrawText(self.font, x - width / 2, y - height / 2, text)
			end
		end
	end
end

return BaseScriptAPI(LotusHelper)