if Log ~= nil then
	function print(...)
		if table.length({...}) == 0 then
			return Log.Write("nil")
		end
		return Log.Write(table.concat(table.values(table.map({...}, function(k, v)
			return tostring(v)
		end)), "\t"))
	end
end