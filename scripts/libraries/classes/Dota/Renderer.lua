local loaded_images = {}

---@class CRenderer: DBase
local CRenderer = class("CRenderer", DBase)

CRenderer.static.SIDE_NOTIFICATION_MESSAGE_ARROW = 0
CRenderer.static.SIDE_NOTIFICATION_MESSAGE_CHARGE_OF_DARKNESS = 1
CRenderer.static.SIDE_NOTIFICATION_MESSAGE_TELEPORT = 2
CRenderer.static.SIDE_NOTIFICATION_MESSAGE_BOUNTY = 3
CRenderer.static.SIDE_NOTIFICATION_MESSAGE_STASH = 4

CRenderer.static.SIDE_NOTIFICATION_SOUND_NONE = 0
CRenderer.static.SIDE_NOTIFICATION_SOUND_ALERT = 1
CRenderer.static.SIDE_NOTIFICATION_SOUND_BUY = 2
CRenderer.static.SIDE_NOTIFICATION_SOUND_YOINK = 3

---@return boolean
function CRenderer.static:StaticAPIs()
	return true
end

---@param id any
---@param path string
---@return integer
function CRenderer.static:LoadImageWithID(id, path)
	local image = self:StaticAPICall("LoadImage", Renderer.LoadImage, path)
	loaded_images[id] = image
	return image
end

---@param path string
---@return integer
function CRenderer.static:GetOrLoadImage(path)
	local image = loaded_images[path]
	if image ~= nil then
		return image
	end
	image = self:LoadImageWithID(path, path)
	return image
end

---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@return nil
function CRenderer.static:DrawOutlineRectCentered(x, y, w, h)
	return self:StaticAPICall("DrawOutlineRect", Renderer.DrawOutlineRect, x-w/2, y-h/2, w, h)
end

---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@return nil
function CRenderer.static:DrawFilledRectCentered(x, y, w, h)
	return self:StaticAPICall("DrawFilledRect", Renderer.DrawFilledRect, x-w/2, y-h/2, w, h)
end

---@param font integer
---@param y integer
---@param text string
---@return nil
function CRenderer.static:DrawTextCentered(font, x, y, text)
	local w, h = CRenderer:GetTextSize(font, text)
	return self:StaticAPICall("DrawText", Renderer.DrawText, font, x - w/2, y - h/2, text)
end

_Classes_Inherite({"Renderer"}, CRenderer)

return CRenderer

--[[
	Renderer.DrawSideNotification(
    {
        ["image1"] = {
            ["path"] = "panorama/images/spellicons/dark_willow_bramble_maze_png.vtex_c",
            ["border"] = true,
            ["text"] = {"first line", "second line"},
        },
        ["image2"] = { ["path"] = "panorama/images/spellicons/dark_willow_cursed_crown_png.vtex_c" },
        ["duration"] = 10,
        -- MESSAGE_ARROW = 0x00000000,
        -- MESSAGE_CHARGE_OF_DARKNESS = 0x00000001,
        -- MESSAGE_TELEPORT = 0x00000002,
        -- MESSAGE_BOUNTY = 0x00000003,
        -- MESSAGE_STASH = 0x00000004,
        ["type"] = 0,
        -- SOUND_NONE = 0x00000000,
        -- SOUND_ALERT = 0x00000001,
        -- SOUND_BUY = 0x00000002,
        -- SOUND_YOINK = 0x00000003,
        ["sound"] = 1,

        ["unique_key"] = "hero_idx/particle_idx"
    }

	Renderer.DrawCenteredNotification(markdownString, duration):
    Параметры: duration [опционально] - Время жизни оповещения в секундах. Привязано к игровому времени. По умолчанию: 10;
                               markdownString - Текст оповещения. Внутри этой строки поддерживаются следующие конструкции:
                               \n - перенос строки;
                               {&imageHandler} - картинка с сохранением пропорций;
                                {#color} - изменение цвета текста, указывать в hex формате (без прозрачности);
)

]]