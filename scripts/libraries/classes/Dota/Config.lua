local CConfig = class("CConfig", DBase)

function CConfig:StaticAPIs()
	return true
end

_Classes_Inherite({"Config"}, CConfig)

return CConfig