visible = true
noclip = function()
    visible = not visible
    local ped = Cache.ped

    SetEntityInvincible(ped, false)
    SetEntityVisible(ped, visible, visible)

    while (not visible) do
        timeDistance = 4
        local dx, dy, dz = getCamDirection()
        local speed = 1.0
        local x, y, z = table.unpack(GetEntityCoords(ped))
        SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)
        if IsControlPressed(1, 21) then
            speed = 5.0
        end
        if IsControlPressed(0, 18) then
            speed = 0.1
        end
        if IsControlPressed(1, 32) then
            x = x + speed * dx
            y = y + speed * dy
            z = z + speed * dz
        end
        if IsControlPressed(1, 269) then
            x = x - speed * dx
            y = y - speed * dy
            z = z - speed * dz
        end
        if IsControlPressed(1, 10) then
            z = z + 1
        end
        if IsControlPressed(1, 11) then
            z = z - 1
        end
        SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)

        Wait(timeDistance)
    end
end
RegisterNetEvent(
    'dash:client:noclip',
    function()
        CreateThread(noclip)
    end
)
