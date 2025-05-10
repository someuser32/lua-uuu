require("xlib/__init__")

local TreeDestroyerExtended = {}

function TreeDestroyerExtended:Init()
	local destroy_abilities = {
		{"item_tango", false},
		{"item_quelling_blade", true},
		{"item_bfury", true},
		{"shredder_whirling_death", true},
		{"furion_force_of_nature", false},
		{"muerta_dead_shot", true},
		{"beastmaster_wild_axes", false},
		{"dark_seer_vacuum", false},
		{"lina_light_strike_array", false},
		{"leshrac_split_earth", false},
		{"windrunner_powershot", false},
	}

	local destroy_trees = {
		{"item_branches", true},
		{"furion_sprout", true},
		{"hoodwink_acorn_shot", true},
		{"hoodwink_bushwhack", true},
		{"monkey_king_tree_dance", true},
	}

	self.furion_sprout_behavior = {
		"Hero forward",
		"Away from enemies or forward",
		"Away from enemies or backward",
	}

	self.tango_usage = {
		"Use always",
		"Don't use, when it used",
		"Don't use, when it used and has other skill",
	}

	self.furion_sprout_count = 8
	self.monkey_king_tree_offset_z = 250

	self.font = Render.LoadFont("Verdana", Enum.FontCreate.FONTFLAG_ANTIALIAS, 0)
	self.icons = Render.LoadFont("FontAwesomeEx", Enum.FontCreate.FONTFLAG_ANTIALIAS, 0)

	self.menu = Menu.Create("General", "Main", "Items Manager")

	self.menu_main = self.menu:Create("xScripts")
	self.menu_main:Icon("\u{e12e}")

	self.menu_script = self.menu_main:Create("Trees Destroyer")

	self.enable = self.menu_script:Switch("Enable", false)
	self.enable:Icon("\u{f00c}")

	self.tree_settings_label = self.menu_script:Label("Tree Settings")
	self.tree_settings_label:Icon("\u{f724}")
	self.tree_settings_gear = self.tree_settings_label:Gear("Tree Specific Settings")

	self.current_tree_settings = self.tree_settings_gear:MultiSelect("Select Tree", table.map(destroy_trees, function(_, info) return {info[1], Ability.GetAbilityNameIconPath(info[1]), false} end), true)
	self.current_tree_settings:Icon("\u{f1bb}")
	self.current_tree_settings:OneItemSelection(true)
	self.current_tree_settings:DragAllowed(false)

	self.tree_settings = {}

	for _, tree_info in pairs(destroy_trees) do
		self.tree_settings[tree_info[1].."_enable"] = self.tree_settings_gear:Switch("Enable", tree_info[2])
		self.tree_settings[tree_info[1].."_enable"]:Icon("\u{f00c}")

		self.tree_settings[tree_info[1].."_destroy"] = self.tree_settings_gear:MultiSelect("Destroy abilities", table.map(destroy_abilities, function(_, destroy_info) return {destroy_info[1], Ability.GetAbilityNameIconPath(destroy_info[1]), destroy_info[2]} end))
		self.tree_settings[tree_info[1].."_destroy"]:Icon("\u{f6b2}")

		self.tree_settings[tree_info[1].."_range_buffer"] = self.tree_settings_gear:Slider("Range buffer", 0, 150, 75)
		self.tree_settings[tree_info[1].."_range_buffer"]:Icon("\u{f547}")
		self.tree_settings[tree_info[1].."_range_buffer"]:ToolTip("Additional range to destroy trees\nExample: Quelling Blade has 350 cast range, trees in radius 350+range buffer will be destroyed")

		self.tree_settings[tree_info[1].."_tango_usage"] = self.tree_settings_gear:Combo("Tango usage", self.tango_usage, 2)
		self.tree_settings[tree_info[1].."_tango_usage"]:Image(Ability.GetAbilityNameIconPath("item_tango"))
		self.tree_settings[tree_info[1].."_tango_usage"]:ToolTip("[Use always] - no restrictions, use by priority\n[Don't use, when it used] - skip using tango if caster has buff\n[Don't use, when it used and has other skill] - skip using tango only if caster has buff and other skill with lower priority\nExample: first time uses Tango for Iron Branch, next time will use Quelling Blade only if Quelling Blade not on cooldown, otherwise uses again Tango")

		if tree_info[1] == "furion_sprout" then
			self.tree_settings[tree_info[1].."_mode"] = self.tree_settings_gear:Combo("Destroy priority", self.furion_sprout_behavior, 1)
			self.tree_settings[tree_info[1].."_mode"]:Icon("\u{f005}")

			self.tree_settings[tree_info[1].."_move_range"] = self.tree_settings_gear:Slider("Move range after destroy", 0, 350, 200)
			self.tree_settings[tree_info[1].."_move_range"]:Icon("\u{f554}")
			self.tree_settings[tree_info[1].."_move_range"]:ToolTip("Range includes range before tree\nIt is not recommended to set high values\nSelect 0 to disable move after destroy (not recommended)")
			self.tree_settings[tree_info[1].."_move_range"]:SetCallback(function(move_range)
				if self.tree_settings[tree_info[1].."_move_dangerous"] == nil then return end
				self.tree_settings[tree_info[1].."_move_dangerous"]:Disabled(not self.tree_settings[tree_info[1].."_enable"]:Get() or move_range:Get() == 0)
			end)

			self.tree_settings[tree_info[1].."_move_dangerous"] = self.tree_settings_gear:Switch("Dangerous move", false)
			self.tree_settings[tree_info[1].."_move_dangerous"]:Icon("\u{f714}")
			self.tree_settings[tree_info[1].."_move_dangerous"]:ToolTip("Move under dangerous effects (Rupture for examples)")
		end

		self.tree_settings[tree_info[1].."_allies"] = UILib:CreateMultiselectFromAlliesOnly(self.tree_settings_gear, "Allies", true, false, true)
		self.tree_settings[tree_info[1].."_allies"]:Icon("\u{f830}")
		self.tree_settings[tree_info[1].."_allies"]:DragAllowed(false)
		self.tree_settings[tree_info[1].."_allies"]:ToolTip("Ally must give shared control access")

		self.tree_settings[tree_info[1].."_enable"]:SetCallback(function(enable)
			local enabled = enable:Get()
			for settings_name, widget in pairs(self.tree_settings) do
				if string.startswith(settings_name, tree_info[1]) and settings_name ~= tree_info[1].."_enable" then
					if type(widget.Disabled) == "function" then
						if settings_name == tree_info[1].."_move_dangerous" then
							widget:Disabled(not enabled or self.tree_settings[tree_info[1].."_move_range"]:Get() == 0)
						else
							widget:Disabled(not enabled)
						end
					end
				end
			end
		end, true)
	end

	self.tree_settings["hoodwink_bushwhack_enable"]:ToolTip("Destroys tree near hero to prevent be trapped")
	self.tree_settings["monkey_king_tree_dance_enable"]:ToolTip("Predicts MK position if he was seen while jumping\nIt's impossible to determine 100% accurate MK position, so sometimes might be inaccurate")

	self.current_tree_settings:SetCallback(function(current_tree_settings)
		local enabled_tree = current_tree_settings:ListEnabled()[1]
		for settings_name, widget in pairs(self.tree_settings) do
			if type(widget.Visible) == "function" then
				widget:Visible(enabled_tree ~= nil and string.startswith(settings_name, enabled_tree) or false)
			end
		end
	end, true)

	self.conditions_invis, self.conditions_channeling = table.unpack(Conditions:CreateUI(self.menu_script, true, true, true))

	self.additional_usage = UILib:CreateAdditionalControllableUnits(self.menu_script, nil, false, true, false)

	self.anti_overwatch_camera = table.unpack(AntiOverwatch:CreateUI(self.menu_script, true, Enum.AntiOverwatchCameraOption.ADVANCED))

	self.tree_destroyer_notifications_text, self.tree_destroyer_notifications_sound = table.unpack(Notifications:CreateUI(self.menu_script, true, true, true))

	self.used_items = {}
	self.monkey_king_tree_dance_particles = {}
