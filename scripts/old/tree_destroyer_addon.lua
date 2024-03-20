local class = require("lib/middleclass")

require("lib/lib")

local ScriptAPI = require("lib/script")()

local TreeDestroyerAddon = class("TreeDestroyerAddon")

function TreeDestroyerAddon:initialize()
	self.path = {"General", "Items manager", "Trees destroyer", "Addon"}

	self.destroy_abilities = {
		{"item_tango", "panorama/images/items/tango_png.vtex_c", false},
		{"item_quelling_blade", "panorama/images/items/quelling_blade_png.vtex_c", true},
		{"item_bfury", "panorama/images/items/bfury_png.vtex_c", true},
		{"shredder_whirling_death", "panorama/images/spellicons/shredder_whirling_death_png.vtex_c", true},
		{"furion_force_of_nature", "panorama/images/spellicons/furion_force_of_nature_png.vtex_c", false},
		{"muerta_dead_shot", "panorama/images/spellicons/muerta_dead_shot_png.vtex_c", true},
		{"beastmaster_wild_axes", "panorama/images/spellicons/beastmaster_wild_axes_png.vtex_c", false},
		{"dark_seer_vacuum", "panorama/images/spellicons/dark_seer_vacuum_png.vtex_c", false},
		{"lina_light_strike_array", "panorama/images/spellicons/lina_light_strike_array_png.vtex_c", false},
		{"leshrac_split_earth", "panorama/images/spellicons/leshrac_split_earth_png.vtex_c", false},
		{"windrunner_powershot", "panorama/images/spellicons/windrunner_powershot_png.vtex_c", false},
	}

	self.cancelable_channelings = {"windrunner_powershot"}

	self.destroy_trees = {
		{"item_branches", "Iron Branch", "panorama/images/items/branches_png.vtex_c", true},
		{"furion_sprout", "Sprout", "panorama/images/spellicons/furion_sprout_png.vtex_c", true},
		{"monkey_king_tree_dance", "Tree Dance", "panorama/images/spellicons/monkey_king_tree_dance_png.vtex_c", true},
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
		{"Blocked", "General.Cancel"},
	}

	self.tango_usage = {
		"Use always",
		"Don't use, when it used",
		"Don't use, when it used and has other skill",
	}

	self.tree_height = 250

	self.tree_destroyer_enable = UI_LIB:create_bool(self.path, "Enable", false)

	self.original_tree_destroyer = Menu.FindMenu({"General", "Items manager", "Trees destroyer"}, "Enable", Enum.MenuType.MENU_TYPE_BOOL)

	self.tree_destroyer_trees = {}
	self.loaded_icons = {}

	for _, tree_info in pairs(self.destroy_trees) do
		local whereAt = table.combine(self.path, {tree_info[2]})
		self.tree_destroyer_trees[tree_info[1]] = UI_LIB:create_bool(whereAt, "Enable", tree_info[4])
		self.tree_destroyer_trees[tree_info[1].."_destroy"] = UI_LIB:create_multiselect(whereAt, "Destroy abilities", self.destroy_abilities, false)
		self.tree_destroyer_trees[tree_info[1].."_tango_usage"] = UI_LIB:create_combo(whereAt, "Tango usage", self.tango_usage, 2)
		self.tree_destroyer_trees[tree_info[1].."_tango_usage"]:set_icon("panorama/images/items/tango_png.vtex_c")
		self.loaded_icons[tree_info[1]] = Renderer.LoadImage(tree_info[3])
		UI_LIB:set_tab_icon(whereAt, tree_info[3])
	end

	self.tree_destroyer_trees["furion_sprout_mode"] = UI_LIB:create_combo(table.combine(self.path, "Sprout"), "Priority", self.furion_sprout_behavior, 1)
	self.tree_destroyer_trees["furion_sprout_mode"]:set_icon("~/MenuIcons/star.png")

	self.tree_destroyer_trees["monkey_king_tree_dance"]:set_tip("Predicts MK position if he was seen while jumping\nIt's impossible to determine 100% accurate MK position")

	for _, destroy_info in pairs(self.destroy_abilities) do
		self.loaded_icons[destroy_info[1]] = Renderer.LoadImage(destroy_info[2])
	end

	self.tree_destroyer_notifications = UI_LIB:create_bool(self.path, "Notification", true)
	self.tree_destroyer_notifications:set_icon("~/MenuIcons/Notifications/alarm.png")

	self.tree_destroyer_sound_notifications = UI_LIB:create_combo(self.path, "Sound Notification", table.map(self.sound_notifications, function(_, info) return info[1] end), 1)
	self.tree_destroyer_sound_notifications:set_icon("~/MenuIcons/volume.png")

	UI_LIB:set_tab_icon(self.path, "~/MenuIcons/utils_wheel.png")

	self.listeners = {}

	self.used_items = {}
	self.used_particles = {}
	self.mk_particles = {}
	self.mk_info = {}

	self.destroying = false

	if self:IsEnabled() then
		self.listeners["AbilityUsageHeroEnemy"] = true
	end
