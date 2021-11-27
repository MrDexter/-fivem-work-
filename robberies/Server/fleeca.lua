local SavedPhases = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("addItem")
AddEventHandler("addItem", function(item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(item, amount)
end)

RegisterServerEvent("removeItem")
AddEventHandler("removeItem", function(amount, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.RemoveInventoryItem(amount, item)
end)

ESX.RegisterServerCallback("checkItem", function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local amount = xPlayer.getInventoryItem(item).count
    print(amount)
    cb(amount)
end)

RegisterServerEvent("savePhases")
AddEventHandler("savePhases", function(savePhases)
    print(savePhases)
    print(json.encode(savePhases))
    print("Sending Phases")
    SavedPhases = savePhases
    TriggerClientEvent("sendPhases", -1, SavedPhases)
end)