local rng = Random.new()

--[=[
    Reverse the order of elements in the given array.
    The return value is the reversed array.

    :::caution
    This function is destructive and will mutate the given array.
    :::

    ```lua
    local array = {1, 2, 3, 4}
    local reversedArray = reverse(array)
    print(reversedArray) --> {4, 3, 2, 1}
    ```
]=]
local function reverse<T>(array: { T }): { T }
    local length = #array

	for position = 1, math.floor(length / 2) do
		local newPosition = length - (position - 1)
		array[position], array[newPosition] = array[newPosition], array[position]
	end

    return array
end

--[=[
    Returns a slice of the given array, starting at index `start` and ending at index `finish`.
    The return value is the sliced array.
    Syntactic sugar for `table.move(array, start, finish, 1)`.

    ```lua
    local array = {1, 2, 3, 4}
    local sliceArray = slice(array, 2, 3)
    print(sliceArray) --> {2, 3}
    ```
]=]
local function slice<T>(array: { T }, start: number, finish: number): { T }
    return table.move(array, start, finish, 1)
end

--[=[
    Removes duplicate values from the given array.
    The return value is the array with unique values.

    ```lua
    local array = {1, 2, 2, 3, 4, 4}
    local uniqueArray = unique(array)
    print(uniqueArray) --> {1, 2, 3, 4}
    ```
]=]
local function unique<T>(array: { T }): { T }
    local uniqueArray = {}

    for _, value in ipairs(array) do
        if not table.find(uniqueArray, value) then
            table.insert(uniqueArray, value)
        end
    end

    return uniqueArray
end

