onClientLoad = function()
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    local ped = setInitialModel()

    FreezeEntityPosition(ped, false)
end

CreateThread(onClientLoad)