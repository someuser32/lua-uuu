require("libraries/__init__")

local TreeDestroyerExtended = class("TreeDestroyerExtended")

function TreeDestroyerExtended:initialize()
	self.path = {"Magma", "General", "Items manager", "Trees destroyer"}

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

	self.sound_notifications = {
		{"Disabled", nil},
		{"Ping (default)", "General.Ping"},
		{"Ping (alternative)", "General.PingWarning"},
		{"Deny", "UI.Deny.Melee"},
		{"Maim", "DOTA_Item.Maim"},
		{"Yoink", "ui.courier_in_use"},
	}

	self.tango_usage = {
		"Use always",
		"Don't use, when it used",
		"Don't use, when it used and has other skill",
	}

	self.furion_sprout_behavior = {
		"Hero forward",
		"Away from enemies or forward",
		"Away from enemies or backward",
	}

	self.furion_sprout_count = 8
	self.monkey_king_tree_offset_z = 250

	self.tree_destroyer_enable = UILib:CreateCheckbox(self.path, "Enable", false)

	self.tree_destroyer_cut_targets = {}

	for _, tree_info in pairs(destroy_trees) do
		local tree_name = CAbility:GetAbilityNameIconPath(tree_info[1])
		local whereAt = {self.path, LocaleLib:LocalizeAbilityName(tree_info[1], "true")}
		self.tree_destroyer_cut_targets[tree_info[1].."_enable"] = UILib:CreateCheckbox(whereAt, "Enable", tree_info[2])
		self.tree_destroyer_cut_targets[tree_info[1].."_destroy"] = UILib:CreateMultiselect(whereAt, "Destroy abilities", table.map(destroy_abilities, function(_, destroy_info) return {destroy_info[1], CAbility:GetAbilityNameIconPath(destroy_info[1]), destroy_info[2]} end))
		self.tree_destroyer_cut_targets[tree_info[1].."_tango_usage"] = UILib:CreateCombo(whereAt, "Tango usage", self.tango_usage, 2)
		self.tree_destroyer_cut_targets[tree_info[1].."_tango_usage"]:SetIcon(CAbility:GetAbilityNameIconPath("item_tango"))
		self.tree_destroyer_cut_targets[tree_info[1].."_tango_usage"]:SetTip("[Use always] - no restrictions, use by priority\n[Don't use, when it used] - skip using tango if caster has buff\n[Don't use, when it used and has other skill] - skip using tango only if caster has buff and other skill with lower priority\nExample: first time uses Tango for Iron Branch, next time will use Quelling Blade only if Quelling Blade not on cooldown, otherwise uses again Tango")
		if tree_info[1] == "furion_sprout" then
			self.tree_destroyer_cut_targets[tree_info[1].."_mode"] = UILib:CreateCombo(whereAt, "Destroy priority", self.furion_sprout_behavior, 1)
			self.tree_destroyer_cut_targets[tree_info[1].."_mode"]:SetIcon("~/MenuIcons/star.png")
			self.tree_destroyer_cut_targets[tree_info[1].."_move_range"] = UILib:CreateSlider({whereAt, "Move settings"}, "Move range after destroy", 0, 350, 200)
			self.tree_destroyer_cut_targets[tree_info[1].."_move_range"]:SetIcon("~/MenuIcons/horizontal.png")
			self.tree_destroyer_cut_targets[tree_info[1].."_move_range"]:SetTip("Range includes range before tree\nIt is not recommended to set high values\nSelect 0 to disable move after destroy (not recommended)")
			self.tree_destroyer_cut_targets[tree_info[1].."_move_unsafe"] = UILib:CreateCheckbox({whereAt, "Move settings"}, "Unsafe move", false)
			self.tree_destroyer_cut_targets[tree_info[1].."_move_unsafe"]:SetIcon("~/MenuIcons/red_square.png")
			self.tree_destroyer_cut_targets[tree_info[1].."_move_unsafe"]:SetTip("By default, unit does not moves if it's unsafe (example Rupture)\nEnabling this will ignore unsafe conditions")
			UILib:SetTabIcon({whereAt, "Move settings"}, "~/MenuIcons/runer-silhouette-running-fast.png")
		end
		self.tree_destroyer_cut_targets[tree_info[1].."_range_buffer"] = UILib:CreateSlider(whereAt, "Range buffer", 0, 125, 75)
		self.tree_destroyer_cut_targets[tree_info[1].."_range_buffer"]:SetIcon("~/MenuIcons/radius.png")
		self.tree_destroyer_cut_targets[tree_info[1].."_range_buffer"]:SetTip("Additional range to destroy trees\nExample: Quelling Blade has 350 cast range, trees in radius 350+range buffer will be destroyed")
		self.tree_destroyer_cut_targets[tree_info[1].."_allies"] = UILib:CreateMultiselectFromAlliesOnly(whereAt, "Allies", false, false, true)
		self.tree_destroyer_cut_targets[tree_info[1].."_allies"]:SetIcon("~/MenuIcons/group3.png")
		self.tree_destroyer_cut_targets[tree_info[1].."_allies"]:SetTip("Ally must give shared control access")
		UILib:SetTabIcon(whereAt, tree_name)
	end

	self.tree_destroyer_cut_targets["hoodwink_bushwhack_enable"]:SetTip("Destroys tree around you to prevent be trapped")
	self.tree_destroyer_cut_targets["monkey_king_tree_dance_enable"]:SetTip("Predicts MK position if he was seen while jumping\nIt's impossible to determine 100% accurate MK position, so sometimes might be inaccurate")

	self.conditions_invis, self.conditions_channeling = table.unpack(Conditions:CreateUI({self.path, "Settings"}, true, true))

	self.additional_usage = UILib:CreateAdditionalControllableUnits({self.path, "Settings"}, "Use on", false, true, false)

	self.anti_overwatch_camera = table.unpack(AntiOverwatch:CreateUI({self.path, "Settings"}, 1))

	self.tree_destroyer_notifications = UILib:CreateCheckbox({self.path, "Settings", "Notification"}, "Text", true)
	self.tree_destroyer_notifications:SetIcon("~/MenuIcons/Notifications/inotification_def.png")

	self.tree_destroyer_sound_notifications = UILib:CreateCombo({self.path, "Settings", "Notification"}, "Sound", table.map(self.sound_notifications, function(_, info) return info[1] end), 1)
	self.tree_destroyer_sound_notifications:SetIcon("~/MenuIcons/Notifications/sound_notification.png")

	UILib:SetTabIcon({self.path, "Settings", "Notification"}, "~/MenuIcons/Notifications/alarm.png")

	UILib:SetTabIcon({self.path, "Settings"}, "~/MenuIcons/utils_wheel.png")

	UILib:SetTabIcon(self.path, "~/MenuIcons/forest.png")

	self.used_items = {}
	self.monkey_king_tree_dance_particles = {}

	self.listeners = {}

	if self.tree_destroyer_enable:Get() then
		self.listeners["AbilityUsageHeroEnemy"] = true
	end
