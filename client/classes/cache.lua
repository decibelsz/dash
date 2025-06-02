Cache = class()

---@class Cache
---@field playerId number
---@field serverId number
function Cache:__init()
    self.playerId = PlayerId()
    self.serverId = GetPlayerServerId(PlayerId())
    self.ped      = PlayerPedId()
end

Cache = Cache()