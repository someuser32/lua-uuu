local CEvent = class("CEvent", DBase)

function CEvent.static:StaticAPIs()
	return {
		"AddListener",
	}
end

_Classes_Inherite({"Event"}, CEvent)

return CEvent