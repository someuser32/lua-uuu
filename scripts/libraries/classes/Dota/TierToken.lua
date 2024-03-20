local CTierToken = class("CTierToken", DBase)

function CTierToken.static:StaticAPIs()
	return true
end

_Classes_Inherite({"TierToken"}, CTierToken)

return CTierToken