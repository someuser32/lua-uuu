---@class CChat: DBase
local CChat = class("CChat", DBase)

---@return string[]
function CChat.static:StaticAPIs()
	return {
		"GetChannels",
	}
end

---@return string[]
function CChat.static:ListAPIs()
	return {
		"GetChannels",
	}
end

_Classes_Inherite({"Chat"}, CChat)

return CChat