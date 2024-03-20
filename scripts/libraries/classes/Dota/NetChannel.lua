local CNetChannel = class("CNetChannel", DBase)

function CNetChannel.static:StaticAPIs()
	return true
end

function CNetChannel.static:GetPingDelay()
	return self:GetLatency(Enum.Flow.MAX_FLOWS) * 2 + 0.1
end

_Classes_Inherite({"NetChannel"}, CNetChannel)

return CNetChannel