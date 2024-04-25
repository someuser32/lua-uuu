local CBaseScriptAPI = class("BaseScriptAPI")

function CBaseScriptAPI:initialize()
	self.instances = {}
	self.ignore_last_used = {}
	self.ignore_cast_phase = {}
	self.inventories_cache = {}
	self.visibility_cache = {}
	self.visibility_cache_pre = {}
	self.tick = 0
	self.draw_tick = 0
	self.hero_text_font = CRenderer:LoadFont("Verdana", 16, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.MEDIUM)
end

function CBaseScriptAPI:register_instance(instance)
	table.insert(self.instances, instance)
	local this = self
	instance.instance.WasHeroVisible = instance.instance.WasHeroVisible or function(self, hero)
		local visible = this.visibility_cache_pre[hero:GetIndex()]
		return (visible ~= nil and {visible} or {false})[1]
	end
	instance.instance.GetTick = instance.instance.GetTick or function(self)
		return this.tick
	end
	instance.instance.GetDrawTick = instance.instance.GetDrawTick or function(self)
		return this.draw_tick
	end
end

function CBaseScriptAPI:callback(source, name, ...)
	if source ~= self.instances[1] then return end
	-- if name ~= "OnDraw" and name ~= "OnFrame" and name ~= "OnUpdate" and name ~= "OnPrepareUnitOrders" then
	-- 	print(name)
	-- 	DeepPrintTable({...})
	-- end
	if self[name] ~= nil then
		return self[name](self, ...)
	end
end

function CBaseScriptAPI:get_listeners()
	local listeners = {}
	for _, instance in pairs(self.instances) do
		if type(instance.instance.listeners) == "table" then
			for event, enabled in pairs(instance.instance.listeners) do
				if enabled then
					listeners[event] = true
				end
			end
		end
	end
	return listeners
end

function CBaseScriptAPI:get_listener_callbacks_instances()
	local callback_names = {
		"OnNPCUsedAbility",
		"OnNPCPhaseAbility",
		"OnNPCLostItem",
	}
	local instances = {}
	for _, instance in pairs(self.instances) do
		for _, callback_name in pairs(callback_names) do
			if type(instance.instance[callback_name]) == "function" then
				if instances[callback_name] == nil then
					instances[callback_name] = {}
				end
				table.insert(instances[callback_name], instance.instance)
			end
		end
	end
	return instances
end

function CBaseScriptAPI:fire_listener_callback(callback_name, ...)
	local callbacks = self:get_listener_callbacks_instances()
	if callbacks[callback_name] ~= nil then
		for _, instance in pairs(callbacks[callback_name]) do
			instance[callback_name](instance, ...)
		end
	end
end

function CBaseScriptAPI:CheckAbilityUsageHeroAbility(ability, callbacks)
	if ability:IsAttributes() or (not ability:IsItem() and ability:GetLevel() == 0) or ability:IsHidden() or ability:IsPassive() then return end
	if callbacks["OnNPCUsedAbility"] ~= nil then
		local last_used = ability:IsUsed()
		if last_used then
			if not table.contains(self.ignore_last_used, ability.ent) then
				self:fire_listener_callback("OnNPCUsedAbility", ability)
				table.insert(self.ignore_last_used, ability.ent)
			end
		elseif table.contains(self.ignore_last_used, ability.ent) then
			table.removeElement(self.ignore_last_used, ability.ent)
		end
	end
	if callbacks["OnNPCPhaseAbility"] ~= nil then
		local in_phase = ability:IsInAbilityPhase()
		if in_phase then
			if not table.contains(self.ignore_cast_phase, ability.ent) then
				self:fire_listener_callback("OnNPCPhaseAbility", ability)
				table.insert(self.ignore_cast_phase, ability.ent)
			end
		elseif table.contains(self.ignore_cast_phase, ability.ent) then
			table.removeElement(self.ignore_cast_phase, ability.ent)
		end
	end
end

function CBaseScriptAPI:CheckAbilityUsageHero(hero, entindex, callbacks)
	if not hero:IsWaitingToSpawn() and hero:IsHero() and not hero:IsIllusion() then
		local inventory = hero:GetInventory()
		for _, ability in pairs(table.combine(table.values(hero:GetAbilities(1)), table.values(inventory))) do
			self:CheckAbilityUsageHeroAbility(ability, callbacks)
		end
		if self.inventories_cache[entindex] ~= nil then
			for slot, item_info in pairs(self.inventories_cache[entindex]) do
				local item = CItem:new(item_info[1])
				local item_name = item_info[2]
				local slot = hero:GetItemSlot(item)
				local container = item:GetContainer()
				if slot == nil and container == nil then
					if string.find(item_name, "item_ward") == nil or hero:GetItemByName("item_ward_dispenser") == nil then
						if callbacks["OnNPCLostItem"] ~= nil then
							self:fire_listener_callback("OnNPCLostItem", item, hero, {GetName=item_name})
						end
					end
				end
			end
		end
		self.inventories_cache[entindex] = table.map(inventory, function(slot, item) return {item.ent, item:GetName()} end)
	elseif self.inventories_cache[entindex] ~= nil then
		self.inventories_cache[entindex] = nil
	end
end

function CBaseScriptAPI:OnFrame()
	Timers:Think()
end

