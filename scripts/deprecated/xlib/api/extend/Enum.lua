---@enum Enum.ItemSlot
Enum.ItemSlot = {
	SLOT_1 = 0,
	SLOT_2 = 1,
	SLOT_3 = 2,
	SLOT_4 = 3,
	SLOT_5 = 4,
	SLOT_6 = 5,
	SLOT_7 = 6,
	SLOT_8 = 7,
	SLOT_9 = 8,
	STASH_1 = 9,
	STASH_2 = 10,
	STASH_3 = 11,
	STASH_4 = 12,
	STASH_5 = 13,
	STASH_6 = 14,
	TP_SCROLL = 15,
	NEUTRAL_SLOT = 16,
	TRANSIENT_ITEM = 17,
	TRANSIENT_RECIPE = 18,
	TRANSIENT_CAST_ITEM = 20,
}

---@enum Enum.InventorySearch
Enum.InventorySearch = {
	INVENTORY = {Enum.ItemSlot.SLOT_1, Enum.ItemSlot.SLOT_2, Enum.ItemSlot.SLOT_3, Enum.ItemSlot.SLOT_4, Enum.ItemSlot.SLOT_5, Enum.ItemSlot.SLOT_6, Enum.ItemSlot.TP_SCROLL, Enum.ItemSlot.NEUTRAL_SLOT},
	INVENTORY_BACKPACK = {Enum.ItemSlot.SLOT_1, Enum.ItemSlot.SLOT_2, Enum.ItemSlot.SLOT_3, Enum.ItemSlot.SLOT_4, Enum.ItemSlot.SLOT_5, Enum.ItemSlot.SLOT_6, Enum.ItemSlot.SLOT_7, Enum.ItemSlot.SLOT_8, Enum.ItemSlot.SLOT_9, Enum.ItemSlot.TP_SCROLL, Enum.ItemSlot.NEUTRAL_SLOT},
	INVENTORY_STASH = {Enum.ItemSlot.SLOT_1, Enum.ItemSlot.SLOT_2, Enum.ItemSlot.SLOT_3, Enum.ItemSlot.SLOT_4, Enum.ItemSlot.SLOT_5, Enum.ItemSlot.SLOT_6, Enum.ItemSlot.SLOT_7, Enum.ItemSlot.SLOT_8, Enum.ItemSlot.SLOT_9, Enum.ItemSlot.TP_SCROLL, Enum.ItemSlot.NEUTRAL_SLOT, Enum.ItemSlot.STASH_1, Enum.ItemSlot.STASH_2, Enum.ItemSlot.STASH_3, Enum.ItemSlot.STASH_4, Enum.ItemSlot.STASH_5, Enum.ItemSlot.STASH_6},
	BACKPACK = {Enum.ItemSlot.SLOT_7, Enum.ItemSlot.SLOT_8, Enum.ItemSlot.SLOT_9},
}

---@enum Enum.LocaleFlags
Enum.LocaleFlags = {
	UNKNOWN = 0,
	OWNER = 2^1,
	OWNER_TABLE = 2^2,
}