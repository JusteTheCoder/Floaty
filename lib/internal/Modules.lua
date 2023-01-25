type ModuleDictionary = { string: ModuleScript }

local CONFLICTING_MODULE_NAME = "Conflicting module name '$s' found in '$s' and '$s'. "
	.. "Rename one to avoid conflicts."

local function getModulesRecursive(location: Instance, modules: ModuleDictionary?): ModuleDictionary
	modules = modules or {}

	for _, child in ipairs(location:GetChildren()) do
		if child:IsA("ModuleScript") then
            local module = modules[child.Name]
            if module then
                warn(CONFLICTING_MODULE_NAME:format(child.Name, child:GetFullName(), module:GetFullName()))
            end
			modules[child.Name] = child
		else
			getModulesRecursive(child, modules)
		end
	end

	return modules
end

local function getDescendantModules(location: Instance): ModuleDictionary
    local modules = {}

    for _, child in ipairs(location:GetDescendants()) do
        if child:IsA("ModuleScript") == false then
            continue
        end

        local module = modules[child.Name]
        if module then
            warn(CONFLICTING_MODULE_NAME:format(child.Name, child:GetFullName(), module:GetFullName()))
        end
        modules[child.Name] = child
    end

    return modules
end

return table.freeze({
    getModulesRecursive = getModulesRecursive,
    getDescendantModules = getDescendantModules,
})