end

---@param callback_name string
---@return boolean
function TreeDestroyerExtended:IsCallbackEnabled(callback_name)
	return self.enable:Get()
end

---@param ent userdata
---@return number
function TreeDestroyerExtended:GetTreeDanceMaxHeight(ent)
	local tree_dance = NPC.GetAbility(ent, "monkey_king_tree_dance")
	if tree_dance and Ability.GetLevel(tree_dance) > 0 then
		return Ability.GetLevelSpecialValueFor(tree_dance, "perched_spot_height")
	end
	return 192
end

---@param ent userdata
---@return number
function TreeDestroyerExtended:GetTreeDanceSpeed(ent)
	return 1405
end

---@param ent userdata
---@return number
function TreeDestroyerExtended:GetTreeDanceMaxDuration(ent)
	local tree_dance = NPC.GetAbility(ent, "monkey_king_tree_dance")
	if tree_dance and Ability.GetLevel(tree_dance) > 0 then
		return Ability.GetEffectiveCastRange(tree_dance)/self:GetTreeDanceSpeed(ent)
	end
	return 0.89
end

---@param ent userdata
---@return number
function TreeDestroyerExtended:GetBushwhackRadius(ent)
	local bushwhack = NPC.GetAbility(ent, "hoodwink_bushwhack")
	if bushwhack and Ability.GetLevel(bushwhack) > 0 then
		return Ability.GetLevelSpecialValueFor(bushwhack, "trap_radius")
	end
	return 265
