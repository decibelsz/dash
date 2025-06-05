setInitialModel = function()
    local ped = updatePlayerModel(Cache.playerId, config.spawn.model)

    SetEntityCoords(ped, config.spawn.coords.x, config.spawn.coords.y, config.spawn.coords.z)
    SetEntityHeading(ped, config.spawn.coords.w)

    SetPedRandomComponentVariation(ped)

    return ped
end