local BaseScriptAPI = {
	uscripts = {},
	tick = 0,
	draw_tick = 0,
	cache = {
		inventory = {},
		items = {},
		visibility = {},
		visibility_pre = {},
		particles = {},
		cast = {},
		phase = {},
	},
	_ = {
		dt_update = GameRules.GetGameTime(),
		dt_draw = GameRules.GetGameTime(),
	},
}

---@alias particle_cp {position: Vector, attach_type: Enum.ParticleAttachment, entity?: userdata, entity_id: number, attachment_name: string, include_wearables: boolean}
---@alias particle {name: string, shortname: string, attach_type: Enum.ParticleAttachment, entity?: userdata, entity_id: number, entity_for_modifiers?: userdata, entity_for_modifiers_id: number, name_index: number, hash: number, control_points: {number: particle_cp}, created_at: number, fired_callback: boolean}
---@alias lost_item_info {name: string}

function BaseScriptAPI:Init()
	Event.AddListener("entity_hurt")
	Event.AddListener("entity_killed")
	Event.AddListener("dota_courier_lost")
end

function BaseScriptAPI:RegisterUmbrellaScript(script)
	table.insert(self.uscripts, script)
	if type(script.instance.Init) == "function" then
		script.instance:Init()
	end
end

function BaseScriptAPI:FireCallback(caller, callback_name, callback_args)
	if caller ~= self.uscripts[1] then
		return
	end
	if self[callback_name] ~= nil then
		return self[callback_name](self, table.unpack(callback_args))
	end
end

function BaseScriptAPI:GetListenedCallbacks(callbacks)
	local active_listeners = {}
	for _, callback_name in pairs(callbacks) do
		for _, uscript in pairs(self.uscripts) do
			if self:CanSendCustomCallbackToUScript(uscript, callback_name) then
				table.insert(active_listeners, callback_name)
				break
			end
		end
	end
	return active_listeners
end

function BaseScriptAPI:IsAnyCallbackListened(callbacks)
	return #self:GetListenedCallbacks(callbacks) > 0
end

function BaseScriptAPI:SendCustomCallback(callback_name, callback_args)
	for _, uscript in pairs(self.uscripts) do
		if type(uscript.instance[callback_name]) == "function" and self:CanSendCustomCallbackToUScript(uscript, callback_name) then
			uscript.instance[callback_name](uscript.instance, table.unpack(callback_args))
		end
	end
end

function BaseScriptAPI:CanSendCustomCallbackToUScript(uscript, name)
	if uscript.instance[name] == nil then return false end
	if type(uscript.instance[name.."Enabled"]) == "function" then
		if uscript.instance[name.."Enabled"](uscript.instance) then
			return true
		end
	elseif type(uscript.instance["IsCallbackEnabled"]) == "function" then
		if uscript.instance["IsCallbackEnabled"](uscript.instance, name) then
			return true
		end
	end
	return false
end

function BaseScriptAPI:CanSendCustomCallback(name)
	for _, uscript in pairs(self.uscripts) do
		if self:CanSendCustomCallbackToUScript(uscript, name) then
			return true
		end
	end
	return false
end

function BaseScriptAPI:OnFrame()
	Timers:Think()
end

function BaseScriptAPI:OnDraw()
	Panels:DrawPanels()
	self.draw_tick = self.draw_tick + 1
	self._dt_draw = GameRules.GetGameTime()
end

function BaseScriptAPI:OnPrepareUnitOrders(order)
	if order["order"] == Enum.UnitOrder.DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION and order["target"] == nil and order["ability"] == nil and order["npc"] == nil and order["showEffects"] == false then
		return false
	end
end