end

function TreeDestroyerExtended:OnUpdate()
	if not self.enable:Get() then return end
	local tick = Tick()
	if tick % 2 == 0 then
		for entindex, info in pairs(table.copy(self.monkey_king_tree_dance_particles)) do
			if info["start_position"] ~= nil and info["from_ground"] ~= nil and info["start_time"] ~= nil then
				local ent = Entity.Get(entindex)
				if ent ~= nil then
					local start_position = info["start_position"]
					local is_from_ground = info["from_ground"]
					local start_time = info["start_time"]
					local start_height = start_position.z

					if not is_from_ground then
						start_height = start_height + self.monkey_king_tree_offset_z
					end

					local max_height = start_height + self:GetTreeDanceMaxHeight(ent)
					local current_height = Entity.GetAbsOrigin(ent).z
					local elapsed_time = GameRules.GetGameTime() - start_time
					local max_capable_duration = self:GetTreeDanceMaxDuration(ent)
					local max_duration = Vec.calculate_arc_max_duration(start_height, max_height, current_height, elapsed_time, max_capable_duration)

					if (max_duration-elapsed_time < 0) and elapsed_time > max_capable_duration then
						self.monkey_king_tree_dance_particles[entindex] = nil
						return
					end

					local is_visible = NPC.IsVisible(ent)
					if info["was_visible"] and (not is_visible or math.abs(start_height-current_height) < 5) then
						if is_visible and is_from_ground and math.abs((start_height + self.monkey_king_tree_offset_z)-current_height) > 50 then
							self.monkey_king_tree_dance_particles[entindex] = nil
							return
						end

						local end_pos = World.GetGroundPosition(start_position + Entity.GetRotation(ent):GetForward() * (self:GetTreeDanceSpeed(ent)*max_duration))
						local best_trees = table.filter(table.combine(Trees.InRadius(end_pos, 500, true), TempTrees.InRadius(end_pos, 500)), function(_, tree)
							local angle = NPC.FindRotationAngle(ent, Entity.GetAbsOrigin(tree))
							return angle < 0.2
						end)
						table.sort(best_trees, function(a, b)
							local tree_a_pos = Entity.GetAbsOrigin(a)
							local tree_b_pos = Entity.GetAbsOrigin(b)
							local angle_a = NPC.FindRotationAngle(ent, tree_a_pos)
							local angle_b = NPC.FindRotationAngle(ent, tree_b_pos)
							local points_a = (end_pos - tree_a_pos):Length2D() * angle_a
							local points_b = (end_pos - tree_b_pos):Length2D() * angle_b
							return points_a < points_b
						end)
						local tree = best_trees[1]
						if tree ~= nil then
							self:TriggerDestroyTrees({tree}, Entity.GetAbsOrigin(tree), "monkey_king_tree_dance", ent)
						end
						self.monkey_king_tree_dance_particles[entindex] = nil
					else
						if is_visible then
							self.monkey_king_tree_dance_particles[entindex]["was_visible"] = true
						end
					end
				end
			end
		end
	end
