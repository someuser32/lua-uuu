---@class Timers
local Timers = {
	timers = {},
	last_think = 0,
	last_think_time = 0,
}

function Timers:Think()
	if Timers.last_think == 0 then
		Timers.last_think = GameRules.GetGameTime() or 0
	end
	if Timers.last_think_time == 0 then
		Timers.last_think_time = os.time()
	end
	for id, timer in pairs(Timers.timers) do
		local bUseGameTime = true
		if timer.useGameTime ~= nil and timer.useGameTime == false then
			bUseGameTime = false
		end
		local delta = (GameRules.GetGameTime() or 0) - Timers.last_think
		if not bUseGameTime then
			delta = os.time() - Timers.last_think_time
		end
		if timer.delay == nil then
			timer.delay = 0
		end
		if timer.delay <= 0 then
			Timers.timers[id] = nil
			Timers.runningTimer = id
			Timers.removeSelf = false
			local status, nextCall = xpcall(function()
				if timer.context then
					return timer.callback(timer.context, timer)
				else
					return timer.callback(timer)
				end
			end, function(msg)
				Timers:HandleEventError("Timer", id, msg.."\n"..debug.traceback().."\n")
			end)
			if type(nextCall) ~= "number" then nextCall = nil end
			Timers.runningTimer = nil
			if status then
				if nextCall and not Timers.removeSelf then
					timer.delay = nextCall
					Timers.timers[id] = timer
				end
			end
		else
			timer.delay = timer.delay - delta
		end
	end
	Timers.last_think = GameRules.GetGameTime() or 0
	Timers.last_think_time = os.time()
end

function Timers:HandleEventError(id, event, err)
	print(err)
end

---@param callback function | table | number
---@param args function | table
---@param context any?
---@return number
function Timers:CreateTimer(callback, args, context)
	if type(callback) == "function" then
		--[[
			-- A timer running every second that starts immediately on the next frame, respects pauses
			Timers:CreateTimer(function()
				print ("Hello. I'm running immediately and then every second thereafter.")
				return 1.0
			end)
			-- A timer which calls a function with a table context
			Timers:CreateTimer(GameMode.someFunction, GameMode)
		]]
		if args ~= nil then
			context = args
		end
		args = {callback = callback}
	elseif type(callback) == "table" then
		--[[
			-- 10 second delayed, run once using gametime (respect pauses)
			Timers:CreateTimer({
				delay = 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
				callback = function()
				print ("Hello. I'm running 10 seconds after when I was started.")
			end})
			-- 10 second delayed, run once regardless of pauses
			Timers:CreateTimer({
				useGameTime = false,
				delay = 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
				callback = function()
				print ("Hello. I'm running 10 seconds after I was started even if someone paused the game.")
			end})
		]]
		args = callback
	elseif type(callback) == "number" then
		--[[
			-- A timer running every second that starts 5 seconds in the future, respects pauses
			Timers:CreateTimer(5, function()
				print ("Hello. I'm running 5 seconds after you called me and then every second thereafter.")
				return 1.0
			end)
		]]
		args = {delay = callback, callback = args}
	end
	if args == nil then
		print("Invalid arguments for created timer")
	end
	if not args.callback then
		print("Invalid callback for created timer")
		return
	end
	if args.delay == nil then
		args.delay = 0
	else
		args.delay = args.delay
	end
	args.context = context
	table.insert(Timers.timers, args)
	return #Timers.timers
end

---@param id integer
---@return nil
function Timers:RemoveTimer(id)
	Timers.timers[id] = nil
	if Timers.runningTimer == id then
		Timers.removeSelf = true
	end
end

---@param killAll boolean?
---@return nil
function Timers:RemoveTimers(killAll)
	local timers = {}
	Timers.removeSelf = true
	if not killAll then
		for k,v in pairs(Timers.timers) do
			if v.persist then
				timers[k] = v
			end
		end
	end
	Timers.timers = timers
end

return Timers