print("^20garage0 (free version) by sum00er. https://discord.gg/pjuPHPrHnx")
local LastMarker, LastPart, thisGarage, thisPound = nil, nil, nil, nil
local next = next
local nearMarker, menuIsShowed = false, false
local vehiclesList, vehiclesImpoundedList = {}, {}

RegisterNetEvent('0garage0:closemenu')
AddEventHandler('0garage0:closemenu', function()
    menuIsShowed = false
    vehiclesList, vehiclesImpoundedList = {}, {}

    SetNuiFocus(false)
    SendNUIMessage({
        close = true
    })

    if not menuIsShowed and thisGarage then
        ESX.TextUI(_U('access_parking'))
    end
    if not menuIsShowed and thisPound then
        ESX.TextUI(_U('access_Impound', Config.ImpoundCost))
    end
end)

RegisterNUICallback('close', function(data, cb)
    TriggerEvent('0garage0:closemenu')
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local spawnCoords = {
        x = data.spawnPoint.x,
        y = data.spawnPoint.y,
        z = data.spawnPoint.z
    }

    if thisGarage then

        if ESX.Game.IsSpawnPointClear(spawnCoords, 2.5) then
            ESX.Game.SpawnVehicle(data.vehicleProps.model, spawnCoords, data.spawnPoint.heading, function(vehicle)
                TaskWarpPedIntoVehicle(ESX.PlayerData.ped, vehicle, -1)
                ESX.Game.SetVehicleProperties(vehicle, data.vehicleProps)
                SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), true, true)
            end)

            thisGarage = nil

            TriggerServerEvent('0garage0:updateOwnedVehicle', false, nil, data.vehicleProps)
            TriggerEvent('0garage0:closemenu')

            ESX.ShowNotification(_U('veh_released'))
            ESX.HideUI()

        else
            ESX.ShowNotification(_U('veh_block'), 'error')
        end

    elseif thisPound then

        ESX.TriggerServerCallback('0garage0:checkMoney', function(hasMoney)
            if hasMoney then
                if ESX.Game.IsSpawnPointClear(spawnCoords, 2.5) then
                    TriggerServerEvent('0garage0:payPound', Config.ImpoundCost)

                    ESX.Game.SpawnVehicle(data.vehicleProps.model, spawnCoords, data.spawnPoint.heading,
                        function(vehicle)
                            TaskWarpPedIntoVehicle(ESX.PlayerData.ped, vehicle, -1)
                            ESX.Game.SetVehicleProperties(vehicle, data.vehicleProps)
                            SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), true, true)
                        end)

                    thisPound = nil

                    TriggerServerEvent('0garage0:updateOwnedVehicle', false, nil, data.vehicleProps)
                    TriggerEvent('0garage0:closemenu')
                    ESX.HideUI()
                else
                    ESX.ShowNotification(_U('veh_block'), 'error')
                end
            else
                ESX.ShowNotification(_U('missing_money'))
            end
        end, Config.ImpoundCost)

    end

    cb('ok')
end)



