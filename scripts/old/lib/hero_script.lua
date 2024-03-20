local class = require("lib/middleclass")
local ScriptAPI = require("lib/script")()

require("lib/lib")

local HeroScript = class("HeroScript")

function HeroScript:initialize(hero_name)
	self.hero_name = hero_name
	self.menu_options = {}
	self.is_menu_ready = false
	self:UpdatePath()
end

function HeroScript:OnGameStart()
	self:UpdatePath()
end

function HeroScript:OnGameEnd()
	self:UpdatePath()
end

function HeroScript:UpdatePath()
	if CHero.GetLocalName() == self.hero_name then
		local new_path = {"Hero Specific", "Current hero"}
		if not table.equals(self.base_path, new_path) then
			self.base_path = new_path
			self:OnPathUpdated()
		end
		self.base_path = new_path
	else
		local new_path = {"Hero Specific", LocalizeAttribute(KVLib:GetHeroAttribute(self.hero_name)), LocalizeHeroName(self.hero_name)}
		if not table.equals(self.base_path, new_path) then
			self.base_path = new_path
			self:OnPathUpdated()
		end
		self.base_path = new_path
	end
	self.actual_path = table.combine(self.base_path, self.path or {})
end

function HeroScript:OnPathUpdated()
	self:DestroyMenu()
	if not self.base_path then return end
	self:BuildMenu()
end

function HeroScript:BuildMenu()
	if self.base_path == nil then
		self:UpdatePath()
		return self:BuildMenu()
	end
	for _, info in pairs(self.menu_options) do
		if info["option"] == nil then
			local args = info["args"]
			local whereAt = 1
			for i=1, #args do
				if type(args[i]) == "table" and type(args[i][1]) == "string" then
					whereAt = i
					break
				end
			end
			args[whereAt] = table.combine(self.base_path, args[whereAt])
			info["option"] = info["function"](table.unpack(args))
			self[info["name"]] = info["option"]
			if info["icon"] ~= nil then
				info["option"]:set_icon(info["icon"])
			end
		end
	end
	UI_LIB:set_tab_icon(self.base_path, "panorama/images/heroes/icons/"..self.hero_name.."_png.vtex_c")
	self.is_menu_ready = true
end

function HeroScript:DestroyMenu()
	for _, info in pairs(self.menu_options) do
		if info["option"] ~= nil then
			Menu.RemoveOption(info["option"])
			info["option"] = nil
			self[info["name"]] = nil
		end
	end
	self.is_menu_ready = false
end

function HeroScript:create_option(create_option, name, icon, args)
	table.insert(self.menu_options, {["name"] = name, ["function"] = create_option, ["args"] = args, ["icon"] = icon})
	if self.is_menu_ready then
		self:BuildMenu()
	end
end

function HeroScript:remove_option(name)
	local remove_options = {}
	for _, info in pairs(self.menu_options) do
		if info["option"] ~= nil and info["name"] == name then
			Menu.RemoveOption(info["option"])
			info["option"] = nil
			self[info["name"]] = nil
		end
		table.insert(remove_options, info)
	end
	for _, info in pairs(remove_options) do
		for i=1, #self.menu_options do
			if self.menu_options[i]["name"] == info["name"] then
				table.remove(self.menu_options, i)
				break
			end
		end
	end
end

function HeroScript:OnGameStart()
	self:UpdatePath()
end

function HeroScript:OnGameEnd()
	self:UpdatePath()
end

return {HeroScript, ScriptAPI}