--[=[
    Filters the given array using the given predicate function.
    The return value is the filtered array.

    ```lua
    local array = {1, 2, 3, 4}
    local filteredArray = filter(array, function(value) return value > 2 end)
    print(filteredArray) --> {3, 4}
    ```
]=]
local function filter<T>(array: { T }, predicate: (T) -> boolean): { T }
    local filteredArray = table.create(#array)

    for index, value in ipairs(array) do
        if predicate(value) then
            filteredArray[index] = value
        end
    end

    return filteredArray
end

--[=[
    Maps the given array using the given mapper function.
    The return value is the mapped array.

    ```lua
    local array = {1, 2, 3, 4}
    local mappedArray = map(array, function(value) return value * 2 end)
    print(mappedArray) --> {2, 4, 6, 8}
    ```
]=]
local function map<T, U>(array: { T }, mapper: (T, number) -> U): { U }
    local mappedArray = table.clone(array)

    for i = 1, #array do
        mappedArray[i] = mapper(array[i],  i)
    end

    return mappedArray
end

--[=[
    Reduces the given array to a single value using the given reducer function and the optional initial value.
    The return value is the reduced value.

    ```lua
    local array = {1, 2, 3, 4}
    local reducedValue = reduce(array, function(acc, value) return acc + value end)
    print(reducedValue) --> 10
    ```
]=]
local function reduce<T, U>(array: { T }, reducer: (U, T, number) -> U, initialValue: U): U
    local start = initialValue == nil and 2 or 1
    local accumulator = initialValue or array[1]

    for i = start, #array do
        accumulator = reducer(accumulator, array[i], i)
    end

    return accumulator
end

--[=[
    Reduces the given array to a single value starting from the right side using the given reducer function and the optional initial value.
    The return value is the reduced value.

    ```lua
    local array = {1, 2, 3, 4}
    local reducedValue = reduceRight(array, function(acc, value) return acc + value end)
    print(reducedValue) --> 10
    ```
]=]
local function reduceRight<T, U>(array: { T }, reducer: (U, T, number) -> U, initialValue: U): U
    local start = initialValue == nil and #array - 1 or #array
    local accumulator = initialValue or array[#array]

    for i = start, 1, -1 do
        accumulator = reducer(accumulator, array[i], i)
    end

    return accumulator
end

--[=[
    Creates an array of arrays, the first array containing the first element of the input arrays, the second array containing the second element of the input arrays, and so on.
    The return value is the zipped array.

    ```lua
    local array1 = {1, 2, 3}
    local array2 = {4, 5, 6}
    local array3 = {7, 8, 9}
    local zippedArray = zip(array1, array2, array3)
    print(zippedArray) --> {{1, 4, 7}, {2, 5, 8}, {3, 6, 9}}
    ```
]=]
local function zip<T>(...: {any}): T
    local arrays = {...}
    local max = -math.huge
    for _, array in ipairs(arrays) do
        max = math.min(max, #array)
    end

    local zippedArray = table.create(max)
    for i = 1, max do
        local zippedValue = table.create(#arrays)
        for j = 1, #arrays do
            zippedValue[j] = arrays[j][i]
        end
        zippedArray[i] = zippedValue
    end

    return zippedArray
end

--[=[
    Applies the given zipper function to the elements of the input arrays and returns an array of the results.
    The return value is the zipped array.

    ```lua
    local array1 = {1, 2, 3}
    local array2 = {4, 5, 6}
    local array3 = {7, 8, 9}
    local zippedArray = zipWith(function(a, b, c) return a + b + c end, array1, array2, array3)
    print(zippedArray) --> {12, 15, 18}
    ```
]=]
local function zipWith<T, U>(zipper: (T) -> U, ...: {any}): U
    local arrays = {...}
    local max = math.huge
    for _, array in ipairs(arrays) do
        max = math.min(max, #array)
    end

    local zippedArray = table.create(max)
    for i = 1, max do
        local zippedValue = table.create(#arrays)
        for j = 1, #arrays do
            zippedValue[j] = arrays[j][i]
        end
        zippedArray[i] = zipper(table.unpack(zippedValue))
    end

    return zippedArray
end

--[=[
    Flattens the given array to a specified depth.
    The return value is the flattened array.

    ```lua
    local array = {{1, 2}, {3, {4, 5}}, 6}
    local flattenedArray = flatten(array, 2)
    print(flattenedArray) --> {1, 2, 3, 4, 5, 6}
    ```
]=]
local function flatten<T>(array: { T }, depth: number?): { T }
    depth = depth or 1
    local flattenedArray = table.create(#array)

    local function flattenArray(array2: { T }, depth2: number)
        for _, value in ipairs(array2) do
            if type(value) == "table" and depth2 > 0 then
                flattenArray(value, depth2 - 1)
            else
                flattenedArray[#flattenedArray + 1] = value
            end
        end
    end

    flattenArray(array, depth)
    return flattenedArray
end

--[=[
    Maps the given array using the given mapper function and flattens the result to a depth of 1.
    The return value is the flattened and mapped array.

    ```lua
    local array = {{1, 2}, {3, {4, 5}}, 6}
    local flatMappedArray = flatMap(array, function(value) return value + 1 end)
    print(flatMappedArray) --> {2, 3, 4, 5, 6, 7}
    ```
]=]
local function flatMap<T, U>(array: { T }, mapper: (T) -> U): { U }
    return flatten(map(array, mapper))
end

--[=[
    Groups the elements of the given array by the result of the given grouper function.
    The return value is the grouped array.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local groupedArray = groupBy(array, function(value) return value % 2 == 0 and "even" or "odd" end)
    print(groupedArray) --> {even = {2, 4, 6}, odd = {1, 3, 5}}
    ```
]=]
local function groupBy<T, U>(array: { T }, grouper: (T) -> U): { U }
    local groups = {}

    for _, value in ipairs(array) do
        local group = grouper(value)
        if not groups[group] then
            groups[group] = {}
        end
        table.insert(groups[group], value)
    end

    return groups
end

--[=[
    Counts the number of elements in the given array that belong to each group as determined by the given grouper function.
    The return value is the grouped array with count of the elements in each group.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local countedArray = countBy(array, function(value) return value % 2 == 0 and "even" or "odd" end)
    print(countedArray) --> {even = 3, odd = 3}
    ```
]=]
local function countBy<T, U>(array: { T }, grouper: (T) -> U): { U }
    local groups = {}

    for _, value in ipairs(array) do
        local group = grouper(value)
        if not groups[group] then
            groups[group] = 0
        end
        groups[group] = groups[group] + 1
    end

    return groups
end

--[=[
    Concatenates the given arrays into a single array.
    The return value is the concatenated array.

    ```lua
    local array1 = {1, 2, 3}
    local array2 = {4, 5, 6}
    local array3 = {7, 8, 9}
    local concatenatedArray = concat(array1, array2, array3)
    print(concatenatedArray) --> {1, 2, 3, 4, 5, 6, 7, 8, 9}
    ```
]=]
local function concat<T>(...: { T }): { T }
    local length = select("#", ...)
    local concatenatedArray = {}

    for i = 1, length do
        local array = select(i, ...)
        table.move(array, 1, #array, #concatenatedArray + 1, concatenatedArray)
    end

    return concatenatedArray
end

--[=[
    Makes a shallow copy of the given array.
    The return value is the copied array.

    ```lua
    local array = {1, 2, 3, 4}
    local copiedArray = copy(array)
    print(copiedArray) --> {1, 2, 3, 4}
    ```
]=]
local copy = table.clone

--[=[
    Makes a deep copy of the given array.
    The return value is the copied array.

    ```lua
    local array = {{1, 2}, {3, {4, 5}}, 6}
    local deepCopiedArray = copyDeep(array)
    print(deepCopiedArray) --> {{1, 2}, {3, {4, 5}}, 6}
    ```
]=]
local function copyDeep<T>(array: { T }): { T }
    local copiedArray = table.clone(array)

    for index, value in ipairs(copiedArray) do
        if type(value) == "table" then
            copiedArray[index] = copyDeep(value)
        end
    end

    return copiedArray
end

--[=[
    Computes the average of the numbers in the given array.
    The return value is the average.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local averageValue = average(array)
    print(averageValue) --> 3.5
    ```
]=]
local function average(array: { number }): number
    return reduce(array, function(accumulator, value)
        return accumulator + value
    end, 0) / #array
end

--[=[
    Computes the sum of the numbers in the given array.
    The return value is the sum.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local sumValue = sum(array)
    print(sumValue) --> 21
    ```
]=]
local function sum(array: { number }): number
    return reduce(array, function(accumulator, value)
        return accumulator + value
    end, 0)
end

--[=[
    Computes the product of the numbers in the given array.
    The return value is the product.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local productValue = product(array)
    print(productValue) --> 720
    ```
]=]
local function product(array: { number }): number
    return reduce(array, function(accumulator, value)
        return accumulator * value
    end, 1)
end

--[=[
    Finds the minimum number in the given array.
    The return value is the minimum number.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local minValue = min(array)
    print(minValue) --> 1
    ```
]=]
local function min(array: { number }): number
    return reduce(array, function(accumulator, value)
        return math.min(accumulator, value)
    end, math.huge)
end

--[=[
    Finds the maximum number in the given array.
    The return value is the maximum number.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local maxValue = max(array)
    print(maxValue) --> 6
    ```
]=]
local function max(array: { number }): number
    return reduce(array, function(accumulator, value)
        return math.max(accumulator, value)
    end, -math.huge)
end

--[=[
    Finds the first element in the given array that satisfies the given predicate.
    The return value is the found element.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local foundValue = find(array, function(value) return value % 2 == 0 end)
    print(foundValue) --> 2
    ```
]=]
local function find<T>(array: { T }, predicate: (T) -> boolean): T?
    for _, value in ipairs(array) do
        if predicate(value) then
            return value
        end
    end
end

--[=[
    Finds the index of the first element in the given array that satisfies the given predicate.
    The return value is the found index.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local foundIndex = findIndex(array, function(value) return value % 2 == 0 end)
    print(foundIndex) --> 2
    ```
]=]
local function findIndex<T>(array: { T }, predicate: (T) -> boolean): number?
    for index, value in ipairs(array) do
        if predicate(value) then
            return index
        end
    end
end

--[=[
    Finds the last element in the given array that satisfies the given predicate.
    The return value is the found element.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local foundValue = findLast(array, function(value) return value % 2 == 0 end)
    print(foundValue) --> 6
    ```
]=]
local function findLast<T>(array: { T }, predicate: (T) -> boolean): T?
    for i = #array, 1, -1 do
        local value = array[i]
        if predicate(value) then
            return value
        end
    end
end

--[=[
    Finds the last index of the element in the given array that satisfies the given predicate.
    The return value is the found index.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local foundIndex = findLastIndex(array, function(value) return value % 2 == 0 end)
    print(foundIndex) --> 6
    ```
]=]
local function findLastIndex<T>(array: { T }, predicate: (T) -> boolean): number?
    for i = #array, 1, -1 do
        local value = array[i]
        if predicate(value) then
            return i
        end
    end
end


--[=[
    Checks if any element in the given array satisfies the given predicate.
    The return value is true if any element satisfies the predicate, false otherwise.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local someValue = some(array, function(value) return value % 2 == 0 end)
    print(someValue) --> true
    ```
]=]
local function some<T>(array: { T }, predicate: (T) -> boolean): boolean
    for _, value in ipairs(array) do
        if predicate(value) then
            return true
        end
    end

    return false
end

--[=[
    Checks if every element in the given array satisfies the given predicate.
    The return value is true if every element satisfies the predicate, false otherwise.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local everyValue = every(array, function(value) return value % 2 == 0 end)
    print(everyValue) --> false
    ```
]=]
local function every<T>(array: { T }, predicate: (T) -> boolean): boolean
    for _, value in ipairs(array) do
        if not predicate(value) then
            return false
        end
    end

    return true
end

--[=[
    Shuffles the given array using the Fisher-Yates algorithm.
    The return value is the shuffled array.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local shuffledArray = shuffle(array)
    print(shuffledArray) --> [5, 2, 6, 4, 3, 1]
    ```
]=]
local function shuffle<T>(array: { T }, rngOverride: Random?): { T }
    local shuffledArray = table.clone(array)
    local length = #shuffledArray
    rngOverride = rngOverride or rng

    for i = 1, length do
        local j = rngOverride:NextInteger(i, length)
        shuffledArray[i], shuffledArray[j] = shuffledArray[j], shuffledArray[i]
    end

    return shuffledArray
end

--[=[
    Returns a random sample of the given array.
    The return value is an array containing the sample.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local sample = sample(array, 3)
    print(sample) --> [4, 2, 5]
    ```
]=]
local function sample<T>(array: { T }, count: number?, rngOverride: Random?): { T }
    local length = #array
    count = count or 1
    rngOverride = rngOverride or rng

    if count > length then
        error("Cannot sample more values than the array contains")
    end

    local sampledArray = table.create(count)
    local sampled = {}

    for i = 1, count do
        local index = rngOverride:NextInteger(1, length)
        while sampled[index] do
            index = rngOverride:NextInteger(1, length)
        end
        sampled[index] = true
        sampledArray[i] = array[index]
    end

    return sampledArray
end

--[=[
    Returns a random element from the given array.
    The return value is the selected element.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local element = sampleOne(array)
    print(element) --> 3
    ```
]=]
local function sampleOne<T>(array: { T }, rngOverride: Random?): T
    return array[rngOverride:NextInteger(1, #array)]
end

--[=[
    Locks the given array and all nested tables to prevent further modification.
    The return value is the locked array.

    ```lua
    local array = {1, 2, {3, 4}, {5, 6}}
    local lockedArray = lock(array)
    lockedArray[1] = 10 -- error
    lockedArray[3][1] = 10 -- error
    ```
]=]
local function lock<T>(array: { T }): { T }
	for _, value in ipairs(array) do
		if type(value) == "table" then
			lock(value)
		end
	end

	table.freeze(array)
	return array
end

--[=[
    Removes the element at the given index from the given array
    by swapping it with the last element and removing the last element.
    The return value is the removed element.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local removed = swapRemove(array, 3)
    print(array) --> {1, 2, 6, 4, 5}
    print(removed) --> 3
    ```
]=]
local function swapRemove<T>(array: { T }, index: number): T
	local last = #array
	array[index] = array[last]
	array[last] = nil
end

--[=[
    Removes the first occurrence of the given value from the given array by swapping it with the last element and removing the last element.
    The return value is a boolean indicating if the value was found and removed.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local removed = swapRemoveFirst(array, 3)
    print(array) --> {1, 2, 6, 4, 5}
    print(removed) --> 3
    ```
]=]
local function swapRemoveFirst<T>(array: { T }, value: T): boolean
	local i = table.find(array, value)
	if i then
		swapRemove(array, i)
	end
	return i
end

--[=[
    Removes the first count values from the beginning of the array and returns the modified array.
    If no count is provided, a default of 1 is used.
    If the count is greater than the length of the array, an error is thrown.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local shiftedArray = shift(array, 2)
    print(shiftedArray) --> {3, 4, 5, 6}
    ```
]=]
local function shift<T>(array: { T }, count: number?): { T }
	local length = #array
	count = count or 1

    assert(count <= length, "Cannot shift more values than the array contains")
    table.move(array, count + 1, length, 1, array)

    for i = length, length - count + 1, -1 do
        array[i] = nil
    end

    return array
end

--[=[
    Adds the given values to the beginning of the array and returns the modified array.
    Any number of values can be passed as separate arguments.

    ```lua
    local array = {1, 2, 3, 4, 5, 6}
    local unshiftedArray = unshift(array, 7, 8, 9)
    print(unshiftedArray) --> {7, 8, 9, 1, 2, 3, 4, 5, 6}
    ```
]=]
local function unshift<T>(array: { T }, ...: T): { T }
    for i = 1, select("#", ...) do
        table.insert(array, i, select(i, ...))
    end

    return array
end

--[=[
    Returns true if the arrays are equal, false otherwise.

    ```lua
    local array1 = {1, 2, 3, 4, 5, 6}
    local array2 = {1, 2, 3, 4, 5, 6}
    local array3 = {1, 2, 3, 4, 5, 7}
    print(equals(array1, array2)) --> true
    print(equals(array1, array3)) --> false
    ```
]=]
local function equals<T>(...: { T }): boolean
    local length = select("#", ...)
    local first = select(1, ...)
    local firstLength = #first

    for i = 2, length do
        local array = select(i, ...)
        local arrayLength = #array
        if arrayLength ~= firstLength then
            return false
        end

        for j = 1, firstLength do
            if array[j] ~= first[j] then
                return false
            end
        end

        if arrayLength > firstLength then
            for j = firstLength + 1, arrayLength do
                if array[j] ~= nil then
                    return false
                end
            end
        end
    end

    return true
end

--[=[
    Returns true if the arrays and all their subtables are equal, false otherwise.

    ```lua
    local array1 = {1, 2, 3, 4, 5, 6}
    local array2 = {1, 2, 3, 4, 5, 6}
    local array3 = {1, 2, 3, 4, 5, 7}
    print(equalsDeep(array1, array2)) --> true
    print(equalsDeep(array1, array3)) --> false
    ```
]=]
local function equalsDeep<T>(...: { T }): boolean
    local length = select("#", ...)
    local first = select(1, ...)
    local firstLength = #first

    for i = 2, length do
        local array = select(i, ...)
        local arrayLength = #array
        if arrayLength ~= firstLength then
            return false
        end

        for j = 1, firstLength do
            local value = array[j]
            local firstValue = first[j]
            if type(value) == "table" and type(firstValue) == "table" then
                if not equalsDeep(value, firstValue) then
                    return false
                end
            elseif value ~= firstValue then
                return false
            end
        end

        if arrayLength > firstLength then
            for j = firstLength + 1, arrayLength do
                if array[j] ~= nil then
                    return false
                end
            end
        end
    end

    return true
end

return table.freeze({
    reverse = reverse,
    slice = slice,
    unique = unique,
    filter = filter,
    map = map,
    reduce = reduce,
    reduceRight = reduceRight,
    zip = zip,
    zipWith = zipWith,
    flatten = flatten,
    flatMap = flatMap,
    groupBy = groupBy,
    countBy = countBy,
    concat = concat,
    copy = copy,
    copyDeep = copyDeep,
    average = average,
    sum = sum,
    product = product,
    min = min,
    max = max,
    find = find,
    findIndex = findIndex,
    findLast = findLast,
    findLastIndex = findLastIndex,
    some = some,
    every = every,
    shuffle = shuffle,
    sample = sample,
    sampleOne = sampleOne,
    lock = lock,
    swapRemove = swapRemove,
    swapRemoveFirst = swapRemoveFirst,
    shift = shift,
    unshift = unshift,
    equals = equals,
    equalsDeep = equalsDeep,
})