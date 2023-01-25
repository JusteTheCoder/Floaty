local internal = script.internal
local util = script.util

local Controllers = require(internal.Controllers)
local Modules = require(internal.Modules)
local Packages = require(internal.Packages)

local ADD_AFTER_START_ERROR = "Cannot add new %s after Matte has started."

local Matte = {}

local start = false
local ready = false

local controllers = {}
local libraries = {}

function Matte.addControllers(location: Instance)
    assert(not start, ADD_AFTER_START_ERROR:format("Controllers"))
    Modules.getModulesRecursive(location, controllers)
end

function Matte.addLibraries()
    assert(not start, ADD_AFTER_START_ERROR:format("Libraries"))
    Modules.getModulesRecursive(script, libraries)
end

table.freeze(Matte)
return Matte