function BaseScriptAPI:OnFireEventClient(data)
	if data["name"] == "entity_hurt" then
		self:SendCustomCallback("OnEntityHurtEvent", {Event.GetInt(data["event"], "entindex_killed"), Event.GetInt(data["event"], "entindex_attacker"), Event.GetInt(data["event"], "entindex_inflictor"), Event.GetFloat(data["event"], "damage")})
	elseif data["name"] == "entity_killed" then
		self:SendCustomCallback("OnEntityKilledEvent", {Event.GetInt(data["event"], "entindex_killed"), Event.GetInt(data["event"], "entindex_attacker"), Event.GetInt(data["event"], "entindex_inflictor")})
	elseif data["name"] == "dota_courier_lost" then
		self:SendCustomCallback("OnCourierLostEvent", {Event.GetInt(data["event"], "killerid"), Event.GetInt(data["event"], "teamnumber"), Event.GetInt(data["event"], "bounty_gold")})
	end
end

function BaseScriptAPI:OnParticleCreate(particle)
	self.cache.particles[particle["index"]] = {
		name=particle["fullName"],
		shortname=particle["name"],
		attach_type=particle["attachType"],
		entity=particle["entity"],
		entity_id=particle["entity_id"],
		entity_for_modifiers=particle["entityForModifiers"],
		entity_for_modifiers_id=particle["entity_for_modifiers_id"],
		name_index=particle["particleNameIndex"],
		hash=particle["hash"],
		control_points={},
		created_at=GameRules.GetGameTime(),
		fired_callback=false,
	}
end

function BaseScriptAPI:OnParticleUpdate(particle)
	if self.cache.particles[particle["index"]] ~= nil then
		local control_point = {position=particle["position"]}
		if self.cache.particles[particle["index"]]["control_points"][particle["controlPoint"]] == nil then
			self.cache.particles[particle["index"]]["control_points"][particle["controlPoint"]] = {control_point}
		else
			table.insert(self.cache.particles[particle["index"]]["control_points"][particle["controlPoint"]], control_point)
		end
	end
end

function BaseScriptAPI:OnParticleUpdateFallback(particle)
	if self.cache.particles[particle["index"]] ~= nil then
		local control_point = {position=particle["position"]}
		if self.cache.particles[particle["index"]]["control_points"][particle["controlPoint"]] == nil then
			self.cache.particles[particle["index"]]["control_points"][particle["controlPoint"]] = {control_point}
		else
			table.insert(self.cache.particles[particle["index"]]["control_points"][particle["controlPoint"]], control_point)
		end
	end
end

function BaseScriptAPI:OnParticleUpdateEntity(particle)
	if self.cache.particles[particle["index"]] ~= nil then
		local control_point = {
			position=particle["position"],
			attach_type=particle["attachType"],
			entity=particle["entity"],
			entity_id=particle["entIdx"],
			attachment_name=particle["attachmentName"],
			include_wearables=particle["includeWearables"],
		}
		if self.cache.particles[particle["index"]]["control_points"][particle["controlPoint"]] == nil then
			self.cache.particles[particle["index"]]["control_points"][particle["controlPoint"]] = {control_point}
		else
			table.insert(self.cache.particles[particle["index"]]["control_points"][particle["controlPoint"]], control_point)
		end
	end
end

function BaseScriptAPI:OnParticleDestroy(particle)
	if self.cache.particles[particle["index"]] ~= nil then
		self:SendCustomCallback("OnParticleDestroyed", {table.copy(self.cache.particles[particle["index"]]), particle["destroyImmediately"]})
		self.cache.particles[particle["index"]] = nil
	end
end

