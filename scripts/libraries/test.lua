-- require("libraries/__init__")

-- -- class = require("middleclass")

-- -- UILibOptionBase = require("classes/UI/OptionBase")

-- -- UILibOptionCheckbox = require("classes/UI/OptionCheckbox")

-- local checkbox = UILibOptionCheckbox:new({"test"}, "Enabled", false)

-- require("libraries/log")

-- require("libraries/util")

-- require("libraries/valve/__init__")

-- local itertools = {}

-- function itertools.combinations(n, k)
-- 	local result = {}
--     local function backtrack(start, combo)
--         if #combo == k then
--             table.insert(result, {table.unpack(combo)})
--             return
--         end
--         for i=start, #n do
--             table.insert(combo, n[i])
--             backtrack(i + 1, combo)
--             table.remove(combo)
--         end
--     end
--     backtrack(1, {})
--     return result
-- end

-- local a = {"enemy1", "enemy2", "enemy3", "enemy4", "enemy5"}

-- DeepPrintTable(itertools.combinations(a, 2))