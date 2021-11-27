TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local reset = false

RegisterServerEvent("giveReward")
AddEventHandler("giveReward", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local rewards = math.random(1,3)
    for i=1, rewards do
        type = math.random(1,10)
        if type >= 5 then
            type = 3
        elseif type > 1 and type < 5 then
            type = 2
        end
        local reward = math.random(1, #ConfigVengelico.items[type])
        local amount = math.random(1, 10) / 3
        xPlayer.addInventoryItem(ConfigVengelico.items[type][reward], amount)
    end

end)

RegisterNetEvent("alterTable")
AddEventHandler("alterTable", function(table)
    TriggerClientEvent("alterLooted", -1, table)
end)

RegisterNetEvent("resetTable")
AddEventHandler("resetTable", function()
    reset = false
    Citizen.Wait(1000)
    reset = true
    while reset do
        Citizen.Wait(ConfigVengelico.resetTime * 60000)
        local table = {}
        TriggerClientEvent("alterLooted", -1, table)
        reset = false
    end
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

RegisterServerEvent('vengelico:modelswap')
AddEventHandler('vengelico:modelswap', function(coords, model1, model2)
    TriggerClientEvent('vengelico:modelswap', -1, coords, model1, model2)
end)