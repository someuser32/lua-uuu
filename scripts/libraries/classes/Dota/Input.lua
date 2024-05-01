---@class CInput: DBase
local CInput = class("CInput", DBase)

---@return boolean
function CInput.static:StaticAPIs()
	return true
end

_Classes_Inherite({"Input"}, CInput)

return CInput