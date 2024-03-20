local CGlobalVars = class("CGlobalVars", DBase)

function CGlobalVars.static:StaticAPIs()
	return true
end

_Classes_Inherite({"GlobalVars"}, CGlobalVars)

return CGlobalVars