local CParticleManager = class("CParticle", DBase)

function CParticleManager.static:StaticAPIs()
	return true
end

function CParticleManager.static:DrawAlert(position, radius, duration, color, dotted, filled)
	local fx = self:Create("materials/alert_range.vpcf", Enum.ParticleAttachment.PATTACH_WORLDORIGIN, nil)
	self:SetControlPoint(fx, 0, position)
	self:SetControlPoint(fx, 1, Vector(color[1], color[2], color[3]))
	self:SetControlPoint(fx, 2, Vector(radius, 185, filled and 150 or 0))
	self:SetControlPoint(fx, 3, Vector(dotted and 100 or 0, 0, 0))
	Timers:CreateTimer(duration, function()
		self:Destroy(fx)
	end, self)
	return fx
end

_Classes_Inherite({"Particle"}, CParticleManager)

return CParticleManager