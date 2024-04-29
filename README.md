# [SteamID](https://developer.valvesoftware.com/wiki/SteamID) class for Luvit

## Installation
1. Download both `bit64.lua` and `steamid.lua`
2. Put them to `deps` folder (or create it if you don't have one)
3. Done

## Example
```lua
local SteamID = require("steamid")
local sid = SteamID("STEAM_0:1:158640106")
print(sid:ToSteamID64())
```

## Methods
* `SteamID(string steamid)` returns `SteamID` object
* `STEAMID:ToSteamID64()` returns SteamID64
* `STEAMID:ToSteamID()` returns SteamID32
* `STEAMID:ToSteamID3()` return SteamID3

## Credits
* Adapted [Lua SteamID class](https://gist.github.com/bmwalters/a5dfd114b067ea5e84c7) by [bmwalters](https://gist.github.com/bmwalters)
* Uses [lua-bit64](https://github.com/ManuelBlanc/lua-bit64) by [ManuelBlanc](https://github.com/ManuelBlanc)
