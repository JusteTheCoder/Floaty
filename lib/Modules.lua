export type ModuleDictionary = { string: ModuleScript }

local function findDirect(location: Instance, modules: ModuleDictionary?): ModuleDictionary
	modules = modules or {}

	for _, child in ipairs(location:GetChildren()) do
		if child:IsA("ModuleScript") == false then
			findDirect(child, modules)
			continue
		end

		local module = modules[child.Name]
		if module then
			warn(
				`Conflicting module name '{child.Name}' with '{child:GetFullName()}' and '{module:GetFullName()}'. Rename one to avoid conflicts.`
			)
		end
	end

	return modules
end

local function findDescendants(location: Instance, modules: ModuleDictionary?): ModuleDictionary
    modules = modules or {}

    for _, child in ipairs(location:GetDescendants()) do
        if child:IsA("ModuleScript") == false then
            continue
        end

        local module = modules[child.Name]
        if module then
            warn(
                `Conflicting module name '{child.Name}' with '{child:GetFullName()}' and '{module:GetFullName()}'. Rename one to avoid conflicts.`
            )
        end
        modules[child.Name] = child
    end

    return modules
end

return table.freeze({
	findDirect = findDirect,
	findDescendants = findDescendants,
})
