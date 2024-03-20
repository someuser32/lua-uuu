local CChat = class("CChat", DBase)

function CChat.static:StaticAPIs()
	return {
		"GetChannels",
	}
end

function CChat.static:ListAPIs()
	return {
		"GetChannels",
	}
end

_Classes_Inherite({"Chat"}, CChat)

return CChat