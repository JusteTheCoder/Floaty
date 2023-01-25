--[=[
    Returns the number of key-value pairs in a given dictionary.

    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    local length = length(dictionary)
    print(length) --> 3
    ```
]=]
local function length<K, V>(dictionary: { [K]: V }): number
    local count = 0

    for _ in pairs(dictionary) do
        count = count + 1
    end

    return count
end

--[=[
    Checks if a given dictionary is empty.
    The return value is true if the dictionary is empty, false otherwise.

    ```lua
    local dictionary = {}
    local isEmpty = isEmpty(dictionary)
    print(isEmpty) --> true
    ```
]=]
local function isEmpty<K, V>(dictionary: { [K]: V }): boolean
    return next(dictionary) == nil
end

--[=[
    Returns an array of all the keys in a given dictionary.

    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    local keys = keys(dictionary)
    print(keys) --> {"a", "b", "c"}
    ```
]=]
local function keys<K, V>(dictionary: { [K]: V }): { K }
    local array = {}

    for key in pairs(dictionary) do
        array[#array + 1] = key
    end

    return array
end

--[=[
    Returns an array of all the values in a given dictionary.

    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    local values = values(dictionary)
    print(values) --> {1, 2, 3}
    ```
]=]
local function values<K, V>(dictionary: { [K]: V }): { V }
    local array = {}

    for _, value in pairs(dictionary) do
        array[#array + 1] = value
    end

    return array
end

--[=[
    Returns a new dictionary with the keys and values flipped.

    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    local flipped = flip(dictionary)
    print(flipped) --> {1 = "a", 2 = "b", 3 = "c"}
    ```
]=]
local function flip<K, V>(dictionary: { [K]: V }): { [V]: K }
    local flipped = {}

    for key, value in pairs(dictionary) do
        flipped[value] = key
    end

    return flipped
end

local copy = table.clone

--[=[
    Creates a deep copy of the given dictionary.

    ```lua
    local original = {a = {b = 1}}
    local copy = copyDeep(original)
    copy.a.b = 2
    print(original.a.b) --> 1
    ```
]=]
local function copyDeep<K, V>(dictionary: { [K]: V }): { [K]: V }
    local copied = table.clone(dictionary)

    for key, value in pairs(dictionary) do
        if type(value) == "table" then
            copied[key] = copyDeep(value)
        end
    end

    return copied
end

--[=[
    Maps the given dictionary to a new one using the given callback.
    The callback is called with the key and value of each key-value pair in the given dictionary.

    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    local mapped = map(dictionary, function(key, value)
        return key .. value
    end)
    print(mapped) --> {"a1", "b2", "c3"}
    ```
]=]
local function map<K, V, R>(dictionary: { [K]: V }, callback: (K, V) -> R): { [K]: R }
    local mapped = table.clone(dictionary)

    for key, value in pairs(mapped) do
        mapped[key] = callback(key, value)
    end

    return mapped
end

--[=[
    Maps the given dictionary using the provided callback function, returning a new dictionary.
    The callback takes a key-value pair from the original dictionary and returns a new key-value pair.


    ```lua
    local dictionary = {x = 1, y = 2, z = 3}
    local mappedDictionary = mapWithKey(dictionary, function(key, value) return key .. value, value * 2 end)
    print(mappedDictionary) --> {x1 = 2, y2 = 4, z3 = 6}
    ```
]=]
local function mapWithKey<K, V, R, S>(dictionary: { [K]: V }, callback: (K, V) -> (R, S)): { [R]: S }
    local mapped = {}

    for key, value in pairs(dictionary) do
        local newKey, newValue = callback(key, value)
        mapped[newKey] = newValue
    end

    return mapped
end

--[=[
    Filters the given dictionary using the provided callback function, returning a new dictionary.
    The callback takes a key-value pair from the original dictionary and returns a boolean.


    ```lua
    local dictionary = {x = 1, y = 2, z = 3}
    local filteredDictionary = filter(dictionary, function(key, value) return value > 1 end)
    print(filteredDictionary) --> {y = 2, z = 3}
    ```
]=]
local function filter<K, V>(dictionary: { [K]: V }, callback: (K, V) -> boolean): { [K]: V }
    local filtered = {}

    for key, value in pairs(dictionary) do
        if callback(key, value) then
            filtered[key] = value
        end
    end

    return filtered
end

--[=[
    Reduces the given dictionary using the provided callback function, returning a single value.
    The callback takes an accumulator, key and value from the original dictionary.


    ```lua
    local dictionary = {x = 1, y = 2, z = 3}
    local reducedValue = reduce(dictionary, function(accumulator, key, value) return accumulator + value end, 0)
    print(reducedValue) --> 6
    ```
]=]
local function reduce<K, V, R>(dictionary: { [K]: V }, reducer: (R, K, V) -> R, initialValue: R): R
    local accumulator = initialValue
    local start = nil

    if accumulator == nil then
        accumulator = next(dictionary)
        start = accumulator
    end

    for key, value in next, dictionary, start do
        accumulator = reducer(accumulator, key, value)
    end

    return accumulator
end

--[=[
    Checks if any key-value pair in the given dictionary satisfies the given callback.
    The return value is true if any pair satisfies the callback, false otherwise.


    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    local someValue = some(dictionary, function(key, value) return value % 2 == 0 end)
    print(someValue) --> true
    ```
]=]
local function some<K, V>(dictionary: { [K]: V }, callback: (K, V) -> boolean): boolean
    for key, value in pairs(dictionary) do
        if callback(key, value) then
            return true
        end
    end

    return false
end

--[=[
    Checks if every key-value pair in the given dictionary satisfies the given callback.
    The return value is true if every pair satisfies the callback, false otherwise.


    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    local everyValue = every(dictionary, function(key, value) return value % 2 == 0 end)
    print(everyValue) --> false
    ```
]=]
local function every<K, V>(dictionary: { [K]: V }, callback: (K, V) -> boolean): boolean
    for key, value in pairs(dictionary) do
        if not callback(key, value) then
            return false
        end
    end

    return true
end

--[=[
    Finds the value of the first key-value pair in the given dictionary that satisfies the given callback.
    The return value is the found value.


    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    local foundValue = find(dictionary, function(key, value) return value % 2 == 0 end)
    print(foundValue) --> 2
    ```
]=]
local function find<K, V>(dictionary: { [K]: V }, callback: (K, V) -> boolean): V?
    for key, value in pairs(dictionary) do
        if callback(key, value) then
            return value
        end
    end

    return nil
end

--[=[
    Finds the key in the given dictionary that satisfies the given callback.
    The return value is the found key.


    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    local foundKey = findKey(dictionary, function(key, value) return value == 2 end)
    print(foundKey) --> "b"
    ```
]=]
local function findKey<K, V>(dictionary: { [K]: V }, callback: (K, V) -> boolean): K?
    for key, value in pairs(dictionary) do
        if callback(key, value) then
            return key
        end
    end

    return nil
end

--[=[
    Determines whether the given dictionary includes the given value.
    The return value is true if the value is found, false otherwise.


    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    local hasValue = includes(dictionary, 2)
    print(hasValue) --> true
    ```
]=]
local function includes<K, V>(dictionary: { [K]: V }, value: V): boolean
    for _, v in pairs(dictionary) do
        if v == value then
            return true
        end
    end

    return false
end

--[=[
    Locks the given dictionary by making its keys and values read-only.
    The return value is the locked dictionary.


    ```lua
    local dictionary = {a = 1, b = 2, c = 3}
    lock(dictionary)
    dictionary.a = 4 -- error
    ```
]=]
local function lock<K, V>(dictionary: { [K]: V }): { [K]: V }
    for key, value in pairs(dictionary) do
        if type(value) == "table" then
            lock(value)
        end

        dictionary[key] = value
    end
end

--[=[
    Merges the given dictionaries into a single dictionary.
    The return value is the merged dictionary.


    ```lua
    local dictionary1 = {a = 1, b = 2}
    local dictionary2 = {c = 3, d = 4}
    local mergedDictionary = merge(dictionary1, dictionary2)
    print(mergedDictionary) --> {a = 1, b = 2, c = 3, d = 4}
    ```
]=]
local function merge<K, V>(...: { [K]: V }): { [K]: V }
    local result = copyDeep(select(1, ...))

	for dictionaryIndex = 2, select("#", ...) do
		local dictionary = select(dictionaryIndex, ...)

		for key, value in pairs(dictionary) do
			result[key] = value
		end
	end

	return result
end

--[=[
    Moves values from the given dictionarys into the first dictionary.
    Identical to merge, but mutates the first dictionary.


    ```lua
    local dictionary1 = {a = 1, b = 2}
    local dictionary2 = {c = 3, d = 4}
    move(dictionary1, dictionary2)
    print(dictionary1) --> {a = 1, b = 2, c = 3, d = 4}
    ```
]=]
local function move<K, V>(...: { [K]: V }): { [K]: V }
    local result = select(1, ...)

    for dictionaryIndex = 2, select("#", ...) do
        local dictionary = select(dictionaryIndex, ...)

        for key, value in pairs(dictionary) do
            result[key] = value
        end
    end

    return result
end

--[=[
    Reconciles the given dictionaries into a single dictionary.
    The return value is the reconciled dictionary.


    ```lua
    local dictionary1 = {a = 1, b = 2, c = {d = 3}}
    local dictionary2 = {a = 4, c = {e = 5}}
    local reconciledDictionary = reconcile(dictionary1, dictionary2)
    print(reconciledDictionary) --> {a = 4, b = 2, c = {d = 3, e = 5}}
    ```
]=]
local function reconcile<K, V>(...: { [K]: V }): { [K]: V }
    local result = copyDeep(select(1, ...))

    for dictionaryIndex = 2, select("#", ...) do
        local dictionary = select(dictionaryIndex, ...)

        for key, value in pairs(dictionary) do
            local resultValue = result[key]

            if resultValue == nil then
                if type(value) == "table" then
                    result[key] = copyDeep(value)
                else
                    result[key] = value
                end
            elseif type(resultValue) == "table" then
                if type(value) == "table" then
                    result[key] = reconcile(resultValue, value)
                else
                    result[key] = value
                end
            end
        end
    end

    return result
end

local function _compare(firstValue, secondValue)
	if type(firstValue) ~= "table" or type(secondValue) ~= "table" then
		return firstValue == secondValue
	end

	for key, value in pairs(firstValue) do
		if secondValue[key] ~= value then
			return false
		end
	end

	for key, value in pairs(secondValue) do
		if firstValue[key] ~= value then
			return false
		end
	end

	return true
end

--[=[
    Determines whether the given dictionaries are equal.
    The return value is true if the dictionaries are equal, false otherwise.


    ```lua
    local dictionary1 = {a = 1, b = 2}
    local dictionary2 = {a = 1, b = 2}
    local dictionariesAreEqual = equals(dictionary1, dictionary2)
    print(dictionariesAreEqual) --> true
    ```
]=]
local function equals<K, V>(...: { [K]: V }): boolean
    local firstDictionary = select(1, ...)
    local totalDictionaries = select("#", ...)

    if totalDictionaries < 2 then
        return true
    elseif totalDictionaries == 2 then
        return _compare(firstDictionary, select(2, ...))
    end

    for dictionaryIndex = 2, totalDictionaries do
        local dictionary = select(dictionaryIndex, ...)

        if not _compare(firstDictionary, dictionary) then
            return false
        end
    end

    return true
end

local function _compareDeep(firstValue, secondValue)
	if type(firstValue) ~= "table" or type(secondValue) ~= "table" then
		return firstValue == secondValue
	end

	for key, value in pairs(firstValue) do
		if not _compareDeep(value, secondValue[key]) then
			return false
		end
	end

	for key, value in pairs(secondValue) do
		if not _compareDeep(value, firstValue[key]) then
			return false
		end
	end

	return true
end

--[=[
    Determines whether the given dictionaries are equal using deep comparison.
    The return value is true if the dictionaries are equal, false otherwise.


    ```lua
    local dictionary1 = {a = 1, b = 2}
    local dictionary2 = {a = 1, b = 2}
    local dictionariesAreEqual = equalsDeep(dictionary1, dictionary2)
    print(dictionariesAreEqual) --> true
    ```
]=]
local function equalsDeep<K, V>(...: { [K]: V }): boolean
    local firstDictionary = select(1, ...)
    local totalDictionaries = select("#", ...)

    if totalDictionaries < 2 then
        return true
    elseif totalDictionaries == 2 then
        return _compareDeep(firstDictionary, select(2, ...))
    end

    for dictionaryIndex = 2, totalDictionaries do
        local dictionary = select(dictionaryIndex, ...)

        if not _compareDeep(firstDictionary, dictionary) then
            return false
        end
    end

    return true
end

return table.freeze({
    length = length,
    isEmpty = isEmpty,
    keys = keys,
    values = values,
    flip = flip,
    copy = copy,
    copyDeep = copyDeep,
    map = map,
    mapWithKey = mapWithKey,
    filter = filter,
    reduce = reduce,
    some = some,
    every = every,
    find = find,
    findKey = findKey,
    includes = includes,
    lock = lock,
    merge = merge,
    move = move,
    reconcile = reconcile,
    equals = equals,
    equalsDeep = equalsDeep,
})