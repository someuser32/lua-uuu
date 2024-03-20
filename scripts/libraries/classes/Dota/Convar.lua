local CConvar = class("CConvar", DBase)

function CConvar.static:StaticAPIs()
	return {
		"Find",
	}
end

_Classes_Inherite({"ConVar"}, CConvar)

return CConvar