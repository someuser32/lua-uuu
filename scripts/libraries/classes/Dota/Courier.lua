local CCourier = class("CCourier", CNPC)

function CCourier.static:ListAPIs()
	return {
		"GetAll",
	}
end

function CCourier.static:GetAll()
	return self:StaticAPICall("GetAll", Couriers.GetAll)
end

function CCourier.static:Count()
	return self:StaticAPICall("Count", Couriers.Count)
end

function CCourier.static:Get()
	return self:StaticAPICall("Get", Couriers.Get)
end

function CCourier.static:Contains(ent)
	return self:StaticAPICall("Contains", Couriers.Contains, ent)
end

_Classes_Inherite({"Entity", "NPC", "Courier"}, CCourier)

return CCourier