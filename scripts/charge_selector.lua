require("libraries/__init__")

local ChargeSelector = class("ChargeSelector")

function ChargeSelector:initialize()
	self.path = {"Magma", "Utility", "Charge Selector"}

	self.enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.select_bind = UILib:CreateKeybind(self.path, "Select key", true)
	self.select_bind:SetTip("Selects unit under Spirit Breaker's charge")

	self.select_filter_only_heroes = UILib:CreateCheckbox({self.path, "Selection filter"}, "Only heroes", false)
	self.select_filter_only_heroes:SetIcon("~/MenuIcons/people.png")
	self.select_filter_only_own = UILib:CreateCheckbox({self.path, "Selection filter"}, "Only own units", true)
	self.select_filter_only_own:SetTip("Despite of this option, you cannot \"query unit\" (aka select units when you cannot control them)")
	self.select_filter_only_own:SetIcon("~/MenuIcons/helmet_g.png")

	self.auto_save_enable = UILib:CreateCheckbox({self.path, "Auto Save Summons"}, "Enable", false)
	self.auto_save_enable:SetTip("If Spirit Breaker charges on your mass summon (like Broodmother spiders)")

	UILib:SetTabIcon({self.path, "Selection filter"}, "~/MenuIcons/target_alt.png")
	UILib:SetTabIcon(self.path, CAbility:GetAbilityNameIconPath("spirit_breaker_charge_of_darkness"))

	self.charge_modifier = "modifier_spirit_breaker_charge_of_darkness_vision"

	self.listeners = {}
end

function ChargeSelector:OnUpdate()
	if not self.enable then return end
	local tick = self:GetTick()
	if self.select_bind:IsActiveOnce() then
		local units = self.select_filter_only_heroes:Get() and CHero:GetAllies() or CNPC:GetAll()
		local localplayer = CPlayer:GetLocal()
		local localplayerid = CPlayer:GetLocalID()
		for _, unit in pairs(units) do
			if unit:HasModifier(self.charge_modifier) and unit:IsControllableByPlayer(localplayerid) and (not self.select_filter_only_own:Get() or unit:RecursiveGetOwner() == localplayer) then
				CPlayer:SetSelectedUnit(unit)
				break
			end
		end
	end
end

function ChargeSelector:IsMassSummon(unit)
	if unit:IsHero() or not unit:HasModifier("modifier_kill") then
		return false
	end
	return true
end

return BaseScriptAPI(ChargeSelector)