function BaseScriptAPI:OnUpdate()
	local now = GameRules.GetGameTime()
	local tick = Tick()
	if tick % 2 == 0 then
		local localTeam = Players.GetLocalTeam()
		local heroListeners = {
			"OnHeroUsedAbility", "OnHeroUsedAbilityEnemy", "OnHeroUsedAbilityAlly",
			"OnHeroPhaseAbility", "OnHeroPhaseAbilityEnemy", "OnHeroPhaseAbilityAlly",
			"OnHeroLostItem", "OnHeroLostItemEnemy", "OnHeroLostItemAlly",
			"HeroVisibility", "HeroVisibilityEnemy", "HeroVisibilityAlly",
		}
		local NPCListeners = {
			"OnNPCUsedAbility", "OnNPCUsedAbilityEnemy", "OnNPCUsedAbilityAlly",
			"OnNPCPhaseAbility", "OnNPCPhaseAbilityEnemy", "OnNPCPhaseAbilityAlly",
		}
		local active_listeners = self:GetListenedCallbacks(table.combine(heroListeners, NPCListeners))
		local isListensHero = table.contains(active_listeners, table.unpack(heroListeners))
		local isListensNPC = table.contains(active_listeners, table.unpack(NPCListeners))
		local searchFlags = (isListensHero and isListensNPC) and (Enum.UnitTypeFlags.TYPE_HERO + Enum.UnitTypeFlags.TYPE_CREEP + Enum.UnitTypeFlags.TYPE_LANE_CREEP) or (isListensHero and Enum.UnitTypeFlags.TYPE_HERO or (isListensNPC and Enum.UnitTypeFlags.TYPE_CREEP + Enum.UnitTypeFlags.TYPE_LANE_CREEP) or nil)
		if tick % (2*3) == 0 or tick % (2*5) == 0 then
			if searchFlags ~= nil then
				for _, npc in pairs(NPCs.GetAll(searchFlags)) do
					if not NPC.xIsIllusion(npc) then
						local entindex = Entity.GetIndex(npc)
						local is_ally = Entity.GetTeamNum(npc) == localTeam
						local is_hero = NPC.IsHero(npc)
						local is_visible = NPC.IsVisible(npc)
						if is_hero and tick % (2*5) == 0 then
							if (table.contains(active_listeners, "HeroVisibility", "HeroVisibilityEnemy") and not is_ally) or (table.contains(active_listeners, "HeroVisibility", "HeroVisibilityAlly") and is_ally) then
								self.cache.visibility_pre[entindex] = self.cache.visibility_pre[entindex] == true
								self.cache.visibility[entindex] = is_ally and NPC.IsVisibleToEnemies(npc) or is_visible
							end
						end
						if (is_hero and tick % (2*3) == 0) or (not is_hero and tick % (2*5) == 0) then
							if is_visible and (is_hero or not NPC.IsWaitingToSpawn(npc)) then
								local use_listeners = is_hero and {
									"OnHeroUsedAbility",
									is_ally and "OnHeroUsedAbilityAlly" or "OnHeroUsedAbilityEnemy"
								} or {
									"OnNPCUsedAbility",
									is_ally and "OnNPCUsedAbilityAlly" or "OnNPCUsedAbilityEnemy",
								}
								local phase_listeners = is_hero and {
									"OnHeroPhaseAbility",
									is_ally and "OnHeroPhaseAbilityAlly" or "OnHeroPhaseAbilityEnemy",
								} or {
									"OnNPCPhaseAbility",
									is_ally and "OnNPCPhaseAbilityAlly" or "OnNPCPhaseAbilityEnemy",
								}
								local items = nil
								if table.contains(active_listeners, table.unpack(table.combine(use_listeners, phase_listeners))) then
									local use_listeners_active = table.contains(active_listeners, table.unpack(use_listeners))
									items = is_hero and NPC.GetInventory(npc) or {}
									local abilities = is_hero and (table.combine(table.values(NPC.GetAbilities(npc)), table.values(items))) or table.values(NPC.GetAbilities(npc))
									for _, ability in pairs(abilities) do
										if (Ability.IsItem(ability) or (not Ability.IsAttributes(ability) and Ability.GetLevel(ability) > 0 and not Ability.IsHidden(ability))) and not Ability.IsPassive(ability) then
											if use_listeners_active then
												local last_used = Ability.IsUsed(ability)
												if last_used then
													if not table.contains(self.cache.cast, ability) then
														for _, listener in pairs(use_listeners) do
															self:SendCustomCallback(listener, {ability})
														end
														table.insert(self.cache.cast, ability)
													end
												elseif table.contains(self.cache.cast, ability) then
													table.removeElement(self.cache.cast, ability)
												end
											end
											if table.contains(active_listeners, table.unpack(phase_listeners)) then
												local in_phase = Ability.IsInAbilityPhase(ability)
												if in_phase then
													if not table.contains(self.cache.phase, ability) then
														for _, listener in pairs(phase_listeners) do
															self:SendCustomCallback(listener, {ability})
														end
														table.insert(self.cache.phase, ability)
													end
												elseif table.contains(self.cache.phase, ability) then
													table.removeElement(self.cache.phase, ability)
												end
											end
										end
									end
								end
								local lose_listeners = is_hero and {
									"OnHeroLostItem",
									is_ally and "OnHeroLostItemAlly" or "OnHeroLostItemEnemy"
								} or {}
								if table.contains(active_listeners, table.unpack(lose_listeners)) then
									items = items or NPC.GetInventory(npc)
									if self.cache.inventory[entindex] ~= nil then
										local ward_dispenser = NPC.GetItem(npc, "item_ward_dispenser")
										for _, item in pairs(self.cache.inventory[entindex]) do
											local status, slot = pcall(Item.GetSlot, item)
											if not status then
												slot = nil
											else
												self.cache.items[item] = self.cache.items[item] or {}
												self.cache.items[item]["name"] = self.cache.items[item]["name"] or Ability.GetName(item)
											end
											local container = Item.GetContainer(item)
											if slot == nil and container == nil and self.cache.items[item] ~= nil then
												if not string.startswith(self.cache.items[item]["name"], "item_ward") or ward_dispenser == nil then
													for _, listener in pairs(lose_listeners) do
														self:SendCustomCallback(listener, {item, npc, self.cache.items[item]})
													end
												end
											end
										end
									end
									self.cache.inventory[entindex] = items
								end
							end
						end
					end
				end
			end
		end
	end
	if tick % 3 == 0 then
		for index, particle in pairs(table.copy(self.cache.particles)) do
			if not particle["fired_callback"] and now-particle["created_at"] > 0.03 then
				self.cache.particles[index]["fired_callback"] = true
				self:SendCustomCallback("OnParticle", {table.merge({index=index}, particle)})
			end
		end
	end
	self.tick = self.tick + 1
	self._.dt_update = now
