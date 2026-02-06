local QBCore = exports['qb-core']:GetCoreObject()

local zones = {}
local foundObjects = {}
local entities = {}
local failedAttempts = 0
local collectedUnits = 0
local maxUnits = 10
local activeJob = false

function createVisualZone(position, zoneId)
    local zone = {}
    local blip = AddBlipForRadius(position.x, position.y, position.z, 50.0)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 128)
    zone.blip = blip
    zones[zoneId] = zone  
    return zone
end

CreateThread(function()
    while true do
        Wait(0)
        for _, zone in ipairs(zones) do
            DrawMarker(1, zone.position.x, zone.position.y, zone.position.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, zone.size.x, zone.size.y, zone.size.z, zone.color.r, zone.color.g, zone.color.b, zone.color.a, false, false, 2, false, nil, nil, false)
        end
    end
end)

function addTargetOption(center)
        local currentCFG = Config.RoofRunning['settings']['target']
        local options = {
            {
                label = currentCFG.label,
                icon = currentCFG.icon,
                event = currentCFG.event,
                distance = 1.5,
                canInteract = function(entity, distance, coords, name, bone)
                    local dist = #(coords - center)
                    if dist <= 50.0 then
                        local hasTools = true -- TODO has tools
                        if hasTools then
                            return not entities[entity]
                        end
                    end
                end,
            },
        }
    for prop, data in pairs(Config.props) do
        exports.ox_target:addModel(prop, options)
    end
end

-- GetGamePool = Objects loaded on player doesn't work if far away. Add check that waits untill player within 250m if need it?
--[[ function setupTargets(center)
    local radius = 50.0
    local allObjects = GetGamePool("CObject")
    for _, obj in ipairs(allObjects) do
        if DoesEntityExist(obj) then
            local model = GetEntityModel(obj)
            if Config.props[model] then
                local coords = GetEntityCoords(obj)
                if #(coords - center) <= radius then
                    table.insert(foundObjects, obj)
                    addTargetOption(obj) -- Your interaction logic
                end
            end
        end
    end
end ]]

function removeVisualZone(zoneId)
    if zones[zoneId] then
        RemoveBlip(zones[zoneId].blip)  -- Remove the blip associated with the zone
        zones[zoneId] = nil             -- Clear the entry from the zones table
    end
end


RegisterNetEvent('npc-quests:start')
AddEventHandler('npc-quests:start', function()
    if not activeJob then
        QBCore.Functions.TriggerCallback('jomidar-rr:sv:checkTime', function(time)
            if time then
                reset()
                Wait(1)
                local activeJob = true
                local acList = Config.Area --Config.RoofRunning["acprops"]
                local randomIndex = math.random(1, #acList)
                local center = acList[randomIndex]
                maxunits = math.random(Config.MinUnits, Config.MaxUnits)
                addTargetOption(center)
                createVisualZone(center, "centralZone")
                -- TODO broadcast selected to server to stop multiple people doing same one. 
                Wait(Config.JobLength * 60000)
                QBCore.Functions.Notify("The job has expired", "success", 5000)
                reset()
                -- Wait x amount and reset removed units?
            end
        end)
    end
end)


RegisterNetEvent('npc-quests:cl:start')
AddEventHandler('npc-quests:cl:start', function(data)
    local entity = data.entity
    local player = source
    
    if DoesEntityExist(entity) then        
        -- local success = exports['np_mini']:RoofRunning(7,11, 20)
        local success = true
        if success then
            QBCore.Functions.Progressbar("remove_ac", "Steal Ac Component..", Config.RoofRunning['settings'].ProgressBarTime, false, true, {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "mini@repair",
                anim = "fixing_a_ped",
                flags = 49,
            }, {}, {}, function()
                if DoesEntityExist(entity) then
                    -- DeleteObject(entity) -- TODO Delete / Hide for x amount of time
                    collectedUnits = collectedUnits +1
                    entities[entity] = true
                    QBCore.Functions.Notify("You have removed a component ".. collectedUnits .. "/" .. maxUnits, "success", 5000)
                    TriggerServerEvent('npc-quests:handleInvItem', GetEntityModel(entity))
                    if collectedUnits >= maxUnits then
                        QBCore.Functions.Notify("You have collected enough components", "success", 5000)
                        reset()
                    end
                end
            end, function()
                QBCore.Functions.Notify("Failed to remove AC Part. Try again!", "error", 5000)
            end)
        else
            failedAttempts = failedAttempts +1
            if failedAttempts >= Config.AlarmAfter then
                if not alarmTriggered then
                    -- Trigger Allarm Maybe by chance?
                    alarmTriggered = true
                end
            end
            if failedAttempts >= Config.maxFails then
                QBCore.Functions.Notify("Failed To Breach The Security System. System Shutdown", "error", 5000)
                reset()
            else
                QBCore.Functions.Notify("Failed To Breach The Security System. Try again!", "error", 5000)
            end
        end
    end
end)

function removeAllTargets()
    for prop, data in pairs(Config.props) do
        exports.ox_target:removeModel(prop)
    end
    entities = {};

end

function reset()
    failedAttempts = 0
    collectedUnits = 0
    activeJob = false
    removeAllTargets()
    removeVisualZone("centralZone")
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        removeAllTargets()
    end
end)

RegisterNetEvent('npc-quests:serverStart')
AddEventHandler('npc-quests:serverStart', function()
    TriggerServerEvent('npc-quests:sv:start')
end)


if Config.RoofRunning['settings'].npc == true then
    Citizen.CreateThread(function()
        local currentCFG = Config.RoofRunning['settings']['npc']
        exports['qb-target']:SpawnPed({
            model = currentCFG.ped, 
            coords = currentCFG.coords, 
            freeze = true,
            invincible = false, 
            blockevents = true, 
            target = { 
                options = { 
                    { 
                    type = "client",
                    event = currentCFG.event, 
                    icon = currentCFG.icon,
                    label = currentCFG.text,
                    }
                },
                distance = 2.5, 
            },
            spawnNow = true,
        })
    end)
end


    TriggerServerEvent('npc-quests:sv:start')