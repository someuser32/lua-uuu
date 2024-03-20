local CGC = class("CGC", DBase)

function CGC.static:StaticAPIs()
	return true
end

_Classes_Inherite({"GC"}, CGC)

return CGC