end

function TreeDestroyerExtended:OnMenuOptionChange(option, oldValue, newValue)
	if option == self.tree_destroyer_enable.menu_option then
		if self.tree_destroyer_enable:Get() then
			self.listeners["AbilityUsageHeroEnemy"] = true
		else
			self.listeners["AbilityUsageHeroEnemy"] = nil
		end
	end
end

function TreeDestroyerExtended:GetTreeDanceMaxHeight(ent)
	local tree_dance = ent:GetAbility("monkey_king_tree_dance")
	if tree_dance and tree_dance:GetLevel() > 0 then
		return tree_dance:GetLevelSpecialValueFor("perched_spot_height")
	end
	return 192
end

function TreeDestroyerExtended:GetTreeDanceSpeed(ent)
	return 1405
end

function TreeDestroyerExtended:GetTreeDanceMaxDuration(ent)
	local tree_dance = ent:GetAbility("monkey_king_tree_dance")
	if tree_dance and tree_dance:GetLevel() > 0 then
		return tree_dance:GetCastRange()/self:GetTreeDanceSpeed()
	end
	return 0.89
end

function TreeDestroyerExtended:GetBushwhackRadius(ent)
	local bushwhack = ent:GetAbility("hoodwink_bushwhack")
	if bushwhack and bushwhack:GetLevel() > 0 then
		return bushwhack:GetLevelSpecialValueFor("trap_radius")
	end
	return 265
