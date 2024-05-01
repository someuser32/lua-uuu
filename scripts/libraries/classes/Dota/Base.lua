---@class DBase
local DBase = class("DBase")

---@param ent any
---@param args table?
---@return nil
function DBase:initialize(ent, args)
	self.ent = ent
	if type(args) == "table" then
		for key, value in pairs(args) do
			self[key] = value
		end
	end
end

---@param ent2 any
---@return boolean
function DBase:__eq(ent2)
	return self.ent == (ent2.ent ~= nil and ent2.ent or ent2)
end

---@return boolean
function DBase:IsClass()
	return true
end

---@return string[] | boolean | nil
function DBase.static:StaticAPIs()
	return nil
end

---@return string[] | boolean | nil
function DBase.static:ListAPIs()
	return {}
end

---@param func_name string
---@param val any
---@return string[] | any | nil
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

---@param func_name string
---@param obj any
---@return any
function DBase.static:Factory(func_name, obj, ...)
	if type(obj.new) == "function" then
		return obj:new(...)
	end
	return obj
end

---@param func_name string
---@param val any
---@return any
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

---@param func_name string
---@param func function
---@return any
function DBase:APICall(func_name, func, ...)
	local args = {...}
	for _, arg in pairs(args) do
		if type(arg) == "table" and arg.IsClass ~= nil and arg:IsClass() then
			args[_] = arg.ent
		end
	end
	return self.class:TypeCast(func_name, func(self.ent, table.unpack(args)))
end

---@param func_name string
---@param func function
---@return any
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