end

---@param ent userdata
---@return boolean
Entity.IsWasVisibleToEnemies = function(ent)
	return BaseScriptAPI.cache.visibility_pre[ent] == true
end

---@param fx integer
---@return table?
Particle.GetInfo = function(fx)
	return BaseScriptAPI.cache.particles[fx]
end

function Tick()
	return BaseScriptAPI.tick
end

function DrawTick()
	return BaseScriptAPI.tick
end

function TickDelta()
	return BaseScriptAPI._.dt_update
end

function DrawTickDelta()
	return BaseScriptAPI._.dt_draw
end

BaseScriptAPI:Init()

return function(script)
	if type(script) ~= "table" then return end

	local UmbrellaScript = {instance=script}

	local callbacks = {
		"OnScriptsLoaded",
		"OnPreHumanizer",
		"OnDraw",
		"OnFrame",
		"OnUpdate",
		"OnUpdateEx",
		"OnEntityCreate",
		"OnEntityDestroy",
		"OnModifierCreate",
		"OnModifierDestroy",
		"OnModifierUpdate",
		"OnEntityHurt",
		"OnEntityKilled",
		"OnFireEventClient",
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
		"OnStartSound",
		"OnOverHeadEvent",
		"OnPrepareUnitOrders",
		"OnMenuOptionChange",
		"OnChatEvent",
		"OnGCMessage",
		"OnSendNetMessage",
		"OnPostReceivedNetMessage",
		"OnSetDormant",
		"OnNpcDying",
	}

	for _, callback in pairs(callbacks) do
		UmbrellaScript[callback] = function(...)
			-- local status, base_result = pcall(function() return BaseScriptAPI:callback(ScriptAPI, callback, table.unpack(args)) end)
			local base_result = BaseScriptAPI:FireCallback(UmbrellaScript, callback, {...})
			local status = true
			if status and base_result ~= nil then
				return base_result
			elseif not status then
				print("ERROR in", callback, base_result)
			end
			if UmbrellaScript.instance[callback] ~= nil then
				return UmbrellaScript.instance[callback](UmbrellaScript.instance, ...)
			end
		end
	end

	BaseScriptAPI:RegisterUmbrellaScript(UmbrellaScript)

	return UmbrellaScript
end