local Looted = {}

-- https://gta-objects.xyz/objects/search?text=des_jewel 

RegisterNetEvent("smashcase")
AddEventHandler("smashcase", function(data)
    local animCoords = nil
    local model = data.item
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local case = GetClosestObjectOfType(pedCoords, 1.0, ConfigVengelico.models[model][1])
    local objCoords = GetEntityCoords(case)
    if Looted[objCoords] ~= nil then ESX.ShowNotification("Already Looted") return end
    local weapon = false
    for k, v in pairs(ConfigVengelico.weapons) do
        local pedWeapon = GetSelectedPedWeapon(ped)
        if pedWeapon == GetHashKey(v) then
            weapon = true
            break
        end
    end
    if weapon == false then ESX.ShowNotification("You'll need a big gun for this") return end
    local animDict = 'missheist_jewel'
    local ptfxAsset = "scr_jewelheist"
    local particleFx = "scr_jewel_cab_smash"
    RequestAnimDict(animDict)
    RequestNamedPtfxAsset(ptfxAsset)
    local offsets = {
        [1] = vec3(0.1016615, -0.993142, -0.5506248), -- All other cases
        [2] = vec3(1.10151, -0.1566475, -0.550628) --Case 4 only
    }
    local caseRot = {}
    caseRot.x, caseRot.y, caseRot.z = table.unpack(GetEntityRotation(case))
    local anims = {
        'smash_case_necklace',
        'smash_case_d',
        'smash_case_e',
        'smash_case_f',
    }
    if model == 4 then
        anim = 'smash_case_necklace_skull'
        animCoords = GetOffsetFromEntityInWorldCoords(case, offsets[2]) 
        caseRot.z = caseRot.z + 90.39797
    else
        anim = anims[math.random(1, #anims)]
        animCoords = GetOffsetFromEntityInWorldCoords(case, offsets[1]) 
    end
    scene = NetworkCreateSynchronisedScene(animCoords, caseRot.x, caseRot.y, caseRot.z, 2, true, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, scene, animDict, anim, 2.0, 4.0, 1, 0, 1148846080, 0)
    NetworkStartSynchronisedScene(scene)

    Wait(300)

    for i = 1, 5 do
        PlaySoundFromCoord(-1, "Glass_Smash", objCoords, 0, 0, 0)
    end
    TriggerServerEvent("vengelico:modelswap", objCoords, ConfigVengelico.models[model][1], ConfigVengelico.models[model][2])
    Looted[objCoords] = true
    TriggerServerEvent("alterTable", Looted)
    TriggerServerEvent("resetTable")
    SetPtfxAssetNextCall(ptfxAsset)
    StartNetworkedParticleFxNonLoopedAtCoord(particleFx, objCoords, 0.0, 0.0, 0.0, 2.0, 0, 0, 0)
    Wait(GetAnimDuration(animDict, anim) * 1000 - 1000)
    ClearPedTasks(ped)
    TriggerServerEvent("giveReward")
end)

RegisterNetEvent("vengelico:modelswap")
AddEventHandler("vengelico:modelswap", function(Coords, model1, model2)
    CreateModelSwap(Coords, 0.5, model1, model2)
end)

RegisterNetEvent("alterLooted")
AddEventHandler("alterLooted", function(table)
    Looted = table
end)


exports['qtarget']:AddTargetModel({37228785}, {
    options = {
        {
            event = "smashcase",
            icon = "fas fa-box-circle-check",
            label = "Smash case",
            item = 1,
        },
    },
distance = 1.5
})
exports['qtarget']:AddTargetModel({-1846370968}, {
    options = {
        {
            event = "smashcase",
            icon = "fas fa-box-circle-check",
            label = "Smash case",
            item = 2,
        },
    },
distance = 1.5
})
exports['qtarget']:AddTargetModel({1768229041}, {
    options = {
        {
            event = "smashcase",
            icon = "fas fa-box-circle-check",
            label = "Smash case",
            item = 3,
        },
    },
distance = 1.5
})
exports['qtarget']:AddTargetModel({-1880169779}, {
    options = {
        {
            event = "smashcase",
            icon = "fas fa-box-circle-check",
            label = "Smash case",
            item = 4,
        },
    },
distance = 1.5
})