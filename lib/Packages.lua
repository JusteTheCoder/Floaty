local packageMeta = {}

function packageMeta:__index(key: string): any?
	local instance = self._modules[key]
	return instance and require(instance) or error(`Module {key} was not found in package {self._name}.`, 2)
end

function packageMeta:__newindex()
	error(`Attempted to write to package {self._name} which is a read-only table.`, 2)
end

function packageMeta:__iter(): (string, ModuleScript)
	return pairs(self._modules)
end

function packageMeta:__len(): number
	return #self._modules
end

function packageMeta:__tostring(): string
	return `Package {self._name}`
end

local function new(name: string): Package
	return setmetatable({ _name = name, _modules = {} }, packageMeta)
end

local function merge(package: Package, ...: { string: ModuleScript }): Package
	for i = 1, select("#", ...) do
		local modules = select(i, ...)

		for name, module in modules do
			package._modules[name] = module
		end
	end

	return package
end

export type Package = typeof(packageMeta) & {
	_name: string,
	_modules: { string: ModuleScript },
}

return table.freeze({
	new = new,
	merge = merge,
})
