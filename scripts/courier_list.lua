require("libraries/__init__")

local CourierList = class("CourierList")

function CourierList:initialize()
	self.path = {"Magma", "Info Screen", "Couriers"}

	self.font = CRenderer:LoadFont("MS Reference Sans Serif", 13, Enum.FontCreate.FONTFLAG_ANTIALIAS + Enum.FontCreate.FONTFLAG_OUTLINE, Enum.FontWeight.MEDIUM)

	self.hero_icon_size = 16
	self.courier_icon_size = 16

	local max_text_width, max_text_height = CRenderer:GetTextSize(self.font, "999:99")
	self.max_width = self.hero_icon_size + 2 + max_text_width + 4
	self.max_height = self.courier_icon_size + self.hero_icon_size * 5 + 4

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.move_key = UILib:CreateKeybind({self.path, "Panel"}, "Move key", Enum.ButtonCode.KEY_LCONTROL)
	self.move_key:SetIcon("~/MenuIcons/drag_def.png")
	self.reset_panel_positions = UILib:CreateButton({self.path, "Panel"}, "Reset positions", function()
		local screen_width, screen_height = CRenderer:GetScreenSize()
		CConfig:WriteInt("magma_courier_list", tostring("panel_x"), math.floor(350*screen_width/1920))
		CConfig:WriteInt("magma_courier_list", tostring("panel_y"), math.floor(980*screen_height/1080))
	end)

	UILib:SetTabIcon({self.path, "Panel"}, "~/MenuIcons/panel_def.png")

	UILib:SetTabIcon(self.path, "~/MenuIcons/Dota/Courier_Donkey.png")

	self.listeners = {}

	self.enemies = {}
	self.courier_respawns = {}

	self:UpdateCouriersInfo()
end

function CourierList:OnMenuOptionChange(option, oldValue, newValue)
	if option == self.enable.menu_option then
		if self.enable:Get() then
			self:UpdateCouriersInfo()
		end
	end
end

function CourierList:DrawPanel(position)
	local max_height = self.courier_icon_size + self.hero_icon_size * math.max(5, #self.enemies) + 4
	local now = CGameRules:GetGameTime()
	CRenderer:SetDrawColor(0, 0, 0, 50)
	CRenderer:DrawFilledRect(position[1], position[2], self.max_width, max_height)
	CRenderer:SetDrawColor(10, 10, 10, 125)
	CRenderer:DrawOutlineRect(position[1], position[2], self.max_width, max_height)
	CRenderer:SetDrawColor(255, 255, 255, 255)
	CRenderer:DrawImageCentered(CRenderer:GetOrLoadImage("~/MenuIcons/Dota/Courier_Donkey.png"), position[1]+(self.max_width-4)/2, position[2]+self.courier_icon_size/2, self.courier_icon_size, self.courier_icon_size)
	for _, enemy_data in pairs(self.enemies) do
		local playerID, hero_name = table.unpack(enemy_data)
		local respawn_time = math.floor(math.max((self.courier_respawns[playerID] or 0) - now, 0))
		local x, y = position[1]+2, position[2]+2+self.courier_icon_size+self.hero_icon_size*(_-1)
		CRenderer:SetDrawColor(255, 255, 255, 255)
		CRenderer:DrawImageCentered(CRenderer:GetOrLoadImage(GetHeroIconPath(hero_name)), x+self.hero_icon_size/2, y+self.hero_icon_size/2, self.hero_icon_size, self.hero_icon_size)
		local text = respawn_time > 0 and ToClockMin(respawn_time) or "ALIVE"
		CRenderer:DrawTextCentered(self.font, x+self.hero_icon_size+2+(self.max_width-self.hero_icon_size-2-4)/2, y+self.hero_icon_size/2, text)
	end
end

function CourierList:DrawPanelWithDrag()
	local screen_width, screen_height = CRenderer:GetScreenSize()
	local should_move = CInput:IsKeyDown(Enum.ButtonCode.KEY_MOUSE1) and self.move_key:IsActive()
	local x, y = CConfig:ReadInt("magma_courier_list", tostring("panel_x"), math.floor(350*screen_width/1920)), CConfig:ReadInt("magma_courier_list", tostring("panel_y"), math.floor(980*screen_height/1080))
	if should_move then
		local cursor_position = {CInput:GetCursorPos()}
		local bounds_min, bounds_max = {x, y}, {x+self.max_width, y+self.max_height}
		if ((cursor_position[1] > bounds_min[1] and cursor_position[1] < bounds_max[1]) and (cursor_position[2] > bounds_min[2] and cursor_position[2] < bounds_max[2])) or self.mouse_previous_position ~= nil then
			if self.mouse_previous_position ~= nil then
				local dt = {cursor_position[1] - self.mouse_previous_position[1], cursor_position[2] - self.mouse_previous_position[2]}
				x, y = math.floor(math.min(math.max(x+dt[1], 0), screen_width-self.max_width)), math.floor(math.min(math.max(y+dt[2], 0), screen_height-self.max_height))
				CConfig:WriteInt("magma_courier_list", tostring("panel_x"), x)
				CConfig:WriteInt("magma_courier_list", tostring("panel_y"), y)
			end
			self.mouse_previous_position = cursor_position
		end
	else
		self.mouse_previous_position = nil
	end
	self:DrawPanel({x, y})
end

function CourierList:OnUpdate()
	if not self.enable:Get() then return end
	local tick = self:GetTick()
	if tick % 100 == 0 then
		self:UpdateCouriersInfo()
	end
end

function CourierList:OnDraw()
	if not self.enable:Get() then return end
	self:DrawPanelWithDrag()
end

function CourierList:UpdateCouriersInfo()
	if not self.enable:Get() then return end
	self.enemies = table.values(table.map(CHero:GetEnemiesHeroNames(), function(playerID, hero_name) return {playerID, hero_name} end))
	for _, courier in pairs(CCourier:GetAll()) do
		local player = courier:GetOwner()
		if player then
			self.courier_respawns[player:GetPlayerID()] = courier:GetRespawnTime()
		end
	end
end

function CourierList:OnCourierLostEvent(killerid, teamnumber, bounty_gold)
	if CPlayer:GetLocalTeam() == teamnumber then return end
	self:UpdateCouriersInfo()
end

return BaseScriptAPI(CourierList)