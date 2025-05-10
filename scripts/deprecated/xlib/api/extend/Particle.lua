---@param position Vector
---@param radius number
---@param duration number
---@param color Color
---@param dotted boolean?
---@param filled boolean?
---@return integer
function Particle.DrawAlert(position, radius, duration, color, dotted, filled)
	local fx = Particle.Create("materials/alert_range.vpcf", Enum.ParticleAttachment.PATTACH_WORLDORIGIN, nil)
	Particle.SetControlPoint(fx, 0, position)
	Particle.SetControlPoint(fx, 1, Vector(color.r, color.g, color.b))
	Particle.SetControlPoint(fx, 2, Vector(radius, 185, filled and 150 or 0))
	Particle.SetControlPoint(fx, 3, Vector(dotted and 100 or 0, 0, 0))
	Timers:CreateTimer(duration, function()
		Particle.Destroy(fx)
	end)
	return fx
end