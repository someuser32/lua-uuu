local CMenu = class("CMenu", DBase)

function CMenu.static:StaticAPIs()
	return true
end

_Classes_Inherite({"Menu"}, CMenu)

return CMenu