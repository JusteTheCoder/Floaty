local WEAK_KEYS = { __mode = "k" }
local WEAK_VALUES = { __mode = "v" }
local WEAK_KEYS_AND_VALUES = { __mode = "kv" }

--[=[
    Creates a new table with weak keys.
    The garbage collector will automatically remove key-value pairs from the table when there are no other references to the keys.

    ```lua
    local weak_keys_table = newWeakKeys({
        [player1: Player] = 12,
        [player2: Player] = 5
    })
    ```
]=]
local function newWeakKeys(t: table): table
	return setmetatable(t or {}, WEAK_KEYS)
end

--[=[
    Creates a new table with weak values.
    The garbage collector will automatically remove key-value pairs from the table when there are no other references to the values.

    ```lua
    local weak_values_table = newWeak({
        weapon1: Tool,
        weapon2: Tool
    })
    ```
]=]
local function newWeakValues(t: table): table
	return setmetatable(t or {}, WEAK_VALUES)
end

--[=[
    Creates a new table with weak keys and values.
    The garbage collector will automatically remove key-value pairs from the table when there are no other references to the keys or values.

    ```lua
    local weak_keys_values_table = newWeak({
        [player1: Player] = weapon1: Tool,
        [player2: Player] = weapon2: Tool
    })
    ```
]=]
local function newWeak(t: table): table
	return setmetatable(t or {}, WEAK_KEYS_AND_VALUES)
end

return table.freeze({
    newWeakKeys = newWeakKeys,
    newWeakValues = newWeakValues,
    newWeak = newWeak,
})