end

function TreeDestroyerAddon:IsEnabled()
	return self.tree_destroyer_enable:get_value() and (self.original_tree_destroyer == 0 or Menu.IsEnabled(self.original_tree_destroyer))
end

function TreeDestroyerAddon:GetTreeDanceMaxHeight(ent)
	local tree_dance = ent:GetAbility("monkey_king_tree_dance")
	if tree_dance and tree_dance:GetLevel() > 0 then
		return tree_dance:GetLevelSpecialValueFor("perched_spot_height")
	end
	return 192
end
function TreeDestroyerAddon:GetTreeDanceSpeed(ent)
	return 1405
end

function TreeDestroyerAddon:GetTreeDanceMaxDuration(ent)
	local tree_dance = ent:GetAbility("monkey_king_tree_dance")
	if tree_dance and tree_dance:GetLevel() > 0 then
		return tree_dance:GetCastRange()/self:GetTreeDanceSpeed()
	end
	return 0.89
end

function TreeDestroyerAddon:OnUpdate()
	if not self:IsEnabled() then return end
	local tick = self:GetTick()
	if tick % 2 == 0 then
		for entindex, info in pairs(table.copy(self.mk_info)) do
			if info["start_position"] ~= nil and info["from_ground"] ~= nil and info["start_time"] ~= nil then
				local ent = CNPC:new(Entity.Get(entindex))
				local is_visible = ent:IsVisible()
				local start_position = info["start_position"]
				local start_height = start_position:GetZ()
				if not info["from_ground"] then
					start_height = start_height + self.tree_height
				end
				local max_height = start_height + self:GetTreeDanceMaxHeight(ent)
				local ent_pos = ent:GetAbsOrigin()
				local current_height = ent_pos:GetZ()
				local start_time = info["start_time"]
				local current_time = GameRules.GetGameTime()
				local elapsed_time = current_time - start_time
				local max_capable_duration = self:GetTreeDanceMaxDuration(ent)
				local max_duration = CalculateArcMaxDuration(start_height, max_height, current_height, elapsed_time, max_capable_duration)
				if (max_duration-elapsed_time < 0) and elapsed_time > max_capable_duration then
					self.mk_info[entindex] = nil
					return
				end
				if info["was_visible"] and (not is_visible or math.abs(start_height-current_height) < 5) then
					if is_visible and info["from_ground"] and math.abs((start_height + self.tree_height)-current_height) > 50 then
						self.mk_info[entindex] = nil
						return
					end
					local speed = self:GetTreeDanceSpeed(ent)
					local direction = ent:GetRotation():GetForward()
					local distance = speed*max_duration
					local end_pos = GetGroundPosition(start_position + direction * distance)
					local best_trees = table.combine(Trees.InRadius(end_pos, 500, true), TempTrees.InRadius(end_pos, 500))
					table.sort(best_trees, function(a, b)
						local tree_a = CEntity:new(a)
						local tree_b = CEntity:new(b)
						local tree_a_pos = tree_a:GetAbsOrigin()
						local tree_b_pos = tree_b:GetAbsOrigin()
						local points_a = (end_pos - tree_a_pos):Length2D() * ent:FindRotationAngle(tree_a_pos)
						local points_b = (end_pos - tree_b_pos):Length2D() * ent:FindRotationAngle(tree_b_pos)
						return points_a < points_b
					end)
					local tree = best_trees[1]
					if tree ~= nil then
						local tree_ent = CEntity:new(tree)
						MiniMap.Ping(tree_ent:GetAbsOrigin())
						self:TryDestroyTree({tree}, tree_ent:GetAbsOrigin(), "monkey_king_tree_dance", ent)
					end
					self.mk_info[entindex] = nil
				else
					if is_visible then
						self.mk_info[entindex]["was_visible"] = true
					end
				end
			end
		end
	end
