local CHTTP = class("CHTTP", DBase)

function CHTTP.static:StaticAPIs()
	return true
end

_Classes_Inherite({"HTTP"}, CHTTP)

return CHTTP