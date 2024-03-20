local CLinearProjectile = class("CLinearProjectile", DBase)

function CLinearProjectile.static:ListAPIs()
	return {
		"GetAll",
	}
end

function CLinearProjectile.static:GetAll()
	return self:StaticAPICall("GetAll", LinearProjectiles.GetAll)
end

function CLinearProjectile:GetHandle()
	return self.ent["handle"]
end

function CLinearProjectile:GetMaxDistance()
	return self.ent["max_dist"]
end

function CLinearProjectile:GetMaxSpeed()
	return self.ent["max_speed"]
end

function CLinearProjectile:GetPosition()
	return self.ent["position"]
end

function CLinearProjectile:GetStartPosition()
	return self.ent["start_position"]
end

function CLinearProjectile:GetVelocity()
	return self.ent["velocity"]
end

return CLinearProjectile