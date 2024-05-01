---@class CConvar: DBase
local CConvar = class("CConvar", DBase)

---@return string[]
function CConvar.static:StaticAPIs()
	return {
		"Find",
	}
end

_Classes_Inherite({"ConVar"}, CConvar)

return CConvar