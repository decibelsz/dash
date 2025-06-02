setInitialModel = function()
    local ped = updatePlayerModel(PlayerId(), config.spawn.model)

    SetEntityCoords(ped, config.spawn.coords.x, config.spawn.coords.y, config.spawn.coords.z)
    SetEntityHeading(ped, config.spawn.coords.w)

    return ped
end