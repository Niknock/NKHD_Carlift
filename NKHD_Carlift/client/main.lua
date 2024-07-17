ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end
end)

local lifts = {}
local isNearLift = false
local UIopen = false

Citizen.CreateThread(function()
    for _, liftCoords in ipairs(Config.CarLifts) do
        TriggerEvent('nkhd_carlift:spawnLift', liftCoords)
    end
end)

RegisterNetEvent('nkhd_carlift:spawnLift')
AddEventHandler('nkhd_carlift:spawnLift', function(liftCoords)
    local frameHash = GetHashKey('nkhd_car_lift_01')
    local platformHash = GetHashKey('nkhd_car_lift_02')

    RequestModel(frameHash)
    while not HasModelLoaded(frameHash) do
        Citizen.Wait(1)
    end

    RequestModel(platformHash)
    while not HasModelLoaded(platformHash) do
        Citizen.Wait(1)
    end

    local liftFrame = CreateObject(frameHash, liftCoords.x, liftCoords.y, liftCoords.z, false, true, true)
    local liftPlatform = CreateObject(platformHash, liftCoords.x, liftCoords.y, liftCoords.z, false, true, true)

    if liftFrame and liftPlatform then
        PlaceObjectOnGroundProperly(liftFrame)
        PlaceObjectOnGroundProperly(liftPlatform)
        SetEntityHeading(liftFrame, liftCoords.heading)
        SetEntityHeading(liftPlatform, liftCoords.heading)

        table.insert(lifts, { frame = liftFrame, platform = liftPlatform, startZ = liftCoords.z, heading = liftCoords.heading, vehicle = nil, frozen = false })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        isNearLift = false

        for _, lift in ipairs(lifts) do
            local liftCoords = GetEntityCoords(lift.frame)
            if GetDistanceBetweenCoords(coords, liftCoords, true) < 3.0 then
                isNearLift = true
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to control the car lift')
                if IsControlJustReleased(0, 38) then
                    SetNuiFocus(true, true)
                    SendNUIMessage({ action = 'open' })
                    lift.active = true
                    UIopen = true
                end
            else
                lift.active = false
            end

            if lift.platform then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if vehicle ~= 0 and GetDistanceBetweenCoords(GetEntityCoords(vehicle), GetEntityCoords(lift.platform), true) < 3.0 then
                    if not lift.vehicle then
                        lift.vehicle = vehicle
                        FreezeEntityPosition(lift.vehicle, true)
                        AttachEntityToEntity(lift.vehicle, lift.platform, 0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, false, false, true, false, 20, true)
                        lift.frozen = true
                    end

                    if not IsPedInVehicle(playerPed, vehicle, false) and not lift.frozen then
                        FreezeEntityPosition(lift.vehicle, true)
                        AttachEntityToEntity(lift.vehicle, lift.platform, 0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, false, false, true, false, 20, true)
                        lift.frozen = true
                    elseif IsPedInVehicle(playerPed, vehicle, false) and lift.frozen then
                        DetachEntity(lift.vehicle, false, true)
                        FreezeEntityPosition(lift.vehicle, false)
                        lift.frozen = false
                    end
                elseif lift.vehicle and GetDistanceBetweenCoords(GetEntityCoords(lift.vehicle), GetEntityCoords(lift.platform), true) >= 3.0 then
                    DetachEntity(lift.vehicle, false, true)
                    FreezeEntityPosition(lift.vehicle, false)
                    lift.vehicle = nil
                    lift.frozen = false
                end
            end
        end

        if not isNearLift and UIopen then
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'close' })
            UIopen = false
        end
    end
end)

RegisterNetEvent('nkhd_carlift:moveLift')
AddEventHandler('nkhd_carlift:moveLift', function(direction)
    for _, lift in ipairs(lifts) do
        if lift.active then
            local platformCoords = GetEntityCoords(lift.platform)
            local step = 0.02

            if direction == 'up' then
                Citizen.CreateThread(function()
                    while platformCoords.z < lift.startZ + 2 do
                        platformCoords = GetEntityCoords(lift.platform)
                        SetEntityCoords(lift.platform, platformCoords.x, platformCoords.y, platformCoords.z + step, 0, 0, 0, false)
                        if lift.vehicle then
                            local vehicleCoords = GetEntityCoords(lift.vehicle)
                            SetEntityCoords(lift.vehicle, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + step, 0, 0, 0, false)
                            SetEntityHeading(lift.vehicle, lift.heading)
                            AttachEntityToEntity(lift.vehicle, lift.platform, 0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, false, false, true, false, 20, true)
                        end
                        Citizen.Wait(10)
                    end
                end)
            elseif direction == 'down' then
                Citizen.CreateThread(function()
                    while platformCoords.z > lift.startZ do
                        platformCoords = GetEntityCoords(lift.platform)
                        SetEntityCoords(lift.platform, platformCoords.x, platformCoords.y, platformCoords.z - step, 0, 0, 0, false)
                        if lift.vehicle then
                            local vehicleCoords = GetEntityCoords(lift.vehicle)
                            SetEntityCoords(lift.vehicle, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z - step, 0, 0, 0, false)
                            SetEntityHeading(lift.vehicle, lift.heading)
                            AttachEntityToEntity(lift.vehicle, lift.platform, 0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, false, false, true, false, 20, true)
                            DetachEntity(lift.vehicle, false, true)
                        end
                        Citizen.Wait(10)
                    end
                end)
            end
        end
    end
end)

RegisterNUICallback('moveLift', function(data, cb)
    local direction = data.direction
    TriggerEvent('nkhd_carlift:moveLift', direction)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    UIopen = false
    SendNUIMessage({ action = 'close' })
    cb('ok')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, lift in ipairs(lifts) do
            if lift.frame then
                DeleteObject(lift.frame)
            end
            if lift.platform then
                DeleteObject(lift.platform)
            end
            if lift.vehicle then
                DetachEntity(lift.vehicle, false, true)
                FreezeEntityPosition(lift.vehicle, false)
            end
        end
    end
end)