end

---@param particle particle
function TreeDestroyerExtended:OnParticle(particle)
	local localteam = Players.GetLocalTeam()
	if particle["entity"] ~= nil and Entity.IsEntity(particle["entity"]) then
		if Entity.GetTeamNum(particle["entity"]) ~= localteam then
			if particle["shortname"] == "monkey_king_jump_trail" then
				if particle["control_points"][1] ~= nil then
					if self.monkey_king_tree_dance_particles[particle["entity_id"]] == nil then
						self.monkey_king_tree_dance_particles[particle["entity_id"]] = {}
					end
					self.monkey_king_tree_dance_particles[particle["entity_id"]]["fx"] = particle["index"]
					self.monkey_king_tree_dance_particles[particle["entity_id"]]["start_time"] = GameRules.GetGameTime()
					self.monkey_king_tree_dance_particles[particle["entity_id"]]["start_position"] = particle["control_points"][1][1]["position"]
				end
				return
			elseif particle["shortname"] == "monkey_king_jump_launch_ring" then
				if self.monkey_king_tree_dance_particles[particle["entity_id"]] == nil then
					self.monkey_king_tree_dance_particles[particle["entity_id"]] = {}
				end
				self.monkey_king_tree_dance_particles[particle["entity_id"]]["from_ground"] = true
				return
			elseif particle["shortname"] == "monkey_king_jump_treelaunch_ring" then
				if self.monkey_king_tree_dance_particles[particle["entity_id"]] == nil then
					self.monkey_king_tree_dance_particles[particle["entity_id"]] = {}
				end
				self.monkey_king_tree_dance_particles[particle["entity_id"]]["from_ground"] = false
				return
			end
		end
	end
	local tree_types = {
		["ironwood_tree"] = "item_branches",
		["furion_sprout"] = "furion_sprout",
		["hoodwink_acorn_shot_tree"] = "hoodwink_acorn_shot",
		["hoodwink_bushwhack_projectile"] = "hoodwink_bushwhack",
	}
	local tree_type = tree_types[particle["shortname"]]
	if tree_type ~= nil then
		local owner = nil
		local trees = {}
		if particle["entity_for_modifiers"] ~= nil then
			owner = particle["entity_for_modifiers"]
		elseif tree_type == "item_branches" then
			local now = GameRules.GetGameTime()
			local used_items = table.values(table.map(table.filter(self.used_items, function(_, info) return now-info["time"] < 1 and tree_type == info["tree_type"] and info["trees"] == nil and info["owner"] ~= nil end), function(_, info) return {_, info} end))
			table.sort(used_items, function(a, b)
				return a[2]["time"] < b[2]["time"]
			end)
			if #used_items > 0 then
				self.used_items[used_items[1][1]]["trees"] = {Entity.Get(particle["entity_id"])}
			else
				table.insert(self.used_items, {time=now, tree_type=tree_type, trees={Entity.Get(particle["entity_id"])}})
			end
			self:CheckForItemTree()
			return
		else
			for _, enemy in pairs(Heroes.GetAll()) do
				if Entity.GetTeamNum(enemy) ~= localteam then
					local ability = NPC.GetAbilityOrItemByName(enemy, tree_type)
					if ability ~= nil then
						owner = enemy
						break
					end
				end
			end
		end
		if owner == nil or Entity.GetTeamNum(owner) == localteam then return end
		local center = nil
		if particle["entity_id"] ~= -1 then
			local ent = Entity.Get(particle["entity_id"])
			if ent ~= nil and Entity.IsEntity(ent) then
				table.insert(trees, ent)
			end
		elseif tree_type == "furion_sprout" then
			local position = particle["control_points"][0][1]["position"]
			local radius = particle["control_points"][1][1]["position"].y
			trees = table.combine(trees, TempTrees.InRadius(position, radius+48))
			center = position
		elseif tree_type == "hoodwink_bushwhack" then
			local position = particle["control_points"][1][1]["position"]
			local radius = self:GetBushwhackRadius(owner)
			trees = table.combine(Trees.InRadius(position, radius+32, true), TempTrees.InRadius(position, radius+32))
			center = position
		end
		if #trees > 0 then
			self:TriggerDestroyTrees(trees, center or Entity.GetAbsOrigin(trees[1]), tree_type, owner)
		end
	end
