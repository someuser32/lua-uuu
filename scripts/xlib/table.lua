---@param t table
---@return table
function table.copy(t)
	if type(t) ~= "table" then return {} end
	local result = {}
	for k,v in pairs(t) do
		result[k] = v
	end
	return result
end

---@param t boolean[]
---@return boolean
function table.any(t)
	if type(t) ~= "table" then return false end
	for k,v in pairs(t) do
		if v == true then
			return true
		end
	end
	return false
end

---@param t boolean[]
---@return boolean
function table.all(t)
	if type(t) ~= "table" then return false end
	for k,v in pairs(t) do
		if v == false then
			return false
		end
	end
	return #table.values(t) > 0
end

---@param t table
---@param el any
---@return integer
function table.removeElement(t, el)
	local pos = table.find(t, el)
	table.remove(t, pos)
	return pos
end

---@param t table
---@param e any
---@return any
function table.find(t, e)
	for k,v in pairs(t) do
		if v == e then
			return k
		end
	end
end

---@param t table
---@param e any
---@return any
function table.finddeep(t, e)
	for k,v in pairs(t) do
		if (type(v) ~= "table" or type(e) ~= "table") and v == e then
			return k
		elseif type(v) == "table" and type(e) == "table" and table.equals(v, e) then
			return k
		end
	end
end

---@param t table
---@param e any
---@return boolean
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

---@param t table
---@param ... any
---@return boolean
function table.contains(t, ...)
	local es = {...}
	for _, v in pairs(t) do
		for _, e in pairs(es) do
			if v == e then
				return true
			end
		end
	end
	return false
end

---@param t1 table
---@param t2 table
---@return boolean
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

---@param t1 table
---@param t2 table
---@return table
function table.merge(t1, t2)
	local t = table.copy(t1)
	if type(t2) == "table" then
		for k, v in pairs(t2) do
			t[k] = v
		end
	end
	return t
end

---@param t1 table
---@param t2 table
---@return table
function table.combine(t1, t2)
	local t = table.copy(t1)
	for k, v in pairs(type(t2) == "table" and t2 or {t2}) do
		table.insert(t, v)
	end
	return t
end

---@param t table
---@param fc function
---@return table
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

---@param t table
---@return table
function table.keys(t)
	local keys = {}
	for k,v in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

---@param t table
---@return table
function table.values(t)
	local values = {}
	for k,v in pairs(t) do
		table.insert(values, v)
	end
	return values
end

---@param t table
---@return number
function table.length(t)
	return #table.values(t)
end

---@param t table
---@param fc function
---@return table
function table.map(t, fc)
	local tt = {}
	for k,v in pairs(t) do
		-- if pcall(fc, k, v) == true then
			tt[k] = fc(k, v)
		-- end
	end
	return tt
end

---@param t table
---@param typ any
---@return boolean
function table.alltypeof(t, typ)
	for k, v in pairs(t) do
		if type(v) ~= typ then
			return false
		end
	end
	return table.length(t) > 0
end

---@param t table
---@param max_level number?
---@param current_level number?
---@return any
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

---@param t table
---@return number
function table.sum(t)
	local s = 0
	for k,v in pairs(t) do
		s = s + v
	end
	return s
end