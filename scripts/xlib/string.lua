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
		return string.sub(string.gsub(" "..str, "%W%l", string.upper), 2)
	end
    return (string.gsub(str, "^%l", string.upper))
end