ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('tuner:itemamount', function(source, cb, item)
    local xPlayer  = ESX.GetPlayerFromId(source)
    local amount = xPlayer.getInventoryItem(item).count
    cb(amount)
end)

RegisterServerEvent('tuner:removeitem')
AddEventHandler("tuner:removeitem", function(item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(item, amount)
end)

RegisterServerEvent('tuner:additem')
AddEventHandler("tuner:additem", function(item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(item, amount)
end)


ESX.RegisterUsableItem('puncturekit', function(source)
	TriggerClientEvent('repair:puncturekit', source)
end)
