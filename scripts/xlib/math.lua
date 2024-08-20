Vec = {}
itertools = {}

math.randomseed(os.time())

---@param val number
---@param decimal number?
---@return number
function math.round(val, decimal)
	local exp = decimal and 10^decimal or 1
	return math.ceil(val * exp - 0.5) / exp
end

---@param lower number
---@param greater number
---@return number
function math.random_float(lower, greater)
	return lower + math.random() * (greater - lower)
end

---@param chance number
---@return boolean
function math.roll(chance)
	return math.random(0, 100) >= (100-chance)
end

---@param vector Vector | Vec2
---@param v1 Vector | Vec2
---@param v2 Vector | Vec2
---@param tolerance number?
---@return boolean
function Vec.IsBetween(vector, v1, v2, tolerance)
	tolerance = tolerance or 50
	if (vector.x >= math.max(v1.x, v2.x) + tolerance) or (vector.x <= math.min(v1.x, v2.x) - tolerance) or (vector.y <= math.min(v1.y, v2.y) - tolerance) or (vector.y >= math.max(v1.y, v2.y) + tolerance) then
		return false
	elseif v1.x == v2.x then
		return math.abs(v1.x - vector.x) < tolerance
	elseif v1.y == v2.y then
		return math.abs(v1.y - vector.y) < tolerance
	end
	return math.abs(((v2.x - v1.x) * (v1.y - vector.y)) - ((v1.x - vector.x) * (v2.y - v1.y))) / math.sqrt((v2.x - v1.x) * (v2.x - v1.x) + (v2.y - v1.y) * (v2.y - v1.y)) < tolerance
end

---@param v1 Vector | Vec2
---@param v2 Vector | Vec2
---@param not_min boolean?
---@return number
function Vec.AngleBetween(v1, v2, not_min)
	local angle = math.abs(math.deg(math.atan(v1.x, v1.y) - math.atan(v2.x, v2.y)))
	if not not_min then
		if angle > 180 then
			return 360 - angle
		end
	end
	return angle
end

---@param start_height number
---@param max_height number
---@param duration number
---@return [number, number]
function Vec.calculate_arc(start_height, max_height, duration)
	if max_height < start_height then
		max_height = start_height+0.01
	end
	if max_height <= 0 then
		max_height = 0.01
	end
	local duration_end = (1 + math.sqrt(1 - start_height/max_height))/2
	return {4*max_height*duration_end/duration, 4*max_height*duration_end*duration_end/(duration*duration)}
end

---@param start_height number
---@param max_height number
---@param duration number
---@param current number
---@return number
function Vec.calculate_arc_for_time(start_height, max_height, duration, current)
	local const1, const2 = table.unpack(Vec.calculate_arc(start_height, max_height, duration))
	current = math.min(current, duration)
	local height = const1 * current - const2*current*current
	return math.max(start_height, height)
end

---@param start_height number
---@param max_height number
---@param current_height number
---@param current number
---@param duration_threshold number
---@return number?
function Vec.calculate_arc_max_duration(start_height, max_height, current_height, current, duration_threshold)
	local current_duration = math.max(0, current/2)
	local max_durations = {}
	while current_duration < duration_threshold do
		current_duration = current_duration + 0.01
		local height = Vec.calculate_arc_for_time(start_height, max_height, current_duration, current)
		table.insert(max_durations, {current_duration, math.abs(height-current_height)})
	end
	table.sort(max_durations, function(a, b)
		return a[2] < b[2]
	end)
	return max_durations[1] ~= nil and max_durations[1][1] or nil
end

---@param range number
---@return Vector
function Vec.random(range)
	local angle = Angle(math.random(0, 360), math.random(0, 360), 0)
	return angle:GetForward() * range
end

---@param range number
---@return Vec2
function Vec.random2(range)
	local vec = Vec.random(range)
	return Vec2(vec.x, vec.y)
end

---@param n any[]
---@param k number
---@return any[]
function itertools.combinations(n, k)
	local result = {}
    local function backtrack(start, combo)
        if #combo == k then
            table.insert(result, {table.unpack(combo)})
            return
        end
        for i=start, #n do
            table.insert(combo, n[i])
            backtrack(i + 1, combo)
            table.remove(combo)
        end
    end
    backtrack(1, {})
    return result
end