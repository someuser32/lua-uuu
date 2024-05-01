---@class CMenu: DBase
local CMenu = class("CMenu", DBase)

---@return boolean
function CMenu.static:StaticAPIs()
	return true
end

_Classes_Inherite({"Menu"}, CMenu)

return CMenu