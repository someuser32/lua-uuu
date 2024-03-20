local CMiniMap = class("CMiniMap", DBase)

function CMiniMap.static:StaticAPIs()
	return true
end

_Classes_Inherite({"MiniMap"}, CMiniMap)

return CMiniMap