---Returns `true` if the `userdata` is visible to local player.
---@param npc userdata npc to check
---@return boolean
function NPC.IsVisibleToEnemies(npc) end


PhysicalItems = {}

---@return userdata[]
function PhysicalItems.GetAll() end

---@return integer
function PhysicalItems.count() end

---@param physical_item integer
---@return userdata?
function PhysicalItems.Get(physical_item) end

---@param physical_item userdata
---@return boolean
function PhysicalItems.Contains(physical_item) end