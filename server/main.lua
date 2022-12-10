RegisterServerEvent('0garage0:updateOwnedVehicle')
AddEventHandler('0garage0:updateOwnedVehicle', function(stored, Impound, vehicleProps)
	local source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

		MySQL.update('UPDATE owned_vehicles SET `stored` = @stored, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
		{
			['@identifier'] = xPlayer.identifier,
			['@vehicle'] 	= json.encode(vehicleProps),
			['@plate'] 		= vehicleProps.plate,
			['@stored']     = stored,
		})

		if stored then
			xPlayer.showNotification(_U('veh_stored'))
		end
end)

RegisterServerEvent('0garage0:setImpound')
AddEventHandler('0garage0:setImpound', function(Impound, vehicleProps)
	local source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

		MySQL.update('UPDATE owned_vehicles SET `stored` = @stored, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
		{
			['@identifier'] = xPlayer.identifier,
			['@vehicle'] 	= json.encode(vehicleProps),
			['@plate'] 		= vehicleProps.plate,
			['@stored']     = false,
		})

		xPlayer.showNotification(_U('veh_impounded'))
	
end)


ESX.RegisterServerCallback('0garage0:getVehiclesInParking', function(source, cb)
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `stored` = 1',
	{
		['@identifier'] 	= xPlayer.identifier
	}, function(result)

		local vehicles = {}
		for i = 1, #result, 1 do
			table.insert(vehicles, {
				vehicle 	= json.decode(result[i].vehicle),
				plate 		= result[i].plate
			})
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('0garage0:checkVehicleOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT COUNT(*) as count FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate',
	{
		['@identifier'] 	= xPlayer.identifier,
		['@plate']     		= plate
	}, function(result)

		if tonumber(result[1].count) > 0 then
			return cb(true)
		else
			return cb(false)
		end
	end)
end)

ESX.RegisterServerCallback('0garage0:getVehiclesInPound', function(source, cb)
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `stored` = @stored',
	{
		['@identifier'] 	= xPlayer.identifier,
		['@stored'] = 0 or 2
	}, function(result)
		local vehicles = {}

		for i = 1, #result, 1 do
			table.insert(vehicles, {
				vehicle 	= json.decode(result[i].vehicle),
				plate 		= result[i].plate
			})
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('0garage0:checkMoney', function(source, cb, amount)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.getMoney() >= amount)
end)

RegisterServerEvent("0garage0:payPound")
AddEventHandler("0garage0:payPound", function(amount)
		local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount, "Impound Fee")
				xPlayer.showNotification(_U('pay_Impound_bill', amount))
    else
		xPlayer.showNotification(_U('missing_money'))
    end
end)