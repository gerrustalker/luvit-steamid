local bit = require("bit64") -- https://github.com/ManuelBlanc/lua-bit64
local en = {
    u = {
        INVALID = 0,
        PUBLIC = 1,
        BETA = 2,
        INTERNAL = 3,
        DEV = 4
    },
    t = {
        INVALID = 0,
        INDIVIDUAL = 1,
        MULTISEAT = 2,
        GAMESERVER = 3,
        ANON_GAMESERVER = 4,
        PENDING = 5,
        CONTENT_SERVER = 6,
        CLAN = 7,
        CHAT = 8,
        P2P_SUPER_SEEDER = 9,
        ANON_USER = 10,
    },
    i = {
        ALL = 0,
        DESKTOP = 1,
        CONSOLE = 2,
        WEB = 4,
    },
    tc = {
        [0] = "I",
        [1] = "U",
        [2] = "M",
        [3] = "G",
        [4] = "A",
        [5] = "P",
        [6] = "C",
        [7] = "g",
        [8] = "T",
        [10] = "a",
    },
    cim = {
        Clan = bit.rshift(0x000FFFFF + 1, 1),
        Lobby = bit.rshift(0x000FFFFF + 1, 2),
        MMSLobby = bit.rshift(0x000FFFFF + 1, 3),
    }
}

local clearULL = function(s) local a = string.gsub(tostring(s), "ULL", "") return a end
local STEAMID = {} STEAMID.__index = STEAMID

function STEAMID:Init(sido)
    if not sido then return end
    local sid = tostring(sido)

    self.Universe = en.u.INVALID
    self.Type = en.t.INVALID
    self.Instance = en.i.ALL
    self.AccountID = 0

    do -- SteamID 32
        local u, low, high = string.match(sid, "^STEAM_([0-5]):([0-1]):([0-9]+)$")
        if u and low and high then
            self.Universe = tonumber(u) if self.Universe == en.u.INVALID then self.Universe = en.u.PUBLIC end
            self.Type = en.t.INDIVIDUAL
            self.Instance = en.i.DESKTOP
            self.AccountID = bit.lshift(tonumber(high), 1) + tonumber(low)
        return end
    end

    do -- SteamID 64
        local a = #sid / 2
        local b, c = tonumber(string.sub(sid, 1, a)), tonumber(string.sub(sid, a + 1))
        if b and c and #sid >= 16 then
            local n = b * 1000000000ULL + c
            if n then
                self.Universe = bit.rshift(n, 56) if self.Universe == en.u.INVALID then self.Universe = en.u.PUBLIC end
                self.Type = bit.band(bit.rshift(n, 52), 2^4 - 1)
                self.Instance = bit.band(bit.rshift(n, 32), 2^20 - 1)
                self.AccountID = bit.band(n, 2^32 - 1) - 4294967296
            return end
        end
    end

    do -- SteamID 3
        local tc, u, id, i = string.match(sid, "^%[(%a):([0-5]):(%d+)(.*)%]$")
        if tc and u and id then
            self.Universe = tonumber(u) if self.Universe == en.u.INVALID then self.Universe = en.u.PUBLIC end
            self.AccountID = tonumber(id)

            if i and i ~= "" then self.Instance = tonumber(string.sub(i, 2))
            elseif tc == "U" then self.Instance = en.i.DESKTOP end

            if tc == "C" then
                self.Instance = bit.bor(self.Instance, en.cim.Clan)
                self.Type = en.t.CHAT
            elseif tc == "L" then
                self.Instance = bit.bor(self.Instance, en.cim.Lobby)
                self.Type = en.t.CHAT
            else for k, v in pairs(tc) do if v == tc then self.Type = k end end end
        return end
    end

    do -- AccountID
        local n = tonumber(sid)
        if n and #sid < 16 then self.AccountID = n end
    end
end

function STEAMID:ToSteamID64() return clearULL(bit.bor(bit.lshift(self.Universe, 56), bit.lshift(self.Type, 52), bit.lshift(self.Instance, 32), self.AccountID)) end
function STEAMID:ToSteamID()
    if self.Type ~= en.t.INDIVIDUAL then return end
    return clearULL(string.format("STEAM_%s:%s:%s", self.Universe == en.u.PUBLIC and 0 or self.Universe, bit.band(self.AccountID, 1), bit.rshift(self.AccountID, 1)))
end
function STEAMID:ToSteamID3()
    local tc = en.tc[self.Type] or "i"
    if bit.band(self.Instance, u.cim.Clan) ~= 0 then tc = "c"
    elseif bit.band(self.Instance, u.cim.Lobby) ~= 0 then tc = "L" end

    local i = self.Type == en.t.ANON_GAMESERVER or self.Type == en.t.MULTISEAT or (self.Type == en.t.INDIVIDUAL and self.Instance ~= en.i.DESKTOP)
    return clearULL(string.format("[%s:%s:%s]", tc, self.Universe, self.AccountID, i and ":" .. self.Instance or ""))
end
function STEAMID:__tostring() return string.format("[SteamID %s]", clearULL(self.AccountID)) end

return function(...) local s = setmetatable({}, STEAMID) pcall(s.Init, s, ...) return s end