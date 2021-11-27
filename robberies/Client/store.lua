TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local Looted = {}

RegisterNetEvent("tillRobbery")
AddEventHandler("tillRobbery", function()
    -- Alert Police
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local entity = GetClosestObjectOfType(pedCoords, 1.5, 303280717)
    local entityHeading = GetEntityHeading(entity)
    local health = GetEntityHealth(entity)
    local offset =  vector3(-0.003411576, -0.6869478, -1.1110764)
    local objCoords = GetEntityCoords(entity)
    if Looted[objCoords] ~= nil then ESX.ShowNotification("Already Looted") return end    
    if health < 1000 then
        local animCoords = GetOffsetFromEntityInWorldCoords(entity, offset)
        local distance = GetDistanceBetweenCoords(pedCoords, animCoords)
        if distance < 1.0 then
            Looted[objCoords] = true
            SetEntityCoords(ped, animCoords)
            SetEntityHeading(ped, entityHeading)
            while not HasAnimDictLoaded('oddjobs@shop_robbery@rob_till') do
                RequestAnimDict('oddjobs@shop_robbery@rob_till')
            end
            print(HasAnimDictLoaded('oddjobs@shop_robbery@rob_till'))
            TaskPlayAnim(ped, "oddjobs@shop_robbery@rob_till", "loop", 1.5, 1.5, -1, 1, 5.0, 0, 0, 0)
            Citizen.Wait(5000)
            ClearPedTasks(ped)
            TriggerServerEvent("giveMoney")
            TriggerServerEvent("alterTable", Looted)
            TriggerServerEvent("resetTable")
        else
            ESX.ShowNotification("Make sure you are on the correct side.")
        end
    else
        ESX.ShowNotification("Find a way to open the cash register")
    end
end)

RegisterNetEvent("alterLooted")
AddEventHandler("alterLooted", function(table)
    Looted = table
end)

exports['qtarget']:AddTargetModel({-1375589668}, {
    options = {
        {
            event = "safeRobbery",
            icon = "fas fa-box-circle-check",
            label = "Open Safe",
        },
    },
distance = 1.5
})


exports['qtarget']:AddTargetModel({303280717}, {
        options = {
            {
                event = "tillRobbery",
                icon = "fas fa-box-circle-check",
                label = "Rob Cash Register",
            },
        },
    distance = 1.0
})


RegisterCommand("clear", function()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
end)

RegisterNetEvent("safeRobbery")
AddEventHandler("safeRobbery", function()  
    TriggerEvent("Drilling:Start", function(success)
        if success then
            OpenDoor()
        else
            ESX.ShowNotification("Drill bit broke")
            -- Take drill bit from inventory
        end
    end)
end)

function OpenDoor()
    local safe = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 1.5, -1375589668)
    local rotation = GetEntityRotation(safe)["z"]
    local doorRot = rotation
    Citizen.CreateThread(function()
        FreezeEntityPosition(safe, false)

        while rotation <= doorRot + 100.0 do
            Citizen.Wait(1)

            rotation = rotation + 0.25

            SetEntityRotation(safe, 0.0, 0.0, rotation)
        end

        FreezeEntityPosition(safe, true)
    end)

end