end

---@param item userdata
---@param caster userdata
---@param info lost_item_info
function TreeDestroyerExtended:OnHeroLostItemEnemy(item, caster, info)
	if info["name"] == "item_branches" then
		local tree_type = "item_branches"
		local now = GameRules.GetGameTime()
		local used_items = table.values(table.map(table.filter(self.used_items, function(_, info) return now-info["time"] < 1 and tree_type == info["tree_type"] and info["trees"] ~= nil and info["owner"] == nil end), function(_, info) return {_, info} end))
		table.sort(used_items, function(a, b)
			return a[2]["time"] < b[2]["time"]
		end)
		if #used_items > 0 then
			self.used_items[used_items[1][1]]["owner"] = caster
		else
			table.insert(self.used_items, {time=now, tree_type=tree_type, owner=caster})
		end
		self:CheckForItemTree()
	end
end

function TreeDestroyerExtended:CheckForItemTree()
	local now = GameRules.GetGameTime()
	for _, info in pairs(table.copy(self.used_items)) do
		if now-info["time"] < 1 then
			if info["tree_type"] ~= nil and info["trees"] ~= nil and info["owner"] ~= nil then
				self:TriggerDestroyTrees(info["trees"], Entity.GetAbsOrigin(info["trees"][1]), info["tree_type"], info["owner"])
				self.used_items[_] = nil
			end
		else
			self.used_items[_] = nil
		end
	end
end

---@param entities userdata[]
---@param position Vector
---@param tree_type string
---@param owner userdata
---@return boolean
function TreeDestroyerExtended:TriggerDestroyTrees(entities, position, tree_type, owner)
	if not self.enable:Get() then return false end
	if not self.tree_settings[tree_type.."_enable"]:Get() then return false end
	if #entities <= 0 then return false end
	local local_hero = Heroes.GetLocal()
	for _, unit in pairs(NPC.GetControllableUnits(position, 900, true)) do
		local distance = (Entity.GetAbsOrigin(unit) - position):Length2D()
		if ((unit == local_hero or self.tree_settings[tree_type.."_allies"]:Get(NPC.GetUnitName(unit))) or ((self.additional_usage:Get("spirit_bear") or not NPC.IsSpiritBear(unit)) and (self.additional_usage:Get("tempest_double") or not NPC.IsTempestDouble(unit)))) and Entity.IsAlive(unit) then
			if Conditions:CanUse(unit, self.conditions_invis, self.conditions_channeling) then
				if tree_type == "furion_sprout" then
					if self:IsInsideFurionSprouts(unit, position) and not NPC.CanPathThroughTrees(unit) then
						if self:DestroyTrees(entities, unit, tree_type, owner) then
							return true
						end
					end
				elseif tree_type == "hoodwink_bushwhack" then
					local radius = self:GetBushwhackRadius(owner)
					if distance <= radius+NPC.GetHullRadius(unit) then
						if self:DestroyTrees(entities, unit, tree_type, owner) then
							return true
						end
					end
				else
					if self:DestroyTrees(entities, unit, tree_type, owner) then
						return true
					end
				end
			end
		end
	end
	return false
end

