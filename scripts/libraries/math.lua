vector = {}

itertools = {}

math.randomseed(os.time())

function math.round(val, decimal)
	local exp = decimal and 10^decimal or 1
	return math.ceil(val * exp - 0.5) / exp
end

function math.random_float(lower, greater)
	return lower + math.random()  * (greater - lower)
end

function RollPercentage(chance)
	return math.random(0, 100) >= (100-chance)
end

function vector.is_vector_between(vector, v1, v2, tolerance)
	tolerance = tolerance or 50
	local vec_x = vector:GetX()
	local vec_y = vector:GetY()
	local v1_x = v1:GetX()
	local v1_y = v1:GetY()
	local v2_x = v2:GetX()
	local v2_y = v2:GetY()
	if (vec_x >= math.max(v1_x, v2_x) + tolerance) or (vec_x <= math.min(v1_x, v2_x) - tolerance) or (vec_y <= math.min(v1_y, v2_y) - tolerance) or (vec_y >= math.max(v1_y, v2_y) + tolerance) then
		return false
	elseif v1_x == v2_x then
		return math.abs(v1_x - vec_x) < tolerance
	elseif v1_y == v2_y then
		return math.abs(v1_y - vec_y) < tolerance
	end
	return math.abs(((v2_x - v1_x) * (v1_y - vec_y)) - ((v1_x - vec_x) * (v2_y - v1_y))) / math.sqrt((v2_x - v1_x) * (v2_x - v1_x) + (v2_y - v1_y) * (v2_y - v1_y)) < tolerance
end

function vector.angle_between_vectors(v1, v2, not_min)
	local angle = math.deg(math.atan2(v1:GetX(), v1:GetY()) - math.atan2(v2:GetX(), v2:GetY()))
	if not not_min then
		angle = math.abs(angle)
		if angle > 180 then
			return 360 - angle
		end
	end
	return angle
end

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

function vector.calculate_arc(start_height, max_height, duration)
	if max_height < start_height then
		max_height = start_height+0.01
	end
	if max_height <= 0 then
		max_height = 0.01
	end
	local duration_end = (1 + math.sqrt(1 - start_height/max_height))/2
	return {4*max_height*duration_end/duration, 4*max_height*duration_end*duration_end/(duration*duration)}
end

function vector.calculate_arc_for_time(start_height, max_height, duration, current)
	local const1, const2 = table.unpack(vector.calculate_arc(start_height, max_height, duration))
	current = math.min(current, duration)
	local height = const1 * current - const2*current*current
	return math.max(start_height, height)
end

function vector.calculate_arc_max_duration(start_height, max_height, current_height, current, duration_threshold)
	local current_duration = math.max(0, current/2)
	local max_durations = {}
	while current_duration < duration_threshold do
		current_duration = current_duration + 0.01
		local height = vector.calculate_arc_for_time(start_height, max_height, current_duration, current)
		table.insert(max_durations, {current_duration, math.abs(height-current_height)})
	end
	table.sort(max_durations, function(a, b)
		return a[2] < b[2]
	end)
	return max_durations[1] ~= nil and max_durations[1][1] or nil
end

function vector.random_vector(range)
	local angle = Angle(math.random(0, 360), math.random(0, 360), 0)
	return Vector(0, 0, 0) + angle:GetForward() * range
end