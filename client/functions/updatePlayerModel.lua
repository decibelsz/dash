updatePlayerModel = function(player, model)
    RequestModel(model)

    repeat Wait(1) until HasModelLoaded(model)

    SetPlayerModel(player, model)

    Cache.ped = PlayerPedId()

    local ped = Cache.ped

    SetPedDefaultComponentVariation(ped)
    SetModelAsNoLongerNeeded(model)
    SetPedMaxHealth(ped, 200)
    SetEntityMaxHealth(ped, 200)
    SetEntityHealth(ped, 300)

    SetPedSuffersCriticalHits(ped, true)

    return ped
end