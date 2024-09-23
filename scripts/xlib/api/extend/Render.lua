---@param info {id: string, duration: number, timer: number, hero: string, primary_text: string, primary_image: number, secondary_image: string, secondary_text: string, active: boolean, position: Vector, sound: string}
---@return {}
function Render.DrawSideNotification(info)
	return Notification(info)
end