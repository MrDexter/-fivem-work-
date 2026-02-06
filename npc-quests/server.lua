local QBCore = exports['qb-core']:GetCoreObject()

local lastHeistTime = 0 

function GetPoliceCount()
    local policeCount = 0
    for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData.job.name == 'police' then
            policeCount = policeCount + 1
        end
    end
    return policeCount
end

QBCore.Functions.CreateCallback('jomidar-rr:sv:checkTime', function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    
    local currentTime = os.time()
    local timeSinceLastHeist = currentTime - lastHeistTime
    if timeSinceLastHeist < Config.RoofRunning["settings"].Cooldown  and lastHeistTime ~= 0 then
        local secondsRemaining = Config.RoofRunning["settings"].Cooldown  - timeSinceLastHeist
        TriggerClientEvent('QBCore:Notify', src, "You must wait " .. secondsRemaining .. " seconds before starting another work.", "error")
        cb(false)
    else
        lastHeistTime = currentTime
        cb(true)
    end
end)

RegisterNetEvent('npc-quests:sv:start')
AddEventHandler('npc-quests:sv:start', function()
    local source = source
    local policeCount = GetPoliceCount()
    if policeCount >= Config.RoofRunning["settings"].Police then
        TriggerClientEvent('npc-quests:start', source)
    else
        -- Notify the player who triggered the event that there are not enough police officers online
        TriggerClientEvent('QBCore:Notify', source, "Not enough police officers online.", "error")
    end
end)

RegisterNetEvent('npc-quests:handleInvItem', function(obj)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if player then
        -- Randomly select one item from the list
        local itemIndex = math.random(#Config.props[obj])
        local itemInfo = Config.props[obj][itemIndex]
        
        -- Add the randomly selected item to the player's inventory
        player.Functions.AddItem(itemInfo, 1)
        TriggerClientEvent('QBCore:Notify', src, "You have received a " .. itemInfo, "success")
    else
        print("Player not found on server.")
    end
end)