end

function TreeDestroyerAddon:OnParticleCreate(particle)
	if particle["entity"] ~= nil then
		local ent = CNPC:new(particle["entity"])
		if ent:GetTeamNum() ~= CHero.GetLocalTeam() then
			if particle["name"] == "monkey_king_jump_trail" then
				self.mk_particles[particle["index"]] = particle["entity_id"]
				if self.mk_info[particle["entity_id"]] == nil then
					self.mk_info[particle["entity_id"]] = {}
				end
				self.mk_info[particle["entity_id"]]["start_time"] = GameRules.GetGameTime()
				return
			elseif particle["name"] == "monkey_king_jump_launch_ring" then
				if self.mk_info[particle["entity_id"]] == nil then
					self.mk_info[particle["entity_id"]] = {}
				end
				self.mk_info[particle["entity_id"]]["from_ground"] = true
				return
			elseif particle["name"] == "monkey_king_jump_treelaunch_ring" then
				if self.mk_info[particle["entity_id"]] == nil then
					self.mk_info[particle["entity_id"]] = {}
				end
				self.mk_info[particle["entity_id"]]["from_ground"] = false
				return
			end
		end
	end
	local tree_types = {
		["particles/items_fx/ironwood_tree.vpcf"] = "item_branches",
		["particles/units/heroes/hero_furion/furion_sprout.vpcf"] = "furion_sprout",
	}
	local tree_type = tree_types[particle["fullName"]]
	if tree_type == nil then return end
	local owner = nil
	local trees = {}
	if particle["entityForModifiers"] ~= nil then
		owner = CEntity:new(particle["entityForModifiers"])
	elseif tree_type == "item_branches" then
		self.used_items[particle["entity_id"]] = {tree_type=tree_type, time=GameRules.GetGameTime()}
		return
	end
	if owner ~= nil and owner:GetTeamNum() == CHero.GetLocalTeam() then return end
	if particle["entity_id"] ~= nil and particle["entity_id"] ~= -1 then
		table.insert(trees, CEntity:new(particle["entity_id"]))
	end
	if #trees == 0 then
		self.used_particles[particle["index"]] = {tree_type=tree_type, owner=owner, position=nil, radius=nil}
		return
	end
end

function TreeDestroyerAddon:OnParticleUpdateEntity(particle)
	if self.mk_particles[particle["index"]] == nil then return end
	if self.mk_info[particle["entIdx"]] == nil then
		self.mk_info[particle["entIdx"]] = {}
	end
	self.mk_info[particle["entIdx"]]["start_position"] = particle["position"]
	self.mk_particles[particle["index"]] = nil
end

function TreeDestroyerAddon:OnParticleUpdate(particle)
	if self.used_particles[particle["index"]] == nil then return end
	if particle["controlPoint"] == 0 then
		self.used_particles[particle["index"]]["position"] = particle["position"]
	elseif particle["controlPoint"] == 1 then
		self.used_particles[particle["index"]]["radius"] = particle["position"]:GetY()
	end
	if self.used_particles[particle["index"]]["position"] ~= nil and self.used_particles[particle["index"]]["radius"] ~= nil then
		local position = Vector(self.used_particles[particle["index"]]["position"]:GetX(), self.used_particles[particle["index"]]["position"]:GetY(), self.used_particles[particle["index"]]["position"]:GetZ())
		local radius = tonumber(self.used_particles[particle["index"]]["radius"])
		local tree_type = tostring(self.used_particles[particle["index"]]["tree_type"])
		local owner = self.used_particles[particle["index"]]["owner"]
		timer.Simple(0.01, function()
			self:TryDestroyTree(TempTrees.InRadius(position, radius+50), position, tree_type, owner)
		end)
		self.used_particles[particle["index"]] = nil
	end
