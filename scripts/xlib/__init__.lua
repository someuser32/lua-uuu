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
require("xlib/api/extend/Item")
require("xlib/api/extend/NPC")

BaseScript = require("xlib/api/base_script")

--- Fix API
-- require("xlib/api/fix")
