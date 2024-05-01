---@class CTargetProjectile: DBase
local CTargetProjectile = class("CTargetProjectile", DBase)

---@return string[]
function CTargetProjectile.static:ListAPIs()
	return {
		"GetAll",
	}
end

---@return CTargetProjectile[]
function CTargetProjectile.static:GetAll()
	return self:StaticAPICall("GetAll", TargetProjectiles.GetAll)
end

---@return integer
function CTargetProjectile:GetHandle()
	return self.ent["handle"]
end

---@return number
function CTargetProjectile:GetSpeed()
	return self.ent["speed"]
end

---@return Vector
function CTargetProjectile:GetPosition()
	return self.ent["current_position"]
end

---@return Vector
function CTargetProjectile:GetTargetPosition()
	return self.ent["target_position"]
end

---@return CEntity
function CTargetProjectile:GetTarget()
	return self.ent["target"]
end

---@return boolean
function CTargetProjectile:IsDodgeable()
	return self.ent["dodgeable"]
end

---@return boolean
function CTargetProjectile:IsAttack()
	return self.ent["attack"]
end

---@return boolean
function CTargetProjectile:IsEvaded()
	return self.ent["evaded"]
end

return CTargetProjectile