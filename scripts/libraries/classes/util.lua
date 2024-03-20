local statics = {
}

function _Classes_Inherite(from, to)
	local function is_static(obj, key, val)
		val = val or statics[obj]
		if type(val) == "boolean" then
			return val
		elseif type(val) == "string" then
			return val == key
		elseif type(val) == "table" then
			return table.contains(val, key)
		elseif to.StaticAPIs ~= nil then
			local new_val = to:StaticAPIs()
			if new_val ~= nil then
				return is_static(obj, key, new_val)
			end
		end
		return false
	end
	for _, object in pairs(from) do
		local object_name = tostring(object)
		local obj = type(object) == "string" and _G[object] or object
		if type(obj) == "table" then
			for obj_key, obj_value in pairs(obj) do
				if type(obj_value) == "function" then
					local func_static = is_static(object_name, obj_key)
					local function instancemethod(self, ...)
						return self:APICall(obj_key, obj_value, ...)
					end
					local function staticmethod(self, ...)
						return to:StaticAPICall(obj_key, obj_value, ...)
					end
					if func_static then
						to.static["API"..object_name..obj_key] = staticmethod
						to["API"..obj_key] = staticmethod
						if to[obj_key] == nil then
							to[obj_key] = staticmethod
						end
					else
						to["API"..object_name..obj_key] = instancemethod
						to["API"..obj_key] = instancemethod
						if to[obj_key] == nil then
							to[obj_key] = instancemethod
						end
					end
				end
			end
		else
			print("[WARNING] "..object_name.." is nil!")
		end
	end
end