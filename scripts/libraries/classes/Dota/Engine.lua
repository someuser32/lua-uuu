---@class CChat: DBase
local CEngine = class("CEngine", DBase)

---@return boolean
function CEngine.static:StaticAPIs()
	return true
end

---@param sound string
---@return boolean
function CEngine.static:PlaySound(sound)
	return self:RunScript("Game.EmitSound('"..sound.."')")
end

_Classes_Inherite({"Engine"}, CEngine)

return CEngine