---@param entities userdata[]
---@param caster userdata
---@param tree_type string
---@param owner userdata
---@return boolean
function TreeDestroyerExtended:DestroyTrees(entities, caster, tree_type, owner)
	local tree = entities[1]
	if tree_type == "furion_sprout" then
		tree = self:GetBestTreeForFurionSprout(entities, caster)
	elseif tree_type == "hoodwink_bushwhack" then
		local caster_pos = Entity.GetAbsOrigin(caster)
		local best_trees = {}
		for _, tree in pairs(entities) do
			table.insert(best_trees, {tree, (Entity.GetAbsOrigin(tree)-caster_pos):Length2D()})
		end
		table.sort(best_trees, function(a, b)
			return a[2] < b[2]
		end)
		tree = best_trees[1][1]
	end
	if not AntiOverwatch:CanUseAtCamera(caster, Entity.GetAbsOrigin(tree), self.anti_overwatch_camera) then
		return false
	end
	local range_buffer = self.tree_settings[tree_type.."_range_buffer"]:Get()
	local ability = NPC.GetUsableAbilities(caster, table.map(self.tree_settings[tree_type.."_destroy"]:ListEnabled(), function(_, ability_name)
		return {ability_name, range_buffer, nil}
	end), tree, nil, nil, self:UsableAbilitiesFilter(tree, tree_type))[1]
	if not ability then
		return false
	end
	local delay = self:CutDownTree(tree, ability)
	if delay == -1 then
		return false
	end
	if tree_type == "furion_sprout" then
		local move_range = self.tree_settings[tree_type.."_move_range"]:Get()
		if move_range > 0 then
			if self.tree_settings[tree_type.."_move_dangerous"]:Get() or self:IsSafeToMove(caster) then
				local direction = (Entity.GetAbsOrigin(tree) - Entity.GetAbsOrigin(caster)):Normalized()
				local distance = (Entity.GetAbsOrigin(tree) - Entity.GetAbsOrigin(caster)):Length2D()
				Timers:CreateTimer(delay + NetChannel.GetPingDelay(), function()
					NPC.MoveToInterpolated(caster, World.GetGroundPosition(Entity.GetAbsOrigin(caster) + direction * (distance + move_range)), (distance + move_range / 3), 50, 75, 0.1)
				end)
			end
		end
	end
	self:SendNotification(ability, tree_type, owner)
	return true
end

---@param tree userdata
---@param ability userdata
---@return number
function TreeDestroyerExtended:CutDownTree(tree, ability)
	local hero = Ability.GetOwner(ability)
	local ability_name = Ability.GetName(ability)
	local heroPos = Entity.GetAbsOrigin(hero)
	local treePos = Entity.GetAbsOrigin(tree)
	local rangeToTree = (treePos - heroPos):Length2D()
	if NPC.IsChannellingAbilityOrItem(hero) then
		NPC.Stop(hero)
	end
	if Ability.HasBehavior(ability, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) then
		local position = heroPos + (treePos - heroPos):Normalized() * 200
		if Ability.HasTargetTeam(ability, Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_ENEMY) then
			local pierces_bkb = Ability.PiercesBKB(ability)
			local search_range = Ability.GetEffectiveCastRange(ability) - rangeToTree
			if ability_name == "muerta_dead_shot" then
				search_range = Ability.GetEffectiveCastRange(ability) * Ability.GetLevelSpecialValueFor(ability, "ricochet_distance_multiplier")
			end
			for _, enemy in pairs(Heroes.InRadius(treePos, search_range, Entity.GetTeamNum(hero), Enum.TeamType.TEAM_ENEMY)) do
				if pierces_bkb or not NPC.IsDebuffImmune(enemy) then
					position = treePos + (Entity.GetAbsOrigin(enemy) - treePos):Normalized() * 50
				end
			end
		end
		Ability.SelectVectorPosition(ability, position)
	end
	Ability.Cast(ability, tree)
	if Ability.HasBehavior(ability, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_POINT) then
		-- HACK: weird behavior, without this it sometimes does not use ability (when player spams move order)
		Ability.Cast(ability, tree)
	end
	local channel_delay = Ability.HasBehavior(ability, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_CHANNELLED) and Ability.GetChannelTime(ability) or 0
	if not Ability.RequiresFullChannel(ability) then
		channel_delay = 0.1 + NetChannel.GetPingDelay()
		NPC.Stop(hero)
	end
	return (not Ability.HasBehavior(ability, Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NO_TARGET) and NPC.GetTimeToFacePosition(hero, treePos) * 1.5 or 0) + (Ability.GetCastPoint(ability) * 1.5) + channel_delay
end

