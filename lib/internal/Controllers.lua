local path = script.Parent.Parent
local util = path.util

local Tables = require(util.Tables)
local Symbol = require(util.Symbol)

local COORDINATOR_NOT_FOUND = "Coordinator '$s' not found."
local YIELDING_COORDINATOR = "Coordinator '$s' yielded! This is not allowed."
local STRICT_WRITE_ERROR = "Cannot assign property '%s' to read-only table '%s'."

local created = Symbol("coordinator")

local coordinators = {}

local function _loadCoordinator(name, moduleScript)
    local coordinator
    local thread = task.spawn(function() coordinator = require(moduleScript) end)

    if coroutine.status(thread) ~= "dead" then
        coroutine.close(thread)
        return warn(YIELDING_COORDINATOR:format(name))
    end

    return coordinator
end

local function _onLifecycleCompleted()
    for name, coordinator in coordinators do
        if coordinator[created] ~= true then
            warn(COORDINATOR_NOT_FOUND:format(name))
        end
    end
end

local function _startCoordinatorLifecycle(moduleScripts)
    local ready = Tables.Dictionary.map(moduleScripts, function(name, moduleScript)
        local coordinator = _loadCoordinator(name, moduleScript)
        return type(coordinator) == "table" and coordinator or nil
    end)

    local thread = coroutine.running()
    local running = 0
    local finished = 0

    for name, coordinator in ready do
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

    for name, coordinator in ready do
        if type(coordinator.start) ~= "function" then
            continue
        end

        task.spawn(function()
            debug.setmemorycategory(name)
            coordinator:start()
        end)
    end

    _onLifecycleCompleted()
end

-- Creates a new coordinator with the given name.
-- If a coordinator with the given name already exists, the existing coordinator is merged with the given data.
local function new(name: string, data: table?): table
    local coordinator = coordinators[name]

    if coordinator == nil then
        coordinator = data or {}
        coordinators[name] = coordinator
    elseif data ~= nil then
        Tables.Dictionary.move(coordinator, data)
    end

    coordinator[created] = true
    return coordinator
end

local function get(name: string): table
    local coordinator = coordinators[name]
    if coordinator == nil then
        coordinator = { [created] = false }
        coordinators[name] = coordinator
    end
    return coordinator
end

return setmetatable({
    new = new,
    _startCoordinatorLifecycle = _startCoordinatorLifecycle,
}, {
	__index = function(_, key)
		return get(key)
	end,

	__newindex = function(_, key)
		error(STRICT_WRITE_ERROR:format(key, "Coordinators"))
	end,
})