end

function TreeDestroyerAddon:OnNPCLostItem(ability, caster, info)
	if info.GetName == "item_branches" then
		local tree_type = "item_branches"
		local current_time = GameRules.GetGameTime()
		local possible_trees = {}
		for ent, info in pairs(self.used_items) do
			if info["tree_type"] == tree_type then
				table.insert(possible_trees, {ent, info["time"]})
			end
		end
		table.sort(possible_trees, function(a, b)
			return math.abs(a[2]-current_time) < math.abs(b[2]-current_time)
		end)
		local tree = possible_trees[1]
		if tree ~= nil then
			local entities = {Entity.Get(tree[1])}
			timer.Simple(0.01, function()
				if Entity.IsEntity(entities[1]) then
					self:TryDestroyTree(entities, Entity.GetAbsOrigin(entities[1]), tree_type, caster)
				end
			end)
			self.used_items[tree[1]] = nil
		end
	end
end

function TreeDestroyerAddon:TryDestroyTree(entities, position, tree_type, owner)
	if not self:IsEnabled() then return false end
	if #entities == 0 then return false end
	local hero = CHero.GetLocal()
	if tree_type == "furion_sprout" then
		if (position - hero:GetAbsOrigin()):Length2D() > 75 then
			return false
		end
		local tree = self:GetBestTreeForFurionSprout(entities, hero)
		return self:CutDownTree(hero, tree, tree_type)
	else
		return self:CutDownTree(hero, CEntity:new(entities[1]), tree_type)
	end
end

function TreeDestroyerAddon:GetBestTreeForFurionSprout(entities, hero)
	local best_trees = {}
	local heroPos = hero:GetAbsOrigin()
	local heroHullRadius = hero:GetHullRadius()
	for _, tree in pairs(entities) do
		local treePos = Entity.GetAbsOrigin(tree)
		local rangeToTree = (treePos - heroPos):Length2D()
		local direction = (treePos - heroPos):Normalized()
		local treePosNear = GetGroundPosition(treePos + direction * (rangeToTree - heroHullRadius * 2))
		local treePosFar = GetGroundPosition(treePos + direction * (rangeToTree + heroHullRadius * 2))
		if treePosNear:GetZ() == heroPos:GetZ() and GridNav.IsTraversable(treePosNear) and treePosFar:GetZ() == heroPos:GetZ() and GridNav.IsTraversable(treePosFar) then
			local treesOnPosition = Trees.InRadius(treePos, heroHullRadius * 3, true)
			local treesOnPositionNear = Trees.InRadius(treePosNear, heroHullRadius * 2, true)
			local treesOnPositionFar = Trees.InRadius(treePosFar, heroHullRadius * 2, true)
			if #treesOnPosition <= 0 and #treesOnPositionNear <= 0 and #treesOnPositionFar <= 0 then
				local isEnoughSpaceToCross = true
				for i=4, -4, -1 do
					local angle = Angle(0, i*15, 0)
					local rotatedDirection = direction:Rotated(angle)
					local rotatedPos = GetGroundPosition(heroPos + rotatedDirection * rangeToTree)
					local rotatedPosNear = GetGroundPosition(treePos + rotatedDirection * (rangeToTree - heroHullRadius * 2))
					local rotatedPosFar = GetGroundPosition(treePos + rotatedDirection * (rangeToTree + heroHullRadius * 2))
					local treesOnRotatedPosition = Trees.InRadius(rotatedPos, heroHullRadius * 3, true)
					local treesOnRotatedPositionNear = Trees.InRadius(rotatedPosNear, heroHullRadius * 3, true)
					local treesOnRotatedPositionFar = Trees.InRadius(rotatedPosFar, heroHullRadius * 3, true)
					if rotatedPos:GetZ() ~= heroPos:GetZ() or not GridNav:IsTraversable(rotatedPos) or rotatedPosNear:GetZ() ~= heroPos:GetZ() or not GridNav.IsTraversable(rotatedPosNear) or #treesOnRotatedPosition > 0 or #treesOnRotatedPositionNear > 0 or #treesOnRotatedPositionFar > 0 then
						isEnoughSpaceToCross = false
						break
					end
				end
				if isEnoughSpaceToCross then
					table.insert(best_trees, {tree, treePos})
				end
			end
		end
	end
	local cut_option = self.tree_destroyer_trees["furion_sprout_mode"]:get_selected_index()
	if cut_option == 1 then
		table.sort(best_trees, function(a, b)
			return hero:FindRotationAngle(a[2]) < hero:FindRotationAngle(b[2])
		end)
	elseif cut_option == 2 or cut_option == 3 then
		local enemies = CHeroes.InRadius(heroPos, 900, hero:GetTeamNum(), Enum.TeamType.TEAM_ENEMY)
		table.sort(best_trees, function(a, b)
			local points_a = 0
			local points_b = 0
			for _, enemy in pairs(enemies) do
				local enemyPos = enemy:GetAbsOrigin()
				local distance_a = (enemyPos - a[2]):Length2D()
				local angle_a = AngleBetweenVectors((a[2] - heroPos):Normalized(), (enemyPos - a[2]):Normalized(), true)
				local distance_b = (enemyPos - b[2]):Length2D()
				local angle_b = AngleBetweenVectors((b[2] - heroPos):Normalized(), (enemyPos - b[2]):Normalized(), true)
				points_a = points_a + distance_a * angle_a
				points_b = points_b + distance_b * angle_b
			end
			if math.abs(points_a - points_b) < 30 then
				if cut_option == 2 then
					return hero:FindRotationAngle(a[2]) < hero:FindRotationAngle(b[2])
				elseif cut_option == 3 then
					return hero:FindRotationAngle(a[2]) > hero:FindRotationAngle(b[2])
				end
			end
			return points_a > points_b
		end)
	end
	if #best_trees > 0 then
		return CEntity:new(best_trees[1][1])
	end
	return CEntity:new(entities[1])
