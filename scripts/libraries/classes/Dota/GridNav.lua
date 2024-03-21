local CGridNav = class("CGridNav", DBase)

function CGridNav.static:StaticAPIs()
	return true
end

function CGridNav.static:GetPathLength(origin, target, ignore_trees)
	local path = self:BuildPath(origin, target, ignore_trees ~= nil and ({ignore_trees} or {true})[1])
	local distance = 0
	for _, position in pairs(path) do
		distance = distance + (position - (path[_-1] or origin)):Length2D()
	end
	return distance
end

function CGridNav.static:GetPathDifficult(origin, target, ignore_trees)
	return #self:BuildPath(origin, target, ignore_trees ~= nil and ({ignore_trees} or {true})[1])
end

_Classes_Inherite({"GridNav"}, CGridNav)

return CGridNav