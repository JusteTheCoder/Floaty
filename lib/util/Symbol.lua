--[=[
	A symbol represents a unique object and is often
	utilized as a unique key in tables to prevent collisions.
	The symbol's distinctiveness ensures that it cannot be reconstructed,
	making it a reliable key identifier.

	```lua
		-- Instantiating a Symbol:
		local symbol = Symbol("MySymbol")
		-- The name parameter is optional:
		local anotherSymbol = Symbol()
		-- Comparison between Symbols:
		print(symbol == symbol) --> true
		-- All Symbol constructions are distinct, even if the name is identical:
		print(Symbol("Hello") == Symbol("Hello")) --> false
		-- Commonly employed as unique keys within tables:
		local DATA_KEY = Symbol("Data")
		local t = {
			-- Accessible only through the DATA_KEY Symbol:
			[DATA_KEY] = {}
		}
		print(t[DATA_KEY]) --> {}
	```
]=]
local function Symbol(name: string?): Symbol
    local proxy = newproxy(true)
	getmetatable(proxy).__tostring = function()
		return `Symbol:({name or ""})`
	end
	return proxy
end

export type Symbol = typeof(Symbol())

return Symbol