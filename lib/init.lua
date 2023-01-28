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

function Floaty.addCoordinators(location: Instance)
	assert(not started, "Coordinators cannot be added after Floaty has started. Please add before initiating.")
	Modules.findDirect(location, Coordinators._coordinators)
end

function Floaty.addLibraries(location: Instance)
	assert(not started, "Libraries cannot be added after Floaty has started. Please add before initiating.")
	Modules.findDirect(location, Floaty.Libraries._modules)
end

function Floaty.getStartData(): any?
	return _startData
end

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

function Floaty.onStart(callback: (startData: any?) -> ())
	if ready then
		return task.spawn(callback, _startData)
	end

	table.insert(awaiting, callback)
end

function Floaty.awaitStart(): any?
	if ready then return _startData end
	table.insert(awaiting, coroutine.running())
	return coroutine.yield()
end

table.freeze(Floaty)
return Floaty