---@param destroy_ability userdata
---@param tree_type string
---@param owner userdata
function TreeDestroyerExtended:SendNotification(destroy_ability, tree_type, owner)
	local owner_image = Render.LoadImage(GetHeroIconPath(NPC.GetUnitName(owner)))
	local tree_image = Render.LoadImage(Ability.GetAbilityNameIconPath(tree_type))
	local caster_image = Render.LoadImage(GetHeroIconPath(NPC.GetUnitName(Ability.GetOwner(destroy_ability))))
	local destroy_image = Render.LoadImage(Ability.GetAbilityNameIconPath(Ability.GetName(destroy_ability)))
	Notifications:SendCenteredNotification("{#FF0000}[{&"..owner_image.."}{#FF0000}]{&"..tree_image.."}{#FFFFFF} destroy by {#00FF00}[{&"..caster_image.."}{#00FF00}]{&"..destroy_image.."}", 2, self.tree_destroyer_notifications_text, self.tree_destroyer_notifications_sound)
end

---@param hero userdata
---@param center Vector
---@return boolean
function TreeDestroyerExtended:IsInsideFurionSprouts(hero, center)
	local heroPos = Entity.GetAbsOrigin(hero)
	local sprouts = table.values(table.filter(TempTrees.InRadius(center, 150+64), function(_, tree)
		local distance = (Entity.GetAbsOrigin(tree)-center):Length2D()
		return math.abs(150-distance) < 5
	end))
	local trees = TempTrees.InRadius(heroPos, 150+128)
	if #trees < self.furion_sprout_count or #sprouts < self.furion_sprout_count then
		return false
	end
	return table.all(table.map(sprouts, function(_, sprout) return table.contains(trees, sprout) end))
end

