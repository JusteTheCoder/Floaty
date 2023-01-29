## With intellisense
To add intellisense first get https://github.com/JusteTheCoder/Roblox-LSP-Module-Intellisense and
add the following strings to the patterns array inside the plugin.lua file
```lua
"()local%s+[%w_]+%s=%sFloaty%.Libraries%.([%w_]+)"
"()local%s+[%w_]+%s=%sFloaty%.Coordinators%.([%w_]+)"
"()local%s+[%w_]+%s=%sFloaty%.Packages%.[%w_.]+%.([%w_]+)"
```