end

function TreeDestroyerAddon:GetUsableAbilities(hero, tree, tree_type, exceptions)
	local usable_abilities = {}
	local abilities = self.tree_destroyer_trees[tree_type.."_destroy"] ~= nil and self.tree_destroyer_trees[tree_type.."_destroy"]:get_value()
	local heroPos = hero:GetAbsOrigin()
	local treePos = tree:GetAbsOrigin()
	local rangeToTree = (treePos - heroPos):Length2D()
	for _, ability_name in pairs(abilities) do
		if not ((type(exceptions) == "table" and table.contains(exceptions, ability_name)) or (type(exceptions) == "string" and ability_name == exceptions)) then
			local ability = string.startswith(ability_name, "item_") and hero:GetItemByName(ability_name, 2) or hero:GetAbility(ability_name)
			if ability ~= nil and ability:IsCastable(hero:GetMana(), false) and ability:GetEffectiveCooldown() <= 0 then
				local cast_range = ability:GetCastRange()
				if cast_range == 0 then
					cast_range = ability:GetRadius() - 75
				end
				if cast_range + 75 >= rangeToTree then
					if self:CanUseSkill(ability, tree, tree_type) then
						table.insert(usable_abilities, ability)
					end
				end
			end
		end
	end
	return usable_abilities
end

function TreeDestroyerAddon:CanUseSkill(ability, tree, tree_type)
	local ability_name = ability:GetName()
	local caster = ability:GetCaster()
	if ability_name == "item_tango" then
		local tango_usage = self.tree_destroyer_trees[tree_type.."_tango_usage"]:get_selected_index()
		if tango_usage == 1 then
			return true
		elseif tango_usage == 2 then
			return not caster:HasModifier("modifier_tango_heal")
		elseif tango_usage == 3 then
			return not caster:HasModifier("modifier_tango_heal") or #self:GetUsableAbilities(caster, tree, tree_type, ability_name) == 0
		end
	end
	return true
end

