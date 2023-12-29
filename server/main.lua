ESX = exports["es_extended"]:getSharedObject()
ESX.RegisterServerCallback('0garage0:getVehicles', function(source, cb, parking)
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM owned_vehicles WHERE owner = ?',{xPlayer.identifier}, 
	function(result)

		local vehicles = {['0'] = {}, ['1'] = {}}
		for i = 1, #result, 1 do
			if type(result[i].stored) ~= 'number' then
				print('[ERROR] Please run SQL before using the script')
				return
			end
			if result[i].stored == 0 or not parking or result[i].parking == parking then
				table.insert(vehicles[tostring(result[i].stored)], {
					vehicle 	= json.decode(result[i].vehicle),
					plate 		= result[i].plate,
				})
			end
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('0garage0:checkVehicleOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT COUNT(*) as count FROM owned_vehicles WHERE owner = ? AND `plate` = ?',{xPlayer.identifier, plate},
	function(result)

		if tonumber(result[1].count) > 0 then
			return cb(true)
		else
			return cb(false)
		end
	end)
end)

RegisterServerEvent('0garage0:updateOwnedVehicle')
AddEventHandler('0garage0:updateOwnedVehicle', function(stored, parking, vehicleProps, entity, shouldPay)
	local source = source
	local xPlayer  = ESX.GetPlayerFromId(source)
	if entity and stored == 1 then
		local Vehicle = NetworkGetEntityFromNetworkId(entity)
		if DoesEntityExist(Vehicle) then
			DeleteEntity(Vehicle)
		end
	end
	if shouldPay then
		if xPlayer.getMoney() >= Config.ImpoundCost then
			xPlayer.removeMoney(Config.ImpoundCost, "Impound Fee")
			TriggerClientEvent('esx:showNotification', source, _U('pay_Impound_bill', Config.ImpoundCost))
		else
			TriggerClientEvent('esx:showNotification', source,_U('missing_money'))
			local Vehicle = NetworkGetEntityFromNetworkId(entity)
			if DoesEntityExist(Vehicle) then
				DeleteEntity(Vehicle)
			end
			return
		end
	end

	MySQL.update('UPDATE owned_vehicles SET stored = ?, vehicle = ?, parking = ? WHERE plate = ? AND owner = ?',{stored, json.encode(vehicleProps), parking, vehicleProps.plate, xPlayer.identifier})
	print(stored)
	if stored == 1 then
		TriggerClientEvent('esx:showNotification', source, _U('veh_stored'))
	end
		
end)

ESX.RegisterServerCallback('0garage0:delVehBeforeRetrieve', function(source, cb, plate)
	if Config.retrieveVerify then
		local source = source
		local veh = GetAllVehicles()
		local my_ped = GetPlayerPed(source)
		local found, canDel = false, nil
		for k, v in pairs(veh) do
			local veh_plate = ESX.Math.Trim(GetVehicleNumberPlateText(v))
			if veh_plate == plate then
				found = true
					local last_ped = GetLastPedInVehicleSeat(v, -1)
					if last_ped == my_ped or last_ped == 0 then
						canDel = v
					elseif GetVehicleEngineHealth(v) <= 0 or GetVehicleBodyHealth(v) <= 0 then
						canDel = v
					end
				break
			end
		end
		local xPlayer = ESX.GetPlayerFromId(source)
		if found and canDel then
			if DoesEntityExist(canDel) then
				DeleteEntity(canDel)
			end
			TriggerClientEvent('esx:showNotification', source, '已刪除仍存在的車輛')
			cb(true) 
		elseif not found then
			cb(true)
		else
			TriggerClientEvent('esx:showNotification', source, '車輛依然存在，無法領取')
			cb(false)
		end
	else
		cb(true)
	end
end)

ESX.RegisterServerCallback('0garage0:checkMoney', function(source, cb, amount)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.getMoney() >= amount)
end)
