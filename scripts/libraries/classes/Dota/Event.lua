---@class CEvent: DBase
local CEvent = class("CEvent", DBase)

---@return string[]
function CEvent.static:StaticAPIs()
	return {
		"AddListener",
	}
end

_Classes_Inherite({"Event"}, CEvent)

return CEvent