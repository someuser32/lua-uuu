local SmokeAbuse = {}

local INVENTORY_NO_EXTRA = {XHelpers.XItem.ItemSlot.SLOT_1, XHelpers.XItem.ItemSlot.SLOT_2, XHelpers.XItem.ItemSlot.SLOT_3, XHelpers.XItem.ItemSlot.SLOT_4, XHelpers.XItem.ItemSlot.SLOT_5, XHelpers.XItem.ItemSlot.SLOT_6}
local STASH = {XHelpers.XItem.ItemSlot.STASH_1, XHelpers.XItem.ItemSlot.STASH_2, XHelpers.XItem.ItemSlot.STASH_3, XHelpers.XItem.ItemSlot.STASH_4, XHelpers.XItem.ItemSlot.STASH_5, XHelpers.XItem.ItemSlot.STASH_6}

function SmokeAbuse:Init()
	self.menu = Menu.Create("Miscellaneous", "In Game", "Smoke")
	self.menu:Image(ZRender:get_ability_icon_path("item_smoke_of_deceit"))

	self.menu_main = self.menu:Create("Main")

	self.menu_script = self.menu_main:Create("Instant Use Abuse", Enum.GroupSide.FullWidth)

	self.mode = self.menu_script:Combo("Mode", {"Disabled", "Pickup", "Use"})

	self.smoke_drop_ref = nil
	self.smoke_drop_ref_last = nil
	self.smoke_pickup = nil
end

---@param npc CNPC
function SmokeAbuse:OnUnitInventoryUpdated(npc)
	local mode = self.mode:Get()

	if mode == 0 then
		return
	end

	if npc ~= LIB_HEROES_DATA.my_hero.ref or not LIB_HEROES_DATA.my_hero:is_alive() then
		return
	end

	if LIB_HEROES_DATA.item_by_slot[npc] == nil then
		return
	end

	local free_inventory_slot = nil

	for _, slot in pairs(XHelpers.XItem.InventorySearch.BACKPACK) do
		if LIB_HEROES_DATA.item_by_slot[npc][slot] == nil then
			free_inventory_slot = slot
			break
		end
	end

	if free_inventory_slot == nil then
		for _, slot in pairs(INVENTORY_NO_EXTRA) do
			if LIB_HEROES_DATA.item_by_slot[npc][slot] == nil then
				free_inventory_slot = slot
				break
			end
		end
	end

	if self.smoke_pickup then
		if mode == 1 then
			if free_inventory_slot ~= nil then
				for _, slot in pairs(XHelpers.XItem.InventorySearch.INVENTORY_BACKPACK) do
					local item = LIB_HEROES_DATA.item_by_slot[npc][slot]

					if item ~= nil then
						if item.name == "item_smoke_of_deceit" then
							self.smoke_pickup = nil

							if item.ref == self.smoke_drop_ref_last then
								if slot < free_inventory_slot then
									Player.PrepareUnitOrders(LIB_HEROES_DATA.my_hero.player_ref, Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_ITEM, free_inventory_slot, Vector(), item.ref, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, LIB_HEROES_DATA.my_hero.ref, false, false, false, false, "smoke_abuse_swap")
								end
							end

							break
						end
					end
				end
			end
		elseif mode == 2 then
			for _, slot in pairs(XHelpers.XItem.InventorySearch.INVENTORY_BACKPACK) do
				local item = LIB_HEROES_DATA.item_by_slot[npc][slot]

				if item ~= nil then
					if item.name == "item_smoke_of_deceit" then
						self.smoke_pickup = nil

						if Ability.GetCooldown(item.ref) <= 0 then
							Player.PrepareUnitOrders(LIB_HEROES_DATA.my_hero.player_ref, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, LIB_HEROES_DATA.my_hero.pos, item.ref, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, LIB_HEROES_DATA.my_hero.ref, false, false, false, false, "smoke_abuse_use")
						end

						break
					end
				end
			end
		end
	end

	for _, slot in pairs(STASH) do
		local item = LIB_HEROES_DATA.item_by_slot[npc][slot]

		if item ~= nil then
			if item.name == "item_smoke_of_deceit" then
				if GameRules.GetGameTime() - Item.GetPurchaseTime(item.ref) < 0.01 + LIB_HEROES_DATA.ping then
					if free_inventory_slot ~= nil then
						self.smoke_drop_ref = item.ref
					end
					self.smoke_drop_ref_last = item.ref

					Player.PrepareUnitOrders(LIB_HEROES_DATA.my_hero.player_ref, Enum.UnitOrder.DOTA_UNIT_ORDER_DROP_ITEM, nil, LIB_HEROES_DATA.my_hero.pos, item.ref, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, LIB_HEROES_DATA.my_hero.ref, false, false, false, false, "smoke_abuse_drop")

					break
				end
			end
		end
	end
end

---@param entity CEntity
function SmokeAbuse:OnEntityCreate(entity)
	if self.smoke_drop_ref ~= nil then
		if PhysicalItems.Contains(entity) then
			XHelpers.Timers:CreateTimer(function()
				if not PhysicalItems.Contains(entity) then
					return
				end

				local item = PhysicalItem.GetItem(entity)

				if item == self.smoke_drop_ref then
					self.smoke_pickup = true
					Player.PrepareUnitOrders(LIB_HEROES_DATA.my_hero.player_ref, Enum.UnitOrder.DOTA_UNIT_ORDER_PICKUP_ITEM, entity, Vector(), nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, LIB_HEROES_DATA.my_hero.ref, false, false, false, false, "smoke_abuse_pickup")
					self.smoke_drop_ref = nil
				end
			end, self)
		end
	end
end

return XHelpers.WrapCallbacks(SmokeAbuse)