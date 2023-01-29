local REGISTERED_KEY = newproxy(true)
getmetatable(REGISTERED_KEY).__tostring = function()
	return "REGISTERED_KEY"
end

local _registeredCoordinators: { string: table } = {}
local _coordinators: { string: ModuleScript } = {}

local function _require(moduleScript: ModuleScript)
	local coordinator
	local thread = task.spawn(function() coordinator = require(moduleScript) end)

	if coroutine.status(thread) ~= "dead" then
		coroutine.close(thread)
		return warn(`Coordinator '{moduleScript.Name}' yielded. This is not allowed.`)
	end

	return coordinator
end

local function _onLifeCycleCompleted()
	for name, coordinator in _registeredCoordinators do
		if coordinator[REGISTERED_KEY] ~= true then
			error(`Coordinator '{name}' not found.`)
		end
	end
end

local function _beginLifeCycle()
	local coordinators = {}
	for name, moduleScript in _coordinators do
		local coordinator = _require(moduleScript)
		if type(coordinator) == "table" then
			coordinators[name] = coordinator
		end
	end

	local thread = coroutine.running()
	local running = 0
	local finished = 0

	for name, coordinator in coordinators do
		if type(coordinator.awake) ~= "function" then
			continue
		end

		running += 1
		task.spawn(function()
			debug.setmemorycategory(name)
			coordinator:awake()
			finished += 1

			if finished == running and coroutine.status(thread) == "suspended" then
				task.spawn(thread)
			end
		end)
	end

	if finished ~= running then
		coroutine.yield()
	end

	for name, coordinator in coordinators do
		if type(coordinator.start) ~= "function" then
			continue
		end

		task.spawn(function()
			debug.setmemorycategory(name)
			coordinator:start()
		end)
	end

	_onLifeCycleCompleted()
end

--[=[
	Registers a coordinator.
	If the coordinator has already been registered, the data will be merged into the existing coordinator.
	If the coordinator has not been registered, it will be registered with the given data.
	If no data is given, the coordinator will be registered with an empty table.
]=]
local function register(name: string, data: table?): table
	local coordinator = _registeredCoordinators[name]

	if coordinator == nil then
		coordinator = data or {}
		_registeredCoordinators[name] = coordinator
	elseif data ~= nil then
		for key, value in data do
			coordinator[key] = value
		end
	end

	coordinator[REGISTERED_KEY] = true
	return coordinator
end

--[=[
	Returns a registered coordinator.
	If the coordinator has not been registered, an empty table will be returned.
]=]
local function get(name: string): table?
	local coordinator = _registeredCoordinators[name]
	if coordinator then return coordinator end

	coordinator = {}
	_registeredCoordinators[name] = coordinator
	return coordinator
end

return setmetatable({
	register = register,
	_beginLifeCycle = _beginLifeCycle,
	_coordinators = _coordinators,
}, {
	__index = function(_, key)
		return get(key)
	end,
	__newindex = function()
		error(`Attempt to write to 'Coordinators' which is a read-only table.`, 2)
	end,
})
