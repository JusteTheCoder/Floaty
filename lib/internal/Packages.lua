local path = script.Parent.Parent
local internal = path.internal

local Modules = require(internal.Modules)

local MODULE_NOT_FOUND = "Module by the name of '%s' was not found in the package '%s'."
local STRICT_WRITE_ERROR = "Cannot assign property '%s' to read-only table '%s'."

local packageMeta = {
    __index = function(self, key)
        local module = self._modules[key]
        return module and require(module) or error(MODULE_NOT_FOUND:format(key, self._name))
    end,
    __newindex = function(self, key)
        error(STRICT_WRITE_ERROR:format(key, self._name))
    end,
    __iter = function(self)
        return pairs(self._modules)
    end,
}

local function newPackage(modules: Modules.ModuleDictionary, name: string): Package
    return setmetatable({ _name = name or "Packages", _modules = modules }, packageMeta)
end

export type Package = typeof(newPackage({}))
return table.freeze({
    new = newPackage,
})