function CBaseScriptAPI:OnUpdate()
	if self.tick % 2 == 0 then
		local listeners = self:get_listeners()
		if #table.values(listeners) > 0 then
			local callbacks = self:get_listener_callbacks_instances()
			local localTeam = CPlayer:GetLocalTeam()
			local heroListeners = {"AbilityUsageHeroEnemy", "AbilityUsageHeroAlly", "HeroVisibilityEnemy", "HeroVisibilityAlly"}
			local NPCListeners = {"AbilityUsageNPCEnemy", "AbilityUsageNPCAlly"}
			if table.any(table.map(heroListeners, function(_, name) return listeners[name] == true end)) and self.tick % (2*3) == 0 or self.tick % (2*5) == 0 then
				for _, hero in pairs(CHero:GetAll()) do
					local entindex = hero:GetIndex()
					local is_ally = hero:GetTeamNum() == localTeam
					if self.tick % (2*3) == 0 then
						if (listeners["AbilityUsageHeroEnemy"] == true and not is_ally) or (listeners["AbilityUsageHeroAlly"] == true and is_ally) then
							self:CheckAbilityUsageHero(hero, entindex, callbacks)
						end
					end
					if self.tick % (2*5) == 0 then
						if (listeners["HeroVisibilityEnemy"] == true and not is_ally) or (listeners["HeroVisibilityAlly"] == true and is_ally) then
							self.visibility_cache_pre[entindex] = self.visibility_cache[entindex] == true
							self.visibility_cache[entindex] = is_ally and hero:IsVisibleToEnemies() or hero:IsVisible()
						end
					end
				end
			end
			if table.any(table.map(NPCListeners, function(_, name) return listeners[name] == true end)) and self.tick % (2*5) == 0 then
				for _, npc in pairs(CNPC:GetAll()) do
					if (listeners["AbilityUsageNPCEnemy"] == true and not is_ally) or (listeners["AbilityUsageNPCAlly"] == true and is_ally) then
						if not npc:IsWaitingToSpawn() and npc:IsVisible() then
							local inventory = npc:GetInventory()
							for _, ability in pairs(table.combine(table.values(npc:GetAbilities(2)), table.values(inventory))) do
								self:CheckAbilityUsageHeroAbility(ability, callbacks)
							end
						end
					end
				end
			end
		end
	end
	self.tick = self.tick + 1
end

function CBaseScriptAPI:get_hero_texts()
	local texts = {}
	for _, instance in pairs(self.instances) do
		if type(instance.instance.GetHeroTexts) == "function" then
			local instance_texts = instance.instance.GetHeroTexts(instance.instance)
			if type(instance_texts) == "table" then
				for _, text in pairs(instance_texts) do
					table.insert(texts, text)
				end
			end
		end
	end
	return texts
end

function CBaseScriptAPI:OnDraw()
	self.draw_tick = self.draw_tick + 1
	local texts = self:get_hero_texts()
	-- DeepPrintTable(texts)
	if #texts > 0 then
		local hero = CHero:GetLocal()
		local offset_z = hero:GetHealthBarOffset()
		local x, y, visible = CRenderer:WorldToScreen(hero:GetAbsOrigin() + Vector(0, 0, offset_z))
		if visible then
			for _, text in pairs(texts) do
				local width, height = CRenderer:GetTextSize(self.hero_text_font, text[1])
				CRenderer:SetDrawColor(table.unpack(text[2] or {255, 255, 255, 255}))
				CRenderer:DrawText(self.hero_text_font, x - width / 2, y - offset_z / 4 - height / 2 - ((height + 2) * (_ - 1)), text[1])
			end
		end
	end
end

function CBaseScriptAPI:OnPrepareUnitOrders(order)
	if order["order"] == Enum.UnitOrder.DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION and order["target"] == nil and order["ability"] == nil and order["npc"] == nil and order["showEffects"] == false then
		return false
	end
	return true
end

local BaseScriptAPI = CBaseScriptAPI:new()

return function(basescript)
	if type(basescript) ~= "table" or type(basescript.new) ~= "function" then return end

	local ScriptAPI = {instance=basescript:new()}

	local callbacks = {
		"OnDraw",
		"OnFrame",
		"OnPreUpdate",
		"OnUpdate",
		"OnUnitAnimation",
		"OnUnitAnimationEnd",
		"OnUnitAddGesture",
		"OnProjectile",
		"OnProjectileLoc",
		"OnLinearProjectileCreate",
		"OnLinearProjectileDestroy",
		"OnParticleCreate",
		"OnParticleUpdate",
		"OnParticleUpdateEntity",
		"OnParticleUpdateFallback",
		"OnParticleDestroy",
		"OnEntityCreate",
		"OnEntityDestroy",
		"OnEntityHurt",
		"OnEntityKilled",
		"OnFireEventClient",
		"OnModifierCreate",
		"OnModifierDestroy",
		"OnStartSound",
		"OnPrepareUnitOrders",
		"OnMenuOptionChange",
		"OnGameStart",
		"OnGameEnd",
		"OnScriptLoad",
		"OnScriptUnload",
		"OnChatEvent",
		"OnOverHeadEvent",
		"OnGCMessage",
		"OnSendNetMessage",
		"OnReceivedNetMessage",
		"OnSetDormant",
	}

	for _, callback in pairs(callbacks) do
		ScriptAPI[callback] = function(...)
			local args = {...}
			local status, base_result = pcall(function() return BaseScriptAPI:callback(ScriptAPI, callback, table.unpack(args)) end)
			if status and base_result ~= nil then
				return base_result
			elseif not status then
				print("ERROR in", callback, base_result)
			end
			if ScriptAPI.instance[callback] ~= nil then
				return ScriptAPI.instance[callback](ScriptAPI.instance, ...)
			end
		end
	end

	BaseScriptAPI:register_instance(ScriptAPI)

	return ScriptAPI
end