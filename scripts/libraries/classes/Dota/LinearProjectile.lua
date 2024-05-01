---@class CLinearProjectile: DBase
local CLinearProjectile = class("CLinearProjectile", DBase)

---@return string[]
function CLinearProjectile.static:ListAPIs()
	return {
		"GetAll",
	}
end

---@return LinearProjectile[]
function CLinearProjectile.static:GetAll()
	return self:StaticAPICall("GetAll", LinearProjectiles.GetAll)
end

---@return integer
function CLinearProjectile:GetHandle()
	return self.ent["handle"]
end

---@return number
function CLinearProjectile:GetMaxDistance()
	return self.ent["max_dist"]
end

---@return number
function CLinearProjectile:GetMaxSpeed()
	return self.ent["max_speed"]
end

---@return Vector
function CLinearProjectile:GetPosition()
	return self.ent["position"]
end

---@return Vector
function CLinearProjectile:GetStartPosition()
	return self.ent["start_position"]
end

---@return Vector
function CLinearProjectile:GetVelocity()
	return self.ent["velocity"]
end

return CLinearProjectile