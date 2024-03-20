local CGridNav = class("CGridNav", DBase)

function CGridNav.static:StaticAPIs()
	return true
end

_Classes_Inherite({"GridNav"}, CGridNav)

return CGridNav