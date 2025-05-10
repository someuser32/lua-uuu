-- Basic

--- Extend lua

require("xlib/log")

require("xlib/math")

require("xlib/string")

require("xlib/table")

--- Add API

require("xlib/util")

-- Advanced APIs

---@type Timers
Timers = require("xlib/timers")

---@type JSON
JSON = require("xlib/json")

-- Extend Umbrella API

require("xlib/api/extend/Ability")
require("xlib/api/extend/Entity")
require("xlib/api/extend/Enum")
require("xlib/api/extend/GameRules")
require("xlib/api/extend/Heroes")
require("xlib/api/extend/Item")
require("xlib/api/extend/NetChannel")
require("xlib/api/extend/NPC")
require("xlib/api/extend/Particle")
require("xlib/api/extend/Player")
require("xlib/api/extend/Render")
require("xlib/api/extend/World")
require("xlib/api/extend/util")

---@type KVLib
KVLib = require("xlib/keyvalues")

---@type UILib
UILib = require("xlib/ui")

---@type Conditions
Conditions = require("xlib/api/conditions")

---@type LinkenBreaker
LinkenBreaker = require("xlib/api/linken_breaker")

---@type SpellReflect
SpellReflect = require("xlib/api/spell_reflect")

---@type AntiOverwatch
AntiOverwatch = require("xlib/api/anti_overwatch")

---@type Notifications
Notifications = require("xlib/api/notifications")

---@type RadiusManager
RadiusManager = require("xlib/api/radius_manager")

require("xlib/panels")

-- Extend Umbrella API (postinit)
require("xlib/api/extend/GameLocalizer")

BaseScript = require("xlib/api/base_script")

--- Fix API
-- require("xlib/api/fix")
