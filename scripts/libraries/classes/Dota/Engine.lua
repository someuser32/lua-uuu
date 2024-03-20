local CEngine = class("CEngine", DBase)

function CEngine.static:StaticAPIs()
	return true
end

function CEngine.static:PlaySound(sound)
	return self:RunScript("Game.EmitSound('"..sound.."')")
end

_Classes_Inherite({"Engine"}, CEngine)

return CEngine