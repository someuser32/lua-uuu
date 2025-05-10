if Log ~= nil then

---@param ... any
---@return nil
function print(...)
	local args = {...}

	if #args == 0 then
		return Log.Write("nil")
	end

	local text = ""
	for _, v in ipairs(args) do
		if _ > 1 then
			text = text .. "\t"
		end
		text = text .. tostring(v)
	end

	return Log.Write(text)
end

end

local function _deepprint(t, indent, seen)
	indent = indent or ""
    seen = seen or {}

	if type(t) == "table" and not seen[t] then
        seen[t] = true
    end

	local text = indent .. "{"

    for k, v in pairs(t) do
        if type(v) == "table" then
			if seen[v] then
				text = text .. "\n" .. indent .. "\t" .. tostring(k) .. "\t= " .. tostring(v) .. " (table, already seen)"
			else
				text = text .. "\n" .. indent .. "\t" .. tostring(k) .. "\t= " .. tostring(v) .. " (table)" .. "\n" .. _deepprint(v, indent .. "\t", seen)
			end
		elseif type(v) == "string" then
            text = text .. "\n" .. indent .. "\t" .. tostring(k) .. "\t= " .. "\"" .. v .. "\" (string)"
        else
            text = text .. "\n" .. indent .. "\t" .. tostring(k) .. "\t= " .. tostring(v) .. " (" .. type(v) .. ")"
        end
    end

    text = text .. "\n" .. indent .. "}"

	return text
end

function deepprint(t)
	if type(t) ~= "table" then
		return print(t)
	end
    return print(_deepprint(t))
end