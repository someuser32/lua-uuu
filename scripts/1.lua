-- return {
--     OnUpdate = function()
--         local my_hero = Heroes.GetLocal()
-- 		for _, hero in pairs(Heroes.GetAll()) do
-- 			if Entity.GetTeamNum(hero) ~= Entity.GetTeamNum(my_hero) then
-- 				Engine.ExecuteCommand("say "..tostring(math.deg(NPC.FindRotationAngle(my_hero, Entity.GetAbsOrigin(hero)))))
-- 				break
-- 			end
-- 		end
--     end
-- }

-- return {
-- 	local toggle = Menu.FindMenu({"Creeps", "Jungle Bot", "Toggle Key"}, Enum.MenuType.MENU_TYPE_HOT_KEY)
-- 	Menu.SetValue(toggle, true)
-- }

--[[
	Для нахождения длины линии, которая идет из центра квадрата под определенным углом,
	нужно знать длину стороны квадрата.
	Если длина стороны квадрата равна `s`, а угол, под которым нужно нарисовать линию,
	равен `θ` (в радианах), то длина линии будет равна `s / (2 * cos(θ/2))`.
]]

local test = {}

-- local img = Renderer.LoadImage("panorama/images/spellicons/pudge_rot_png.vtex_c")

function test.OnDraw()
	local rect_x = 200
	local rect_y = 200
	local rect_size = 64
	local rect_angles = {
		{rect_x-rect_size/2, rect_y-rect_size/2},
		{rect_x+rect_size/2, rect_y-rect_size/2},
		{rect_x+rect_size/2, rect_y+rect_size/2},
		{rect_x-rect_size/2, rect_y+rect_size/2},
	}
	-- local angle = 30

    Renderer.SetDrawColor(255, 255, 255, 255)
	Renderer.DrawOutlineRect(rect_x, rect_y, rect_size, rect_size)

	local segments = 30 -- количество сегментов для фильтра, можно изменить по желанию

    local points = {} -- таблица для хранения точек фильтра

    local angle_step = 2*math.pi / segments -- шаг угла между сегментами

    local progress = (5 - 4) / 5 -- прогресс заполнения фильтра

    -- рисуем каждый сегмент фильтра в зависимости от прогресса
    for i = 1, segments * progress do
        local angle = angle_step * i -- угол текущего сегмента
        local end_x = rect_x + rect_size * 0.5 * math.cos(angle) -- вычисляем конечную точку сегмента по X
        local end_y = rect_y + rect_size * 0.5 * math.sin(angle) -- вычисляем конечную точку сегмента по Y
        table.insert(points, {rect_x, rect_y}) -- добавляем начальную точку сегмента
        table.insert(points, {end_x, end_y}) -- добавляем конечную точку сегмента
    end

	-- DeepPrintTable(polygon)
	-- DeepPrintTable(Renderer)

	Renderer.SetDrawColor(255, 0, 0, 255)
	Renderer.DrawPolyLine(points)

	-- Renderer.DrawImage(img, rect_x, rect_y, rect_size, rect_size)
end

-- return test

local function point_lerp(x1, y1, x2, y2, t)
    local x = x1 + (x2 - x1) * t
    local y = y1 + (y2 - y1) * t
    return x, y
end

local function draw_point(x, y, size)
    Renderer.DrawFilledRect(x - size / 2, y - size / 2, size, size)
end

-- return {
--     OnDraw = function()
--         local x1, y1 = 100, 400;
--         local x2, y2 = 400, 500;


--         Renderer.SetDrawColor(255, 0, 0, 255)
--         Renderer.DrawLine(x1, y1, x2, y2)

-- 		local angle = 90
-- 		local t = (angle % 90) / 90

--         local center_x, center_y = point_lerp(x1, y1, x2, y2, t)

--         draw_point(center_x, center_y, 10)
--     end
-- }