end

function TreeDestroyerExtended:OnUpdate()
	if not self.tree_destroyer_enable:Get() then return end
	local tick = self:GetTick()
	if tick % 2 == 0 then
		for entindex, info in pairs(table.copy(self.monkey_king_tree_dance_particles)) do
			if info["start_position"] ~= nil and info["from_ground"] ~= nil and info["start_time"] ~= nil then
				local ent = CNPC:new(CEntity:Get(entindex).ent)
				if ent ~= nil then
					local start_position = info["start_position"]
					local is_from_ground = info["from_ground"]
					local start_time = info["start_time"]
					local start_height = start_position.z

					if not is_from_ground then
						start_height = start_height + self.monkey_king_tree_offset_z
					end

					local max_height = start_height + self:GetTreeDanceMaxHeight(ent)
					local current_height = ent:GetAbsOrigin().z
					local elapsed_time = CGameRules:GetGameTime() - start_time
					local max_capable_duration = self:GetTreeDanceMaxDuration(ent)
					local max_duration = vector.calculate_arc_max_duration(start_height, max_height, current_height, elapsed_time, max_capable_duration)

					if (max_duration-elapsed_time < 0) and elapsed_time > max_capable_duration then
						self.monkey_king_tree_dance_particles[entindex] = nil
						return
					end

					local is_visible = ent:IsVisible()
					if info["was_visible"] and (not is_visible or math.abs(start_height-current_height) < 5) then
						if is_visible and is_from_ground and math.abs((start_height + self.monkey_king_tree_offset_z)-current_height) > 50 then
							self.monkey_king_tree_dance_particles[entindex] = nil
							return
						end

						local end_pos = CWorld:GetGroundPosition(start_position + ent:GetRotation():GetForward() * (self:GetTreeDanceSpeed(ent)*max_duration))
						local best_trees = table.combine(CTree:FindInRadius(end_pos, 500, true), CTempTree:FindInRadius(end_pos, 500))
						table.sort(best_trees, function(a, b)
							local tree_a_pos = a:GetAbsOrigin()
							local tree_b_pos = b:GetAbsOrigin()
							local points_a = (end_pos - tree_a_pos):Length2D() * ent:FindRotationAngle(tree_a_pos)
							local points_b = (end_pos - tree_b_pos):Length2D() * ent:FindRotationAngle(tree_b_pos)
							return points_a < points_b
						end)
						local tree = best_trees[1]
						if tree ~= nil then
							self:TriggerDestroyTrees({tree}, tree:GetAbsOrigin(), "monkey_king_tree_dance", ent)
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

