TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("addItem")
AddEventHandler("addItem", function(item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(item, amount)
end)

RegisterServerEvent("giveMoney")
AddEventHandler("giveMoney", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = math.random(Config.Store.MinMoney, Config.Store.MaxMoney)
    print(money)
    xPlayer.addMoney(money)
end)


RegisterNetEvent("alterTable")
AddEventHandler("alterTable", function(table)
    TriggerClientEvent("alterLooted", -1, table)
end)

RegisterNetEvent("resetTable")
AddEventHandler("resetTable", function()
    reset = true
    while reset do
        Citizen.Wait(Config.Store.resetTime * 60000)
        local table = {}
        TriggerClientEvent("alterLooted", -1, table)
        reset = false
    end
end)