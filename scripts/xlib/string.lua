---@param str string
---@param sep string?
---@return string[]
function string.split(str, sep)
	if sep == nil then sep = "%s" end
	local match = sep ~= "" and "([^"..sep.."]+)" or "."
	local t = {}
	for s in string.gmatch(str, match) do
		table.insert(t, s)
	end
	return t
end

---@param str string
---@param find string
---@return boolean
function string.startswith(str, find)
	return string.sub(str, 1, string.len(find)) == find
end

---@param str string
---@param find string
---@return boolean
function string.endswith(str, find)
	return string.sub(str, string.len(str)-string.len(find)+1, string.len(str)) == find
end

---@param str string
---@param every boolean?
---@return string
function string.capitalize(str, every)
	if every then
		local s = ""
		for _, st in pairs(string.split(str, " ")) do
			s = s..string.capitalize(st).." "
		end
		return string.sub(s, 1, #s-1)
	end
    return string.upper(string.sub(str, 1, 1))..string.lower(string.sub(str, 2))
end