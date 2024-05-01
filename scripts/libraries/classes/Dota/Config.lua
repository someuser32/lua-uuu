---@class CConfig: DBase
local CConfig = class("CConfig", DBase)

---@return boolean
function CConfig:StaticAPIs()
	return true
end

_Classes_Inherite({"Config"}, CConfig)

return CConfig