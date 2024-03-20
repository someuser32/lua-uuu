local DBase = class("DBase")

function DBase:initialize(ent, args)
	self.ent = ent
	if type(args) == "table" then
		for key, value in pairs(args) do
			self[key] = value
		end
	end
end

function DBase:__eq(ent2)
	return self.ent == (ent2.ent ~= nil and ent2.ent or ent2)
end

function DBase:IsClass()
	return true
end

function DBase.static:StaticAPIs()
	return nil
end

function DBase.static:ListAPIs()
	return {}
end

function DBase.static:GetType(func_name, val)
	if val == nil then
		return nil
	end
	local function is_vector(v)
		local val_meta = getmetatable(v)
		return val_meta ~= nil and (val_meta.Length2D ~= nil or val_meta.GetVectors ~= nil)
	end
	if (type(val) == "userdata" and not is_vector(val)) or (type(val) == "table" and type(table.values(val)[1]) == "userdata" and not is_vector(table.values(val)[1])) then
		return self
	end
end

function DBase.static:Factory(func_name, obj, ...)
	if type(obj.new) == "function" then
		return obj:new(...)
	end
	return obj
end

function DBase.static:TypeCast(func_name, val)
	local val_type = self:GetType(func_name, val)
	if val_type ~= nil then
		val_type = class[val_type] or val_type
		if table.contains(self:ListAPIs(), func_name) then
			if type(val) == "table" then
				return table.map(val, function(k, v) return self:Factory(func_name, val_type, v) end)
			end
		end
		return self:Factory(func_name, val_type, val)
	end
	return val
end

function DBase:APICall(func_name, func, ...)
	local args = {...}
	for _, arg in pairs(args) do
		if type(arg) == "table" and arg.IsClass ~= nil and arg:IsClass() then
			args[_] = arg.ent
		end
	end
	return self.class:TypeCast(func_name, func(self.ent, table.unpack(args)))
end

function DBase.static:StaticAPICall(func_name, func, ...)
	local args = {...}
	for _, arg in pairs(args) do
		if type(arg) == "table" and arg.IsClass ~= nil and arg:IsClass() then
			args[_] = arg.ent
		end
	end
	return table.unpack(table.map({func(table.unpack(args))}, function(_, val) return self:TypeCast(func_name, val) end))
end

return DBase