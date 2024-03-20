local CFogOfWar = class("CFogOfWar", DBase)

function CFogOfWar.static:StaticAPIs()
	return true
end

_Classes_Inherite({"FogOfWar"}, CFogOfWar)

return CFogOfWar