function TreeDestroyerExtended:OnParticle(particle)
	if particle["entity"] ~= nil then
		local ent = particle["entity"]
		if ent:GetTeamNum() ~= CPlayer:GetLocalTeam() then
			if particle["shortname"] == "monkey_king_jump_trail" then
				if particle["control_points"][1] ~= nil then
					if self.monkey_king_tree_dance_particles[particle["entity_id"]] == nil then
						self.monkey_king_tree_dance_particles[particle["entity_id"]] = {}
					end
					self.monkey_king_tree_dance_particles[particle["entity_id"]]["fx"] = particle["index"]
					self.monkey_king_tree_dance_particles[particle["entity_id"]]["start_time"] = CGameRules:GetGameTime()
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
			local now = CGameRules:GetGameTime()
			local used_items = table.values(table.map(table.filter(self.used_items, function(_, info) return now-info["time"] < 1 and tree_type == info["tree_type"] and info["trees"] == nil and info["owner"] ~= nil end), function(_, info) return {_, info} end))
			table.sort(used_items, function(a, b)
				return a[2]["time"] < b[2]["time"]
			end)
			if #used_items > 0 then
				self.used_items[used_items[1][1]]["trees"] = {CEntity:Get(particle["entity_id"])}
			else
				table.insert(self.used_items, {time=now, tree_type=tree_type, trees={CEntity:Get(particle["entity_id"])}})
			end
			self:CheckForItemTree()
			return
		else
			for _, enemy in pairs(CHero:GetEnemies()) do
				local ability = enemy:GetAbilityOrItemByName(tree_type)
				if ability ~= nil then
					owner = enemy
					break
				end
			end
		end
		if owner == nil or owner:GetTeamNum() == CPlayer:GetLocalTeam() then return end
		local center = nil
		if particle["entity_id"] ~= -1 then
			local ent = CEntity:Get(particle["entity_id"])
			if ent ~= nil and ent:IsEntity() then
				table.insert(trees, ent)
			end
		elseif tree_type == "furion_sprout" then
			local position = particle["control_points"][0][1]["position"]
			local radius = particle["control_points"][1][1]["position"].y
			trees = table.combine(trees, CTempTree:FindInRadius(position, radius+48))
			center = position
		elseif tree_type == "hoodwink_bushwhack" then
			local position = particle["control_points"][1][1]["position"]
			local radius = self:GetBushwhackRadius(owner)
			trees = table.combine(CTree:FindInRadius(position, radius+32, true), CTempTree:FindInRadius(position, radius+32))
			center = position
		end
		if #trees > 0 then
			self:TriggerDestroyTrees(trees, center or trees[1]:GetAbsOrigin(), tree_type, owner)
		end
	end
end

function TreeDestroyerExtended:OnNPCLostItem(ability, caster, info)
	if info.GetName == "item_branches" then
		local tree_type = "item_branches"
		local now = CGameRules:GetGameTime()
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
	local now = CGameRules:GetGameTime()
	for _, info in pairs(table.copy(self.used_items)) do
		if now-info["time"] < 1 then
			if info["tree_type"] ~= nil and info["trees"] ~= nil and info["owner"] ~= nil then
				self:TriggerDestroyTrees(info["trees"], info["trees"][1]:GetAbsOrigin(), info["tree_type"], info["owner"])
				self.used_items[_] = nil
			end
		else
			self.used_items[_] = nil
		end
	end
end

---@param entities CEntity[]
---@param position Vector
---@param tree_type string
---@param owner CNPC
---@return boolean
function TreeDestroyerExtended:TriggerDestroyTrees(entities, position, tree_type, owner)
	if not self.tree_destroyer_enable:Get() then return false end
	if not self.tree_destroyer_cut_targets[tree_type.."_enable"]:Get() then return false end
	if #entities <= 0 then return false end
	local local_hero = CHero:GetLocal()
	for _, unit in pairs(CNPC:GetControllableUnits(position, 900, true)) do
		local distance = (unit:GetAbsOrigin() - position):Length2D()
		if (unit == local_hero or self.tree_destroyer_cut_targets[tree_type.."_allies"]:IsSelected(unit:GetUnitName())) and ((self.additional_usage:IsSelected("spirit_bear") or not unit:IsSpiritBear()) and (self.additional_usage:IsSelected("tempest_double") or not unit:IsTempestDouble())) and unit:IsAlive() then
			if Conditions:CanUse(unit, self.conditions_invis, self.conditions_channeling) then
				if tree_type == "furion_sprout" then
					if self:IsInsideFurionSprouts(unit, position) and not unit:CanPathThroughTrees() then
						if self:DestroyTrees(entities, unit, tree_type, owner) then
							return true
						end
					end
				elseif tree_type == "hoodwink_bushwhack" then
					local radius = self:GetBushwhackRadius(owner)
					if distance <= radius+unit:GetHullRadius() then
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