---@param entities userdata[]
---@param hero userdata
---@return userdata
function TreeDestroyerExtended:GetBestTreeForFurionSprout(entities, hero)
	local heroPos = Entity.GetAbsOrigin(hero)
	local direction = Entity.GetRotation(hero):GetForward()
	local cut_option = self.tree_settings["furion_sprout_mode"]:Get()
	if cut_option == 0 then
		direction = Entity.GetRotation(hero):GetForward()
	elseif cut_option == 1 or cut_option == 2 then
		local enemies = Heroes.InRadius(heroPos, 900, Entity.GetTeamNum(hero), Enum.TeamType.TEAM_ENEMY)
		if #enemies <= 0 then
			if cut_option == 1 then
				direction = Entity.GetRotation(hero):GetForward()
			elseif cut_option == 2 then
				direction = Entity.GetRotation(hero):GetForward():Rotated(Angle(0, 180, 0))
			end
		elseif #enemies == 1 then
			direction = (heroPos - Entity.GetAbsOrigin(enemies[1])):Normalized()
		else
			local enemies_positions = {}
			for _, enemy_combination in pairs(itertools.combinations(enemies, 2)) do
				local enemy1, enemy2 = table.unpack(enemy_combination)
				local enemy1_pos, enemy2_pos = Entity.GetAbsOrigin(enemy1), Entity.GetAbsOrigin(enemy2)
				local enemy1_distance, enmey2_distance = (enemy1_pos - heroPos):Length2D(), (enemy2_pos - heroPos):Length2D()
				local enemy1_pos_reversed, enemy2_pos_reversed = (heroPos + (heroPos - enemy1_pos):Normalized() * enemy1_distance), (heroPos + (heroPos - enemy2_pos):Normalized() * enmey2_distance)
				table.insert(enemies_positions, {{enemy1, enemy1_pos_reversed}, {enemy2, enemy2_pos_reversed}, Vec.AngleBetween(enemy1_pos_reversed, enemy2_pos_reversed)})
			end
			table.sort(enemies_positions, function(a, b)
				return a[3] > b[3]
			end)
			local enemy1, enemy1_pos_reversed = table.unpack(enemies_positions[1][1])
			local enemy2, enemy2_pos_reversed = table.unpack(enemies_positions[1][2])
			local center_between_enemies = enemy1_pos_reversed + (enemy2_pos_reversed - enemy1_pos_reversed):Normalized() * ((enemy1_pos_reversed - enemy2_pos_reversed):Length2D() / 2)
			direction = (center_between_enemies - heroPos):Normalized()
		end
	end
	local path_distance = ((Entity.GetAbsOrigin(entities[1]) - heroPos):Length2D() + self.tree_settings["furion_sprout_move_range"]:Get())
	local path = GridNav.BuildPath(heroPos, heroPos + direction * path_distance, true)
	if #path <= 0 then
		for i=-2, 2 do
			if i ~= 0 then
				path = GridNav.BuildPath(heroPos, heroPos + direction:Rotated(Angle(0, i*15, 0)) * path_distance, true)
				if #path > 0 then
					break
				end
			end
		end
	end
	if #path <= 0 then
		return entities[1]
	end
	local direction_collisions = (path[#path >= 2 and 2 or 1] - heroPos):Normalized()
	local best_trees = {}
	for _, tree in pairs(entities) do
		table.insert(best_trees, {tree, Vec.AngleBetween(direction_collisions, (Entity.GetAbsOrigin(tree) - heroPos):Normalized())})
	end
	table.sort(best_trees, function(a, b)
		return a[2] < b[2]
	end)
	local heroHullRadius = NPC.GetHullRadius(hero)
	local function ValidateTreePos(tree_pos)
		if not GridNav.IsTraversable(tree_pos) then
			return false
		end
		local direction = (tree_pos - heroPos):Normalized()
		local distance = (tree_pos - heroPos):Length2D()
		local tree_pos_near = World.GetGroundPosition(tree_pos + direction * (distance - heroHullRadius * 2))
		if not GridNav.IsTraversable(tree_pos_near) then
			return false
		end
		local tree_pos_far = World.GetGroundPosition(tree_pos + direction * (distance + heroHullRadius * 2))
		if not GridNav.IsTraversable(tree_pos_far) then
			return false
		end
		if #Trees.InRadius(tree_pos, heroHullRadius * 3, true) > 0 then
			return false
		end
		if #Trees.InRadius(tree_pos_near, heroHullRadius * 2, true) > 0 then
			return false
		end
		if #Trees.InRadius(tree_pos_far, heroHullRadius * 2, true) > 0 then
			return false
		end
		return true
	end
	for _, tree_info in pairs(best_trees) do
		local tree = tree_info[1]
		local tree_pos = Entity.GetAbsOrigin(tree)
		if ValidateTreePos(tree_pos) then
			local enough_space_to_cross = true
			for i=-1, 1 do
				if i ~= 0 then
					local angle = Angle(0, i*15, 0)
					local rotated_direction = (tree_pos - heroPos):Normalized():Rotated(angle)
					local rotated_pos = World.GetGroundPosition(heroPos + rotated_direction * (tree_pos - heroPos):Length2D())
					if not ValidateTreePos(rotated_pos) then
						enough_space_to_cross = false
						break
					end
				end
			end
			if enough_space_to_cross then
				return tree
			end
		end
	end
	return entities[1]
end

---@param target userdata
---@param tree_type string
---@return function
function TreeDestroyerExtended:UsableAbilitiesFilter(target, tree_type)
	---@param ability userdata
	---@return boolean | number | nil
	return function(ability)
		local caster = Ability.GetOwner(ability)
		local ability_name = Ability.GetName(ability)
		if ability_name == "item_tango" then
			local tango_usage = self.tree_settings[tree_type.."_tango_usage"]:Get()
			if tango_usage == 0 then
				return true
			elseif tango_usage == 1 then
				return not NPC.HasModifier(caster, "modifier_tango_heal")
			elseif tango_usage == 2 then
				local range_buffer = self.tree_settings[tree_type.."_range_buffer"]:Get()
				local abilities = table.map(table.values(table.filter(self.tree_settings[tree_type.."_destroy"]:ListEnabled(), function(_, abilityname)
					return abilityname ~= ability_name
				end)), function(_, ability_name)
					return {ability_name, range_buffer, nil}
				end)
				return not NPC.HasModifier(caster, "modifier_tango_heal") or #NPC.GetUsableAbilities(caster, abilities, target, nil, nil, self:UsableAbilitiesFilter(target, tree_type)) == 0
			end
		end
		return true
	end
end

---@param npc userdata
---@return boolean
function TreeDestroyerExtended:IsSafeToMove(npc)
	if NPC.HasModifier(npc, "modifier_bloodseeker_rupture") then
		return false
	end
	return true
end

return BaseScript(TreeDestroyerExtended)