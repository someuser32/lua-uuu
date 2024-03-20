local CInput = class("CInput", DBase)

function CInput.static:StaticAPIs()
	return true
end

_Classes_Inherite({"Input"}, CInput)

return CInput