---@param entities CEntity[]
---@param caster CNPC
---@param tree_type string
---@param owner CNPC
---@return boolean
function TreeDestroyerExtended:DestroyTrees(entities, caster, tree_type, owner)
	local tree = entities[1]
	if tree_type == "furion_sprout" then
		tree = self:GetBestTreeForFurionSprout(entities, caster)
	elseif tree_type == "hoodwink_bushwhack" then
		local caster_pos = caster:GetAbsOrigin()
		local best_trees = {}
		for _, tree in pairs(entities) do
			table.insert(best_trees, {tree, (tree:GetAbsOrigin()-caster_pos):Length2D()})
		end
		table.sort(best_trees, function(a, b)
			return a[2] < b[2]
		end)
		tree = best_trees[1][1]
	end
	if not AntiOverwatch:CanUseAtCamera(caster, tree:GetAbsOrigin(), self.anti_overwatch_camera) then
		return false
	end
	local range_buffer = self.tree_destroyer_cut_targets[tree_type.."_range_buffer"]:Get()
	local ability = caster:GetUsableAbilities(table.map(self.tree_destroyer_cut_targets[tree_type.."_destroy"]:Get(), function(_, ability_name)
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
		local move_range = self.tree_destroyer_cut_targets[tree_type.."_move_range"]:Get()
		if move_range > 0 then
			if self.tree_destroyer_cut_targets[tree_type.."_move_unsafe"]:Get() or self:IsSafeToMove(caster) then
				local direction = (tree:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
				local distance = (tree:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
				Timers:CreateTimer(delay + CNetChannel:GetPingDelay(), function()
					caster:MoveToInterpolated(CWorld:GetGroundPosition(caster:GetAbsOrigin() + direction * (distance + move_range)), (distance + move_range / 3), 50, 75, 0.1)
				end)
			end
		end
	end
	self:SendNotification(ability, tree_type, owner)
	return true
end

function TreeDestroyerExtended:CutDownTree(tree, ability)
	local hero = ability:GetCaster()
	local ability_name = ability:GetName()
	local heroPos = hero:GetAbsOrigin()
	local treePos = tree:GetAbsOrigin()
	local rangeToTree = (treePos - heroPos):Length2D()
	if hero:IsChannellingAbility() then
		hero:Stop()
	end
	if ability:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) then
		local position = heroPos + (treePos - heroPos):Normalized() * 200
		if ability:GetTargetTeam(Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_ENEMY) then
			local pierces_bkb = ability:PiercesBKB()
			local search_range = ability:GetCastRange() - rangeToTree
			if ability_name == "muerta_dead_shot" then
				search_range = ability:GetCastRange() * ability:GetLevelSpecialValueForFloat("ricochet_distance_multiplier")
			end
			for _, enemy in pairs(CHero:FindInRadius(treePos, search_range, hero:GetTeamNum(), Enum.TeamType.TEAM_ENEMY)) do
				if pierces_bkb or not enemy:IsDebuffImmune() then
					position = treePos + (enemy:GetAbsOrigin() - treePos):Normalized() * 50
				end
			end
		end
		ability:SelectVectorPosition(position)
	end
	ability:Cast(tree)
	if ability:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_POINT) then
		-- HACK: weird behavior, without this it sometimes does not use ability (when player spams move order)
		ability:Cast(tree)
	end
	local channel_delay = ability:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_CHANNELLED) and ability:GetChannelTime() or 0
	if not CAbility:RequiresFullChannelName(ability_name) then
		channel_delay = 0.1 + CNetChannel:GetPingDelay()
		hero:Stop()
	end
	return (not ability:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_NO_TARGET) and hero:GetTimeToFacePosition(treePos) * 1.5 or 0) + (ability:GetCastPoint() * 1.5) + channel_delay
end

