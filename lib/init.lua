local Coordinators = require(script.Coordinators)
local Packages = require(script.Packages)
local Modules = require(script.Modules)

local Floaty = {
	Coordinators = Coordinators,
	Libraries = Packages.new("Libraries"),
	Packages = Packages.new("Packages"),
}

local awaiting: { thread } = {}
local started: boolean = false
local ready: boolean = false
local _startData: any? = nil

--[=[
	Adds a coordinator to Floaty. Should be called before Floaty.start(),
	otherwise an error will be thrown.
	Unlike libraries, coordinators can only be accessed if they defined
	with Floaty.Coordinators.register().
]=]
function Floaty.addCoordinators(location: Instance)
	assert(not started, "Coordinators cannot be added after Floaty has started. Please add before initiating.")
	Modules.findDirect(location, Coordinators._coordinators)
end

--[=[
	Adds a library to Floaty. Should be called before Floaty.start(),
	otherwise an error will be thrown.
	Libraries can be accessed via Floaty.Libraries.<libraryName>.
]=]
function Floaty.addLibraries(location: Instance)
	assert(not started, "Libraries cannot be added after Floaty has started. Please add before initiating.")
	Modules.findDirect(location, Floaty.Libraries._modules)
end

--[=[
	Returns the start data passed to Floaty.start().
	This will be nil if no start data was passed.
]=]
function Floaty.getStartData(): any?
	return _startData
end

--[=[
	Returns whether Floaty has started and the coordinator lifecycle has completed.
]=]
function Floaty.isReady(): boolean
	return ready
end

--[=[
	Returns whether Floaty has started.
	This differs from Floaty.isReady() in that it will return true
	even though the coordinator lifecycle has not completed.
]=]
function Floaty.isStarted(): boolean
	return started
end

--[=[
	@yields
	Starts Floaty and yields the current thread until the coordinator lifecycle has completed.
	Can only be called once. Further calls will throw an error.

	It should be noted that this function will only yield if the coordinator lifecycle is asynchronous.
	i.e a coordinator has a 'awake' function that yields.
]=]
function Floaty.start(startData: any?)
	assert(not started, "Floaty has already been started.")
	started = true
	_startData = startData

	Packages.merge(Floaty.Packages, Floaty.Libraries._modules, Coordinators._coordinators)
	Coordinators._beginLifeCycle()

	ready = true
	for _, callback in ipairs(awaiting) do
		task.defer(callback, startData)
	end
end

--[=[
	Binds a callback to the start event.
	If Floaty has already started, the callback will be called immediately.
]=]
function Floaty.onStart(callback: (startData: any?) -> ())
	if ready then
		return task.spawn(callback, _startData)
	end

	table.insert(awaiting, callback)
end

--[=[
	@yields
	Yields the current thread until Floaty has started.
	If Floaty has already started, the function will return immediately.
]=]
function Floaty.awaitStart(): any?
	if ready then return _startData end
	table.insert(awaiting, coroutine.running())
	return coroutine.yield()
end

table.freeze(Floaty)
return Floaty
