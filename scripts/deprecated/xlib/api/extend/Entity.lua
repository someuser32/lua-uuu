---@param entity userdata
---@return boolean
function Entity.IsLotusPool(entity)
	return Entity.GetClassName(entity) == "C_DOTA_BaseNPC_MangoTree"
end

---@param entity userdata
---@return boolean
function Entity.IsTree(entity)
	return Entity.IsTempTree(entity) or Entity.IsMapTree(entity)
end

---@param entity userdata
---@return boolean
function Entity.IsMapTree(entity)
	return Entity.GetClassName(entity) == "C_DOTA_MapTree"
end

---@param entity userdata
---@return boolean
function Entity.IsTempTree(entity)
	return Entity.GetClassName(entity) == "C_DOTA_TempTree"
end