---@param destroy_ability CAbility
---@param tree_type string
---@param owner CNPC
function TreeDestroyerExtended:SendNotification(destroy_ability, tree_type, owner)
	if self.tree_destroyer_notifications:Get() then
		local owner_image = CRenderer:GetOrLoadImage(GetHeroIconPath(owner:GetUnitName()))
		local tree_image = CRenderer:GetOrLoadImage(CAbility:GetAbilityNameIconPath(tree_type))
		local caster_image = CRenderer:GetOrLoadImage(GetHeroIconPath(destroy_ability:GetCaster():GetUnitName()))
		local destroy_image = CRenderer:GetOrLoadImage(CAbility:GetAbilityNameIconPath(destroy_ability:GetName()))
		CRenderer:DrawCenteredNotification("{#FF0000}[{&"..owner_image.."}{#FF0000}]{&"..tree_image.."}{#FFFFFF} destroy by {#00FF00}[{&"..caster_image.."}{#00FF00}]{&"..destroy_image.."}", 2)
	end
	local sound = self.sound_notifications[self.tree_destroyer_sound_notifications:GetIndex()][2]
	if sound ~= nil then
		CEngine:PlaySound(sound)
	end
end

---@param hero CNPC
---@param center Vector
---@return CEntity
function TreeDestroyerExtended:IsInsideFurionSprouts(hero, center)
	local heroPos = hero:GetAbsOrigin()
	local sprouts = table.values(table.filter(CTempTree:FindInRadius(center, 150+64), function(_, tree)
		local distance = (tree:GetAbsOrigin()-center):Length2D()
		return math.abs(150-distance) < 5
	end))
	local trees = CTempTree:FindInRadius(heroPos, 150+128)
	if #trees < self.furion_sprout_count or #sprouts < self.furion_sprout_count then
		return false
	end
	return table.all(table.map(sprouts, function(_, sprout) return table.contains(trees, sprout) end))
end

