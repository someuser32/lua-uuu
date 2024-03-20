local CEvent = class("CEvent", DBase)

function CEvent.static:StaticAPIs()
	return true
end

_Classes_Inherite({"Event"}, CEvent)

return CEvent