ESX = exports["es_extended"]:getSharedObject()
local isInMenu = false
local isImpound = false

Citizen.CreateThread(function()
    print("^20garage0 by sum00er. https://discord.gg/pjuPHPrHnx")
    for k, v in pairs(Config.Garages) do
        local BlipData = v.blip
        if BlipData.Enable then
            local blip = AddBlipForCoord(BlipData.Coords)

            SetBlipSprite(blip, BlipData.Sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, BlipData.Scale)
            SetBlipColour(blip, BlipData.Colour)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(BlipData.Text)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = true
        while isInMenu do Citizen.Wait(1000) end
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for parking, v in pairs(Config.Garages) do
            if not Config.SeperateGarage then parking = nil end
            for k, n in pairs(v.coords) do
                local dist = #(coords - n)
                if dist < Config.DrawDistance then
                    sleep = false
                    DrawMarker(Config.Markers[k].Type, n.x, n.y, n.z, 0.0, 0.0,
                        0.0, 0, 0.0, 0.0, Config.Markers[k].Size.x, Config.Markers[k].Size.y,
                        Config.Markers[k].Size.z, Config.Markers[k].Color.r,
                        Config.Markers[k].Color.g, Config.Markers[k].Color.b, 255, false, true, 2, false,
                        false, false, false)
                    if dist < Config.Markers[k].Size.x then
                        Config.TextUI(_U(k, Config.ImpoundCost))
                        textui = true
                        if IsControlJustReleased(0, 38) then
                            if k == 'EntryPoint' then
                                OpenGarageMenu(false, v.SpawnPoint, parking)
                            elseif k == 'StopPoint' then
                                StoreVehicle(parking)
                            elseif k == 'GetOutPoint' then
                                OpenGarageMenu(true, v.SpawnPoint)
                            end
                        end
                        break
                    elseif textui then
                        textui = false
                        Config.CloseUI()
                    end
                end
            end
        end
        Citizen.Wait(0)
        if sleep then
            Citizen.Wait(1000)
        end
    end
end)

function OpenGarageMenu(isimpound, SpawnPoint, parking)
    isInMenu = true
    isImpound = isimpound
    ESX.TriggerServerCallback('0garage0:getVehicles', function(vehicles)
        local NUIvehicleList = {{}, {}}
        for n = 0, 1 do
            local n = tostring(n)
            for i = 1, #vehicles[n], 1 do
                local model
                local vname = GetDisplayNameFromVehicleModel(vehicles[n][i].vehicle.model)
                model = GetLabelText(vname)
                if model == 'NULL' then
                    model = vname
                end
                model = string.sub(model, 1, 10)
                table.insert(NUIvehicleList[(tonumber(n) + 1)], {
                    model = model,
                    plate = vehicles[n][i].plate,
                    props = vehicles[n][i].vehicle,
                })
            end
        end
        local garage = 'garage'
        if isImpound then
            garage = 'impound'
        end
        SetNuiFocus(true, true)
        SendNUIMessage({
            show = true,
            type = garage,
            vehiclesList = not next(NUIvehicleList[2]) or {json.encode(NUIvehicleList[2])},
            vehiclesImpoundedList = not next(NUIvehicleList[1]) or {json.encode(NUIvehicleList[1])},
            spawnPoint = SpawnPoint,
            locales = {
                carplate = _U('plate'),
                health = _U('health'),
                fuel = _U('fuel'),
                retrieve = _U('retrieve'),
                uploadphoto = _U('uploadphoto'),
                rename = _U('rename'),
            }
        })
    end, parking)
end
exports('OpenGarageMenu', OpenGarageMenu)

function StoreVehicle(parking)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

    ESX.TriggerServerCallback('0garage0:checkVehicleOwner', function(owner)
        if owner then
            local networkId = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('impoundVeh:sv', networkId)
            TriggerServerEvent('0garage0:updateOwnedVehicle', 1, parking, vehicleProps, networkId)
        else
            ESX.ShowNotification(_U('not_owning_veh'), 'error')
        end
    end, vehicleProps.plate)
end

function CloseMenu()
    isInMenu = false
    SetNuiFocus(false)
    SendNUIMessage({
        close = true
    })
end
exports('StoreVehicle', StoreVehicle)

--NUI
RegisterNUICallback('close', function(data, cb)
    CloseMenu()
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local spawnCoords = data.spawnPoint
    local money
    if isImpound then
        ESX.TriggerServerCallback('0garage0:checkMoney', function(hasMoney)
            money = hasMoney
        end)
        while money == nil do Citizen.Wait(100) end
        if money < Config.ImpoundCost then
            ESX.ShowNotification(_U('missing_money'))
            return
        end
    end
    if ESX.Game.IsSpawnPointClear(spawnCoords, 2.5) then
        if retrieving then
            return
        end
        retrieving = true
        local plate = ESX.Math.Trim(data.vehicleProps.plate)
        ESX.TriggerServerCallback('0garage0:delVehBeforeRetrieve', function(cb)
            if cb then
                ESX.Game.SpawnVehicle(data.vehicleProps.model, spawnCoords, data.spawnPoint.w, function(vehicle)
                    TaskWarpPedIntoVehicle(ESX.PlayerData.ped, vehicle, -1)
                    ESX.Game.SetVehicleProperties(vehicle, data.vehicleProps)
                    SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), true, true)
                end)

                TriggerServerEvent('0garage0:updateOwnedVehicle', 0, nil, data.vehicleProps, vehicle, isImpound)
                
                ESX.ShowNotification(_U('veh_released'))
            end
            retrieving = false
        end, plate)
        CloseMenu()
    else
        ESX.ShowNotification(_U('veh_block'), 'error')
    end
end)
