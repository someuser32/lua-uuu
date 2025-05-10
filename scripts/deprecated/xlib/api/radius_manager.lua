---@enum Enum.RadiusType
Enum.RadiusType = {
	DOTA = 1,
	SOLID_GLOW = 2,
	SOLID = 3,
	DOTTED = 4,
	FADE = 5,
	DUST = 6,
	FOG = 7,
	PULSE = 8,
	WAVES = 9,
	LINK = 10,
	INFINITY = 11,
	ROUNDED = 12,
	SLIDE = 13,
}

---@class RadiusManager
local RadiusManager = {
	particles = {},
	particle_names = {
		[Enum.RadiusType.DOTA] = "materials/ui_mouseactions/range_display.vpcf",
		[Enum.RadiusType.SOLID_GLOW] = "materials/radius_particle/glow_solid.vpcf",
		[Enum.RadiusType.SOLID] = "materials/radius_particle/solid.vpcf",
		[Enum.RadiusType.DOTTED] = "materials/radius_particle/dotted_finish.vpcf",
		[Enum.RadiusType.FADE] = "materials/radius_particle/fade_finish.vpcf",
		[Enum.RadiusType.DUST] = "materials/radius_particle/dust.vpcf",
		[Enum.RadiusType.FOG] = "materials/radius_particle/fog.vpcf",
		[Enum.RadiusType.PULSE] = "particles/new_particle_radius/new_particle_radius_1.vpcf",
		[Enum.RadiusType.WAVES] = "particles/new_particle_radius/new_particle_radius_2.vpcf",
		[Enum.RadiusType.LINK] = "particles/new_particle_radius/new_particle_radius_3.vpcf",
		[Enum.RadiusType.INFINITY] = "particles/new_particle_radius/new_particle_radius_4.vpcf",
		[Enum.RadiusType.ROUNDED] = "particles/new_particle_radius/new_particle_radius_5.vpcf",
		[Enum.RadiusType.SLIDE] = "particles/new_particle_radius/new_particle_radius_6.vpcf",
	}
}

---@param parent CMenuGroup | CMenuGearAttachment
---@param gear? boolean
---@param _type? boolean
---@param color? boolean
---@param return_parent? boolean
---@return table
function RadiusManager:CreateUI(parent, gear, _type, color, return_parent)
	local modules = {}
	local radiuses = parent
	local returned_parent = radiuses
	if gear then
		local label = parent:Label("Radius")
		label:Icon("\u{f13a}")
		radiuses = label:Gear("Settings")
		returned_parent = label
	end
	if _type then
		local types = table.keys(Enum.RadiusType)
		table.sort(types, function(a, b) return Enum.RadiusType[a] < Enum.RadiusType[b] end)
		local radius_type = radiuses:Combo("Particle", table.map(types, function(_, k) return string.capitalize((string.gsub(k, "_", " ")), true) end))
		radius_type:Icon("\u{e105}")
		table.insert(modules, radius_type)
	end
	if color then
		local radius_color = radiuses:ColorPicker("Color", Color(255, 255, 255, 255))
		radius_color:Icon("\u{f53f}")
		table.insert(modules, radius_color)
	end
	if return_parent then
		table.insert(modules, returned_parent)
	end
	return modules
end

---@param particle_type Enum.RadiusType
---@param particle_color Color
---@param radius number
---@param position_or_unit userdata | Vector
---@returns number
function RadiusManager:DrawParticle(particle_type, particle_color, radius, position_or_unit)
	local fx = Particle.Create(self.particle_names[particle_type], Enum.ParticleAttachment.PATTACH_ABSORIGIN_FOLLOW, position_or_unit)
	self.particles[fx] = {
		["type"] = particle_type,
		["color"] = particle_color,
		["radius"] = radius,
		["target"] = position_or_unit,
	}
	self:ChangeColor(fx, particle_color)
	self:ChangeRadius(fx, radius)
	Particle.SetControlPoint(fx, 3, Vector(1, 0, 0))
	return fx
end

---@param fx number
---@param particle_type Enum.RadiusType
---@returns number
function RadiusManager:ChangeType(fx, particle_type)
	Particle.Destroy(fx)
	return self:DrawParticle(particle_type, self.particles[fx]["color"], self.particles[fx]["radius"], self.particles[fx]["target"])
end

---@param fx number
---@param color Color
---@returns number
function RadiusManager:ChangeColor(fx, color)
	Particle.SetControlPoint(fx, 1, Vector(color.r, color.g, color.b))
	Particle.SetControlPoint(fx, 2, Vector(self.particles[fx]["radius"], color.a, 0))
	self.particles[fx]["color"] = color
	return fx
end

---@param fx number
---@param radius number
---@returns number
function RadiusManager:ChangeRadius(fx, radius)
	Particle.SetControlPoint(fx, 2, Vector(radius, self.particles[fx]["color"].a, 0))
	self.particles[fx]["radius"] = radius
	return fx
end

---@param fx number
---@param position_or_unit userdata | Vector
---@returns number
function RadiusManager:ChangeTarget(fx, position_or_unit)
	Particle.Destroy(fx)
	return self:DrawParticle(self.particles[fx]["type"], self.particles[fx]["color"], self.particles[fx]["radius"], position_or_unit)
end

return RadiusManager