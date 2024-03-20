function string.split(str, sep)
	if sep == nil then sep = "%s" end
	local match = sep ~= "" and "([^"..sep.."]+)" or "."
	local t = {}
	for s in string.gmatch(str, match) do
		table.insert(t, s)
	end
	return t
end

function string.startswith(str, find)
	return string.sub(str, 1, string.len(find)) == find
end

function string.endswith(str, find)
	return string.sub(str, string.len(str)-string.len(find)+1, string.len(str)) == find
end

function string.capitalize(str, every)
	if every then
		return string.sub(string.gsub(" "..str, "%W%l", string.upper), 2)
	end
    return string.gsub(str, "^%l", string.upper)
end