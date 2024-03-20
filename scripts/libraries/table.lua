function table.copy(t)
	if type(t) ~= "table" then return {} end
	local result = {}
	for k,v in pairs(t) do
		result[k] = v
	end
	return result
end

-- function table.copy(o)
-- 	if o == nil then return nil end
-- 	if type(o) == "table" and o.class ~= nil and o.class.name ~= nil then return o end
-- 	local no = {}
-- 	for k, v in next, o, nil do
-- 		k = (type(k) == 'table') and table.copy(k) or k
-- 		v = (type(v) == 'table') and table.copy(v) or v
-- 		no[k] = v
-- 	end
-- 	return no
-- end

function table.any(t)
	if type(t) ~= "table" then return false end
	for k,v in pairs(t) do
		if v == true then
			return true
		end
	end
	return false
end

function table.all(t)
	if type(t) ~= "table" then return false end
	for k,v in pairs(t) do
		if v == false then
			return false
		end
	end
	return #table.values(t) > 0
end

function table.removeElement(t, el)
	local pos = table.find(t, el)
	table.remove(t, pos)
	return pos
end

function table.find(t, e)
	for k,v in pairs(t) do
		if v == e then
			return k
		end
	end
end

function table.finddeep(t, e)
	for k,v in pairs(t) do
		if (type(v) ~= "table" or type(e) ~= "table") and v == e then
			return k
		elseif type(v) == "table" and type(e) == "table" and table.equals(v, e) then
			return k
		end
	end
end

function table.containsdeep(t, e)
	for k,v in pairs(t) do
		if (type(v) ~= "table" or type(e) ~= "table") and v == e then
			return true
		elseif type(v) == "table" and type(e) == "table" and table.equals(v, e) then
			return true
		end
	end
	return false
end

function table.contains(t, e)
	for k, v in pairs(t) do
		if v == e then
			return true
		end
	end
	return false
end

function table.equals(t1, t2, ignore_mt)
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not table.equals(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not table.equals(v1,v2) then return false end
	end
	return true
end

function table.merge(t1, t2)
	local t = table.copy(t1)
	if type(t2) == "table" then
		for k, v in pairs(t2) do
			t[k] = v
		end
	end
	return t
end

function table.combine(t1, t2)
	local t = table.copy(t1)
	for k, v in pairs(type(t2) == "table" and t2 or {t2}) do
		table.insert(t, v)
	end
	return t
end

function table.filter(t, fc)
	local tt = {}
	for k,v in pairs(t) do
		-- if pcall(fc, k, v) == true and fc(k, v) == true then
		if fc(k, v) == true then
			tt[k] = v
		end
	end
	return tt
end

function table.keys(t)
	local keys = {}
	for k,v in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

function table.values(t)
	local values = {}
	for k,v in pairs(t) do
		table.insert(values, v)
	end
	return values
end

function table.length(t)
	return #table.values(t)
end

function table.map(t, fc)
	local tt = {}
	for k,v in pairs(t) do
		-- if pcall(fc, k, v) == true then
			tt[k] = fc(k, v)
		-- end
	end
	return tt
end

function table.alltypeof(t, typ)
	for k, v in pairs(t) do
		if type(v) ~= typ then
			return false
		end
	end
	return table.length(t) > 0
end

function table.unzip(t, max_level, current_level)
	local tt = {}
	for k,v in pairs(t) do
		if type(v) == "table" and (current_level == nil or max_level == nil or current_level <= max_level) then
			for kk,vv in pairs(table.unzip(v, max_level, (current_level or 1) + 1)) do
				table.insert(tt, vv)
			end
		else
			table.insert(tt, v)
		end
	end
	return tt
end