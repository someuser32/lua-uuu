---@class CMiniMap: DBase
local CMiniMap = class("CMiniMap", DBase)

---@return boolean
function CMiniMap.static:StaticAPIs()
	return true
end

_Classes_Inherite({"MiniMap"}, CMiniMap)

return CMiniMap