function TreeDestroyerAddon:CutDownTree(hero, tree, tree_type)
	if self.tree_destroyer_trees[tree_type] == nil or not self.tree_destroyer_trees[tree_type]:get_value() then return false end
	local heroPos = hero:GetAbsOrigin()
	local treePos = tree:GetAbsOrigin()
	local rangeToTree = (treePos - heroPos):Length2D()
	local ability = self:GetUsableAbilities(hero, tree, tree_type)[1]
	if ability == nil then return false end
	local wait_for = self:UseAbilityOnTree(hero, ability, tree, tree_type)
	if wait_for ~= -1 then
		local this = self
		if tree_type == "furion_sprout" then
			local direction = (treePos - heroPos):Normalized()
			local a = GameRules.GetGameTime()
			timer.Simple(wait_for + GetPingDelay(), function()
				hero:MoveToInterpolated(GetGroundPosition(heroPos + direction * (rangeToTree + 200)), rangeToTree + 50, 50, 75, 0.1)
			end)
		end
		self:SendNotification(ability:GetName(), tree_type)
		return true
	end
	return false
end

function TreeDestroyerAddon:UseAbilityOnTree(hero, ability, tree, tree_type)
	local ability_name = ability:GetName()
	local heroPos = hero:GetAbsOrigin()
	local treePos = tree:GetAbsOrigin()
	local rangeToTree = (treePos - heroPos):Length2D()
	if ability:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) then
		local position = heroPos + (treePos - heroPos):Normalized() * 200
		if ability:GetTargetTeam(Enum.TargetTeam.DOTA_UNIT_TARGET_TEAM_ENEMY) then
			local pierces_bkb = ability:PiercesBKB()
			local search_range = ability:GetCastRange() - rangeToTree
			if ability_name == "muerta_dead_shot" then
				search_range = ability:GetCastRange() * ability:GetLevelSpecialValueForFloat("ricochet_distance_multiplier")
			end
			for _, enemy in pairs(CHeroes.InRadius(treePos, search_range, hero:GetTeamNum(), Enum.TeamType.TEAM_ENEMY)) do
				if pierces_bkb or not enemy:IsDebuffImmune() then
					position = treePos + (enemy:GetAbsOrigin() - treePos):Normalized() * 50
				end
			end
		end
		Player.PrepareUnitOrders(CPlayer.GetLocal().ent, Enum.UnitOrder.DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION, nil, position, ability.ent, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, hero.ent, false, true, false)
	end
	ability:Cast(tree)
	if ability:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_POINT) then
		-- weird behavior, without this it sometimes does not use ability (when player spams move order)
		Player.PrepareUnitOrders(CPlayer.GetLocal().ent, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, tree.ent, treePos, ability.ent, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, hero.ent, false, true, false)
	end
	local channel_delay = ability:HasBehavior(Enum.AbilityBehavior.DOTA_ABILITY_BEHAVIOR_CHANNELLED) and ability:GetChannelTime() or 0
	if table.contains(self.cancelable_channelings, ability:GetName()) then
		channel_delay = 0.1
		Player.PrepareUnitOrders(CPlayer.GetLocal().ent, Enum.UnitOrder.DOTA_UNIT_ORDER_STOP, nil, nil, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, hero.ent, false, true, false)
	end
	return hero:GetTimeToFacePosition(treePos) + (ability:GetCastPoint() * 1.5) + channel_delay
end

function TreeDestroyerAddon:SendNotification(destroy_type, tree_type)
	if self.tree_destroyer_notifications:get_value() then
		Renderer.DrawCenteredNotification("{&"..self.loaded_icons[tree_type].."} {#FFFFFF}destroy by {&"..self.loaded_icons[destroy_type].."}", 2)
	end
	local sound = self.sound_notifications[self.tree_destroyer_sound_notifications:get_selected_index()][2]
	if sound ~= nil then
		PlaySound(sound)
	end
end

function TreeDestroyerAddon:OnMenuOptionChange(option, oldValue, newValue)
	if option == self.tree_destroyer_enable.menu_option or option == self.original_tree_destroyer then
		if self:IsEnabled() then
			self.listeners["AbilityUsageHeroEnemy"] = true
		else
			self.listeners["AbilityUsageHeroEnemy"] = nil
		end
	end
end


ScriptAPI.Init(TreeDestroyerAddon)

return ScriptAPI