local CSteam = class("CSteam", DBase)

function CSteam.static:StaticAPIs()
	return true
end

_Classes_Inherite({"Steam"}, CSteam)

return CSteam