---@param entities CEntity[]
---@param hero CNPC
---@return CEntity
function TreeDestroyerExtended:GetBestTreeForFurionSprout(entities, hero)
	local heroPos = hero:GetAbsOrigin()
	local direction = hero:GetRotation():GetForward()
	local cut_option = self.tree_destroyer_cut_targets["furion_sprout_mode"]:GetIndex()
	if cut_option == 1 then
		direction = hero:GetRotation():GetForward()
	elseif cut_option == 2 or cut_option == 3 then
		local enemies = CHero:FindInRadius(heroPos, 900, hero:GetTeamNum(), Enum.TeamType.TEAM_ENEMY)
		if #enemies <= 0 then
			if cut_option == 2 then
				direction = hero:GetRotation():GetForward()
			elseif cut_option == 3 then
				direction = hero:GetRotation():GetForward():Rotated(Angle(0, 180, 0))
			end
		elseif #enemies == 1 then
			direction = (heroPos - enemies[1]:GetAbsOrigin()):Normalized()
		else
			local enemies_positions = {}
			for _, enemy_combination in pairs(itertools.combinations(enemies, 2)) do
				local enemy1, enemy2 = table.unpack(enemy_combination)
				local enemy1_pos, enemy2_pos = enemy1:GetAbsOrigin(), enemy2:GetAbsOrigin()
				local enemy1_distance, enmey2_distance = (enemy1_pos - heroPos):Length2D(), (enemy2_pos - heroPos):Length2D()
				local enemy1_pos_reversed, enemy2_pos_reversed = (heroPos + (heroPos - enemy1_pos):Normalized() * enemy1_distance), (heroPos + (heroPos - enemy2_pos):Normalized() * enmey2_distance)
				table.insert(enemies_positions, {{enemy1, enemy1_pos_reversed}, {enemy2, enemy2_pos_reversed}, vector.angle_between_vectors(enemy1_pos_reversed, enemy2_pos_reversed)})
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
	local path_distance = ((entities[1]:GetAbsOrigin() - heroPos):Length2D() + self.tree_destroyer_cut_targets["furion_sprout_move_range"]:Get())
	local path = CGridNav:BuildPath(heroPos, heroPos + direction * path_distance, true)
	if #path <= 0 then
		for i=-2, 2 do
			if i ~= 0 then
				path = CGridNav:BuildPath(heroPos, heroPos + direction:Rotated(Angle(0, i*15, 0)) * path_distance, true)
				if #path > 0 then
					break
				end
			end
		end
	end
	if #path <= 0 then
		return entities[1]
	end
	local direction_collisions = (path[1] - heroPos):Normalized()
	local best_trees = {}
	for _, tree in pairs(entities) do
		table.insert(best_trees, {tree, vector.angle_between_vectors(direction_collisions, (tree:GetAbsOrigin() - heroPos):Normalized())})
	end
	table.sort(best_trees, function(a, b)
		return a[2] < b[2]
	end)
	local heroHullRadius = hero:GetHullRadius()
	local function ValidateTreePos(tree_pos)
		if not CGridNav:IsTraversable(tree_pos) then
			return false
		end
		local direction = (tree_pos - heroPos):Normalized()
		local distance = (tree_pos - heroPos):Length2D()
		local tree_pos_near = CWorld:GetGroundPosition(tree_pos + direction * (distance - heroHullRadius * 2))
		if not CGridNav:IsTraversable(tree_pos_near) then
			return false
		end
		local tree_pos_far = CWorld:GetGroundPosition(tree_pos + direction * (distance + heroHullRadius * 2))
		if not CGridNav:IsTraversable(tree_pos_far) then
			return false
		end
		if #CTree:FindInRadius(tree_pos, heroHullRadius * 3, true) > 0 then
			return false
		end
		if #CTree:FindInRadius(tree_pos_near, heroHullRadius * 2, true) > 0 then
			return false
		end
		if #CTree:FindInRadius(tree_pos_far, heroHullRadius * 2, true) > 0 then
			return false
		end
		return true
	end
	for _, tree_info in pairs(best_trees) do
		local tree = tree_info[1]
		local tree_pos = tree:GetAbsOrigin()
		if ValidateTreePos(tree_pos) then
			local enough_spcae_to_cross = true
			for i=-1, 1 do
				if i ~= 0 then
					local angle = Angle(0, i*15, 0)
					local rotated_direction = (tree_pos - heroPos):Normalized():Rotated(angle)
					local rotated_pos = CWorld:GetGroundPosition(heroPos + rotated_direction * (tree_pos - heroPos):Length2D())
					if not ValidateTreePos(rotated_pos) then
						enough_spcae_to_cross = false
						break
					end
				end
			end
			if enough_spcae_to_cross then
				return tree
			end
		end
	end
	return entities[1]
end

---@param target CEntity
---@param tree_type string
---@return function
function TreeDestroyerExtended:UsableAbilitiesFilter(target, tree_type)
	---@param ability CAbility
	---@return boolean | number | nil
	return function(ability)
		local caster = ability:GetCaster()
		local ability_name = ability:GetName()
		if ability_name == "item_tango" then
			local tango_usage = self.tree_destroyer_cut_targets[tree_type.."_tango_usage"]:GetIndex()
			if tango_usage == 1 then
				return true
			elseif tango_usage == 2 then
				return not caster:HasModifier("modifier_tango_heal")
			elseif tango_usage == 3 then
				local range_buffer = self.tree_destroyer_cut_targets[tree_type.."_range_buffer"]:Get()
				local abilities = table.map(table.values(table.filter(self.tree_destroyer_cut_targets[tree_type.."_destroy"]:Get(), function(_, abilityname)
					return abilityname ~= ability_name
				end)), function(_, ability_name)
					return {ability_name, range_buffer, nil}
				end)
				return not caster:HasModifier("modifier_tango_heal") or #caster:GetUsableAbilities(abilities, target, self:UsableAbilitiesFilter(target, tree_type)) == 0
			end
		end
		return true
	end
end

---@param hero CNPC
---@return boolean
function TreeDestroyerExtended:IsSafeToMove(hero)
	if hero:HasModifier("modifier_bloodseeker_rupture") then
		return false
	end
	return true
end

return BaseScriptAPI(TreeDestroyerExtended)