-- Create Blips
CreateThread(function()
    for k, v in pairs(Config.Garages) do
        local blip = AddBlipForCoord(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)

        SetBlipSprite(blip, v.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, v.Scale)
        SetBlipColour(blip, v.Colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(_U('parking_blip_name'))
        EndTextCommandSetBlipName(blip)
    end

    for k, v in pairs(Config.Impounds) do
        local blip = AddBlipForCoord(v.GetOutPoint.x, v.GetOutPoint.y, v.GetOutPoint.z)

        SetBlipSprite(blip, v.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, v.Scale)
        SetBlipColour(blip, v.Colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(_U('Impound_blip_name'))
        EndTextCommandSetBlipName(blip)
    end
end)

AddEventHandler('0garage0:hasEnteredMarker', function(name, part)
    if part == 'EntryPoint' then
        local garage = Config.Garages[name]
        thisGarage = garage
        ESX.TextUI(_U('access_parking'))
    elseif part == 'StopPoint' then
        local garage = Config.Garages[name]
        thisGarage = garage
        ESX.TextUI(_U('park_veh'))
    elseif part == 'GetOutPoint' then
        local pound = Config.Impounds[name]
        thisPound = pound

        ESX.TextUI(_U('access_Impound', Config.ImpoundCost))
    end
end)

AddEventHandler('0garage0:hasExitedMarker', function()
    thisGarage = nil
    thisPound = nil
    ESX.HideUI()
    TriggerEvent('0garage0:closemenu')
end)

-- Display markers
CreateThread(function()
    while true do
        local sleep = 500

        local playerPed = ESX.PlayerData.ped
        local coords = GetEntityCoords(playerPed)
        local inVehicle = IsPedInAnyVehicle(playerPed, false)

        -- parking
        for k, v in pairs(Config.Garages) do
            if not inVehicle then
            if (#(coords - vector3(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)) < Config.DrawDistance) then
                DrawMarker(Config.Markers.EntryPoint.Type, v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z, 0.0, 0.0,
                    0.0, 0, 0.0, 0.0, Config.Markers.EntryPoint.Size.x, Config.Markers.EntryPoint.Size.y,
                    Config.Markers.EntryPoint.Size.z, Config.Markers.EntryPoint.Color.r,
                    Config.Markers.EntryPoint.Color.g, Config.Markers.EntryPoint.Color.b, 100, false, true, 2, false,
                    false, false, false)
                sleep = 0
                break
            end
            else
            if (#(coords - vector3(v.StopPoint.x, v.StopPoint.y, v.StopPoint.z)) < Config.DrawDistanceStop) then
                DrawMarker(Config.Markers.StopPoint.Type, v.StopPoint.x, v.StopPoint.y, v.StopPoint.z, 0.0, 0.0,
                    0.0, 0, 0.0, 0.0, Config.Markers.StopPoint.Size.x, Config.Markers.StopPoint.Size.y,
                    Config.Markers.StopPoint.Size.z, Config.Markers.StopPoint.Color.r,
                    Config.Markers.StopPoint.Color.g, Config.Markers.StopPoint.Color.b, 100, false, true, 2, false,
                    false, false, false)
                sleep = 0
                break
            end
            end
        end

        -- Impound
        for k, v in pairs(Config.Impounds) do
            if (#(coords - vector3(v.GetOutPoint.x, v.GetOutPoint.y, v.GetOutPoint.z)) < Config.DrawDistance) then
                DrawMarker(Config.Markers.GetOutPoint.Type, v.GetOutPoint.x, v.GetOutPoint.y, v.GetOutPoint.z, 0.0, 0.0,
                    0.0, 0, 0.0, 0.0, Config.Markers.GetOutPoint.Size.x, Config.Markers.GetOutPoint.Size.y,
                    Config.Markers.GetOutPoint.Size.z, Config.Markers.GetOutPoint.Color.r,
                    Config.Markers.GetOutPoint.Color.g, Config.Markers.GetOutPoint.Color.b, 100, false, true, 2, false,
                    false, false, false)
                sleep = 0
                break
            end
        end

        if sleep == 0 then
            nearMarker = true
        else
            nearMarker = false
        end

        Wait(sleep)
    end
end)

-- Enter / Exit marker events (parking)
CreateThread(function()
    while true do
        if nearMarker then
            local playerPed = ESX.PlayerData.ped
            local coords = GetEntityCoords(playerPed)
            local isInMarker = false
            local currentMarker = nil
            local currentPart = nil

            for k, v in pairs(Config.Garages) do
                --garage
                if (#(coords - vector3(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)) <
                    Config.Markers.EntryPoint.Size.x) then
                    local isInVehicle = IsPedInAnyVehicle(playerPed, false)

                    if not isInVehicle then
                        isInMarker = true
                        currentMarker = k
                        currentPart = 'EntryPoint'
                        if IsControlJustReleased(0, 38) and not menuIsShowed then
                            ESX.TriggerServerCallback('0garage0:getVehiclesInParking', function(vehicles)
                                if next(vehicles) then
                                    menuIsShowed = true

                                    for i = 1, #vehicles, 1 do
                                        local vname = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model)
                                        local model = GetLabelText(vname)
                                        if model == 'NULL' then
                                            model = vname
                                        end
                                        table.insert(vehiclesList, {
                                            model = string.sub(model, 1, 10),
                                            plate = vehicles[i].plate,
                                            props = vehicles[i].vehicle
                                        })
                                    end

                                    local spawnPoint = {
                                        x = v.SpawnPoint.x,
                                        y = v.SpawnPoint.y,
                                        z = v.SpawnPoint.z,
                                        heading = v.SpawnPoint.heading
                                    }

                                    ESX.TriggerServerCallback('0garage0:getVehiclesInPound', function(vehicles)
                                        if next(vehicles) then

                                            for i = 1, #vehicles, 1 do
                                                local vname = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model)
                                                local model = GetLabelText(vname)
                                                if model == 'NULL' then
                                                    model = vname
                                                end
                                                table.insert(vehiclesImpoundedList, {
                                                    model = string.sub(model, 1, 10),
                                                    plate = vehicles[i].plate,
                                                    props = vehicles[i].vehicle
                                                })
                                            end

                                            SendNUIMessage({
                                                show = true,
                                                type = 'garage',
                                                vehiclesList = {json.encode(vehiclesList)},
                                                vehiclesImpoundedList = {json.encode(vehiclesImpoundedList)},
                                                spawnPoint = spawnPoint,
                                                locales = {
                                                    carplate = _U('plate'),
                                                    health = _U('health'),
                                                    retrieve = _U('retrieve'),
                                                    uploadphoto = _U('uploadphoto'),
                                                    rename = _U('rename'),
                                                    
                                                }
                                            })
                                        else
                                            SendNUIMessage({
                                                show = true,
                                                type = 'garage',
                                                vehiclesList = {json.encode(vehiclesList)},
                                                spawnPoint = spawnPoint,
                                                locales = {
                                                    carplate = _U('plate'),
                                                    health = _U('health'),
                                                    retrieve = _U('retrieve'),
                                                    uploadphoto = _U('uploadphoto'),
                                                    rename = _U('rename'),
                                                }
                                            })
                                        end
                                    end)

                                    SetNuiFocus(true, true)

                                    if menuIsShowed then
                                        ESX.HideUI()
                                    end
                                else
                                    menuIsShowed = true

                                    ESX.TriggerServerCallback('0garage0:getVehiclesInPound', function(vehicles)
                                        if next(vehicles) then

                                            for i = 1, #vehicles, 1 do
                                                local vname = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model)
                                                local model = GetLabelText(vname)
                                                if model == 'NULL' then
                                                    model = vname
                                                end
                                                table.insert(vehiclesImpoundedList, {
                                                    model = string.sub(model, 1, 10),
                                                    plate = vehicles[i].plate,
                                                    props = vehicles[i].vehicle
                                                })
                                            end


                                            SendNUIMessage({
                                                show = true,
                                                type = 'garage',
                                                vehiclesImpoundedList = {json.encode(vehiclesImpoundedList)},
                                                locales = {
                                                    carplate = _U('plate'),
                                                    health = _U('health'),
                                                    retrieve = _U('retrieve'),
                                                    uploadphoto = _U('uploadphoto'),
                                                    rename = _U('rename'),
                                                }
                                            })
                                        else
                                            SendNUIMessage({
                                                show = true,
                                                type = 'garage',
                                                locales = {
                                                    carplate = _U('plate'),
                                                    health = _U('health'),
                                                    retrieve = _U('retrieve'),
                                                    uploadphoto = _U('uploadphoto'),
                                                    rename = _U('rename'),
                                                }
                                            })
                                        end
                                    end)

                                    SetNuiFocus(true, true)

                                    if menuIsShowed then
                                        ESX.HideUI()
                                    end
                                end
                            end)
                        end
                    end
                    break
                end
                if (#(coords - vector3(v.StopPoint.x, v.StopPoint.y, v.StopPoint.z)) <
                    Config.Markers.EntryPoint.Size.x) then
                    local isInVehicle = IsPedInAnyVehicle(playerPed, false)
                    if isInVehicle then
                        isInMarker = true
                        currentMarker = k
                        currentPart = 'StopPoint'
                        if IsControlJustReleased(0, 38) then
                            local vehicle = GetVehiclePedIsIn(playerPed, false)
                            local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

                            ESX.TriggerServerCallback('0garage0:checkVehicleOwner', function(owner)
                                if owner then
                                    ESX.Game.DeleteVehicle(vehicle)
                                    TriggerServerEvent('0garage0:updateOwnedVehicle', true, nil,
                                        vehicleProps)
                                        ESX.HideUI()
                                else
                                    ESX.ShowNotification(_U('not_owning_veh'), 'error')
                                end
                            end, vehicleProps.plate)
                        end
                    end
                    break
                end
            end

            --impound
            for k, v in pairs(Config.Impounds) do

                if (#(coords - vector3(v.GetOutPoint.x, v.GetOutPoint.y, v.GetOutPoint.z)) < 2.0) then
                    isInMarker = true
                    currentMarker = k
                    currentPart = 'GetOutPoint'

                    if IsControlJustReleased(0, 38) and not menuIsShowed then
                        ESX.TriggerServerCallback('0garage0:getVehiclesInPound', function(vehicles)
                            if next(vehicles) then
                                menuIsShowed = true

                                for i = 1, #vehicles, 1 do
                                    local vname = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model)
                                    local model = GetLabelText(vname)
                                    if model == 'NULL' then
                                        model = vname
                                    end
                                    table.insert(vehiclesImpoundedList, {
                                        model = string.sub(model, 1, 10),
                                        plate = vehicles[i].plate,
                                        props = vehicles[i].vehicle
                                    })
                                end

                                local spawnPoint = {
                                    x = v.SpawnPoint.x,
                                    y = v.SpawnPoint.y,
                                    z = v.SpawnPoint.z,
                                    heading = v.SpawnPoint.heading
                                }
                                ESX.TriggerServerCallback('0garage0:getVehiclesInParking', function(vehicles)
                                    if next(vehicles) then
    
                                        for i = 1, #vehicles, 1 do
                                            local vname = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model)
                                            local model = GetLabelText(vname)
                                            if model == 'NULL' then
                                                model = vname
                                            end
                                            table.insert(vehiclesList, {
                                                model = string.sub(model, 1, 10),
                                                plate = vehicles[i].plate,
                                                props = vehicles[i].vehicle
                                            })
    
                                        end
                                    SendNUIMessage({
                                        show = true,
                                        type = 'impound',
                                        vehiclesList = {json.encode(vehiclesList)},
                                        vehiclesImpoundedList = {json.encode(vehiclesImpoundedList)},
                                        spawnPoint = spawnPoint,
                                        locales = {
                                            carplate = _U('plate'),
                                            health = _U('health'),
                                            retrieve = _U('retrieve'),
                                            uploadphoto = _U('uploadphoto'),
                                            rename = _U('rename'),
                                        }
                                    })
                                    else
                                        SendNUIMessage({
                                            show = true,
                                            type = 'impound',
                                            vehiclesImpoundedList = {json.encode(vehiclesImpoundedList)},
                                            spawnPoint = spawnPoint,
                                            locales = {
                                                carplate = _U('plate'),
                                                health = _U('health'),
                                                retrieve = _U('retrieve'),
                                                uploadphoto = _U('uploadphoto'),
                                                rename = _U('rename'),
                                            }
                                        })
                                    end
                                    vehiclesList = {}
                                    vehiclesImpoundedList = {}

                                    SetNuiFocus(true, true)

                                    if menuIsShowed then
                                     ESX.HideUI()
                                    end
                                end)
                            else
                                ESX.ShowNotification(_U('no_veh_Impound'))
                            end
                        end)
                    end
                    break
                end
            end

            if isInMarker and not HasAlreadyEnteredMarker or
                (isInMarker and (LastMarker ~= currentMarker or LastPart ~= currentPart)) then

                if LastMarker ~= currentMarker or LastPart ~= currentPart then
                    TriggerEvent('0garage0:hasExitedMarker')
                end

                HasAlreadyEnteredMarker = true
                LastMarker = currentMarker
                LastPart = currentPart

                TriggerEvent('0garage0:hasEnteredMarker', currentMarker, currentPart)
            end

            if not isInMarker and HasAlreadyEnteredMarker then
                HasAlreadyEnteredMarker = false

                TriggerEvent('0garage0:hasExitedMarker')
            end

            Wait(0)
        else
            Wait(500)
        end
    end
end)
