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

-- ---@type UILib
-- UILib = require("xlib/ui")

-- Extend Umbrella API

require("xlib/api/extend/Ability")
require("xlib/api/extend/Entity")
require("xlib/api/extend/Enum")
require("xlib/api/extend/GameRules")
require("xlib/api/extend/Heroes")
require("xlib/api/extend/Item")
require("xlib/api/extend/NPC")
require("xlib/api/extend/Particle")
require("xlib/api/extend/Player")
require("xlib/api/extend/World")
require("xlib/api/extend/util")

---@type KVLib
KVLib = require("xlib/keyvalues")

require("xlib/panels")

-- Extend Umbrella API (postinit)
require("xlib/api/extend/GameLocalizer")

BaseScript = require("xlib/api/base_script")

--- Fix API
-- require("xlib/api/fix")
