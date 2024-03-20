local CTargetProjectile = class("CTargetProjectile", DBase)

function CTargetProjectile.static:ListAPIs()
	return {
		"GetAll",
	}
end

function CTargetProjectile.static:GetAll()
	return self:StaticAPICall("GetAll", TargetProjectiles.GetAll)
end

function CTargetProjectile:GetHandle()
	return self.ent["handle"]
end

function CTargetProjectile:GetSpeed()
	return self.ent["speed"]
end

function CTargetProjectile:GetPosition()
	return self.ent["current_position"]
end

function CTargetProjectile:GetTargetPosition()
	return self.ent["target_position"]
end

function CTargetProjectile:GetTarget()
	return self.ent["target"]
end

function CTargetProjectile:IsDodgeable()
	return self.ent["dodgeable"]
end

function CTargetProjectile:IsAttack()
	return self.ent["attack"]
end

function CTargetProjectile:IsEvaded()
	return self.ent["evaded"]
end

return CTargetProjectile