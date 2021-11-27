local data = nil
local SavedPhases = {}
local currentgrab
local code = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	PlayerData = ESX.GetPlayerData()
		
	esxloaded = true
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	TriggerServerEvent('esx_garbagecrew:setconfig')
end)

RegisterNetEvent("utku:hackinganim")
AddEventHandler("utku:hackinganim", function()
    local animDict = "anim@heists@ornate_bank@hack"

    RequestAnimDict(animDict)
    RequestModel("hei_prop_hst_laptop")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestModel("hei_prop_heist_card_hack_02")

    while not HasAnimDictLoaded(animDict)
        or not HasModelLoaded("hei_prop_hst_laptop")
        or not HasModelLoaded("hei_p_m_bag_var22_arm_s")
        or not HasModelLoaded("hei_prop_heist_card_hack_02") do
        Citizen.Wait(100)
    end
    local ped = PlayerPedId()
    local targetPosition, targetRotation = (vec3(GetEntityCoords(ped))), vec3(GetEntityRotation(ped))
    local animPos = GetAnimInitialOffsetPosition(animDict, "hack_enter", 148.18, -1046.25, 29.5, 148.18, -1046.25, 29.5, 0, 2) -- Animasyon kordinatları, buradan lokasyonu değiştirin // These are fixed locations so if you want to change animation location change here
    local animPos2 = GetAnimInitialOffsetPosition(animDict, "hack_loop", 148.18, -1046.25, 29.5, 148.18, -1046.25, 29.5, 0, 2)
    local animPos3 = GetAnimInitialOffsetPosition(animDict, "hack_exit", 148.18, -1046.25, 29.5, 148.18, -1046.25, 29.5, 0, 2)
    -- part1
    FreezeEntityPosition(ped, true)
    local netScene = NetworkCreateSynchronisedScene(animPos, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene, animDict, "hack_enter", 1.5, -4.0, 1, 16, 1148846080, 0)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), targetPosition, 1, 1, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene, animDict, "hack_enter_bag", 4.0, -8.0, 1)
    local laptop = CreateObject(GetHashKey("hei_prop_hst_laptop"), targetPosition, 1, 1, 0)
    NetworkAddEntityToSynchronisedScene(laptop, netScene, animDict, "hack_enter_laptop", 4.0, -8.0, 1)
    local card = CreateObject(GetHashKey("hei_prop_heist_card_hack_02"), targetPosition, 1, 1, 0)
    NetworkAddEntityToSynchronisedScene(card, netScene, animDict, "hack_enter_card", 4.0, -8.0, 1)
    -- part2
    local netScene2 = NetworkCreateSynchronisedScene(animPos2, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene2, animDict, "hack_loop", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene2, animDict, "hack_loop_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene2, animDict, "hack_loop_laptop", 2.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(card, netScene2, animDict, "hack_loop_card", 4.0, -8.0, 1)
    -- -- part3
    local netScene3 = NetworkCreateSynchronisedScene(animPos3, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene3, animDict, "hack_exit", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene3, animDict, "hack_exit_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene3, animDict, "hack_exit_laptop", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(card, netScene3, animDict, "hack_exit_card", 4.0, -8.0, 1)
    --event başlangıç
    SetPedComponentVariation(ped, 5, 0, 0, 0) -- çantayı yok ediyoruz eğer varsa // removes bag from ped so no 2 bags
    SetEntityHeading(ped, 250.0) -- Animasyon düzgün oturması için yön // for proper animation direction

    NetworkStartSynchronisedScene(netScene)
    Citizen.Wait(4500) -- Burayı deneyerek daha iyi hale getirebilirsiniz // You can try editing this to make transitions perfect
    NetworkStopSynchronisedScene(netScene)

    NetworkStartSynchronisedScene(netScene2)
    Citizen.Wait(4500)
    NetworkStopSynchronisedScene(netScene2)

    NetworkStartSynchronisedScene(netScene3)
    Citizen.Wait(4500)
    NetworkStopSynchronisedScene(netScene3)

    DeleteObject(bag)
    DeleteObject(laptop)
    DeleteObject(card)
    FreezeEntityPosition(ped, false)
    --SetPedComponentVariation(ped, 5, 45, 0, 0) --gives bag back to ped
end)

function Location()
    local coords = GetEntityCoords(PlayerPedId())
    for k, v in pairs(Config.Banks) do
        local distance = GetDistanceBetweenCoords(coords, v.doors.startloc.x, v.doors.startloc.y, v.doors.startloc.z, true)
        if distance <= 5 then
            data = v
            break
        end
    end
    return data
end

RegisterNetEvent("startRobbery")
AddEventHandler("startRobbery", function ()
    data = Location()
    ResetDoor()
    currentcoords = vector3(data.doors.startloc.x, data.doors.startloc.y, data.doors.startloc.z)
    RequestModel("p_ld_id_card_01")
    while not HasModelLoaded("p_ld_id_card_01") do
        Citizen.Wait(1)
    end
    local ped = PlayerPedId()

    SetEntityCoords(ped, data.doors.startloc.animcoords.x, data.doors.startloc.animcoords.y, data.doors.startloc.animcoords.z)
    SetEntityHeading(ped, data.doors.startloc.animcoords.h)
    local pedco = GetEntityCoords(PlayerPedId())
    IdProp = CreateObject(GetHashKey("hei_prop_heist_card_hack_02"), pedco, 1, 1, 0)
    local boneIndex = GetPedBoneIndex(PlayerPedId(), 28422)

    AttachEntityToEntity(IdProp, ped, boneIndex, 0.12, 0.028, 0.001, 20.0, 270.0, 180, true, true, false, true, 1, true)
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, true)
    Citizen.Wait(1500)
    DetachEntity(IdProp, false, false)
    SetEntityCoords(IdProp, data.prop.first.coords, 0.0, 0.0, 0.0, false)
    SetEntityRotation(IdProp, data.prop.first.rot, 1, true)
    FreezeEntityPosition(IdProp, true)
    Citizen.Wait(500)
    ClearPedTasksImmediately(ped)
    Citizen.Wait(1000)
    local attempts = 1
    while attempts < 4 and secretCode ~= Config.Code do
        secretCode = KeyboardInput("Enter the correct security code : (Attempt "..attempts..")", "", 4)
        Citizen.Wait(2500)
        attempts = attempts + 1
    end
        if secretCode == Config.Code then
            ESX.ShowNotification("Correct, Vault Opening")
            SpawnTrolleys()
            DoorInteraction()
            Wait(1000)
            OpenDoor()
        else
            ESX.ShowNotification("Systen Locked Down - Too many failed attempts")
        end
end)

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry)
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result --Returns the result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

function ResetDoor()
    local hash = nil
    if data.hash == nil then hash = Config.vaultdoor else hash = data.hash end
    local vault = GetClosestObjectOfType(data.doors.startloc.x, data.doors.startloc.y, data.doors.startloc.z, 3.0, hash)
    local gate = GetClosestObjectOfType(data.doors.secondloc.x, data.doors.secondloc.y, data.doors.secondloc.z, 3.0, Config.door)
    FreezeEntityPosition(gate, true)
    SetEntityRotation(vault, 0.0, 0.0, 249.846, 0.0)
end

--[[ function DoorReset(h)
    local door = GetClosestObjectOfType(148.025, -1044.364, 29.5, 3.0, 108706825)
    print(h)
    SetEntityRotation(door, 0.0, 0.0, tonumber(h), 0.0)
end

RegisterCommand("doorreset", function(source, args)
    DoorReset(args[1])
end)--]]

RegisterCommand("door", function()
    -- OpenDoor()
    data = Config.Banks[4]
    DoorInteraction()
end)

function OpenDoor()
    local hash = Config.vaultdoor
    --data = Config.Banks[4]
    ResetDoor()

    if data.hash ~= nil then hash = data.hash  end
    local door = GetClosestObjectOfType(data.doors.startloc.x, data.doors.startloc.y, data.doors.startloc.z, 3.0, hash)
    local rotation = GetEntityRotation(door)["z"]
    Citizen.CreateThread(function()
        FreezeEntityPosition(door, false)

        while rotation >= -183.599 do
            Citizen.Wait(1)

            rotation = rotation - 0.25

            SetEntityRotation(door, 0.0, 0.0, rotation)
        end

        FreezeEntityPosition(door, true)
    end)

end

function DoorInteraction()
    exports['qtarget']:AddBoxZone("PlantThermite", vector3(data.prop.second.coords), 0.4, 0.6, { -- 147.32, -1046.3, 29.37
    name="PlantThermite",
    heading=250,
    debugPoly=true,
    minZ=data.doors.startloc.z + 0.3,
    maxZ=data.doors.startloc.z + 0.5
    }, {
        options = {
            {
                event = "blowdoor",
                icon = "far fa-clipboard",
                label = "Place Thermite",
            },
        },
        distance = 10
    })
end

RegisterCommand("hash", function()
    print(GetHashKey("ch_prop_ch_cash_trolly_01c"))
end)

function SpawnTrolleys()
    local amount = math.random(1,3) -- Gruppe6:  ch_prop_ch_cash_trolly_01c - 412463629 Basic: hei_prop_hei_cash_trolly_01 - 269934519
    RequestModel(GetHashKey("hei_prop_hei_cash_trolly_01"))
    while not HasModelLoaded(GetHashKey("hei_prop_hei_cash_trolly_01")) do
        Citizen.Wait(100)
    end
    for i=1, amount do
        Trolley = CreateObject(269934519, data.trolleys[i].coords, 1, 0, 0)
        SetEntityHeading(Trolley, data.trolleys[i].h)
        exports['qtarget']:AddEntityZone("Trolley-"..Trolley, Trolley, {
            name = "Trolley-"..Trolley,
            heading = 0.0, -- data.trolleys[i].h + 180,
            debugPoly = false,
            minZ=data.doors.startloc.z - 0.2,
            maxZ=data.doors.startloc.z + 0.4
            }, { 
                options = {
                    {
                        event = "trolleymoney",
                        icon = "fas fa-box-circle-check",
                        label = "Collect Money",
                    },
                },
            distance = 10.0
        })
    end
end

RegisterCommand("Trolley", function() 
data = Config.Banks[1]
SpawnTrolleys()
end)

function resetBank()
    data = Location()
    for i = 1, 3 do
        trolley = GetClosestObjectOfType(data.trolleys[i].coords, 1.5, 769923921) -- ch_prop_cash_low_trolly_01c
        if trolley == 0 then
            trolley = GetClosestObjectOfType(data.trolleys[i].coords, 1.5, 269934519)
        end
        DeleteObject(trolley)
    end
 ResetDoor()
end

RegisterCommand("resetBank", function() 
    resetBank()
end)

RegisterNetEvent("sendPhases")
AddEventHandler("sendPhases", function(RecievedPhases)
    SavedPhases = RecievedPhases
end)

RegisterNetEvent("trolleymoney")
AddEventHandler("trolleymoney", function()
    Grab2clear = false
    Grab3clear = false
    grabber = true
    Trolley = nil
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local model = "hei_prop_heist_cash_pile"

    Trolley = GetClosestObjectOfType(pedCoords, 1.0, 412463629, false, false, false)
	local CashAppear = function()
	    local pedCoords = GetEntityCoords(ped)
        local grabmodel = GetHashKey(model)
        RequestModel(grabmodel)
        while not HasModelLoaded(grabmodel) do
            Citizen.Wait(100)
        end
	    local grabobj = CreateObject(grabmodel, pedCoords, true)

	    FreezeEntityPosition(grabobj, true)
	    SetEntityInvincible(grabobj, true)
	    SetEntityNoCollisionEntity(grabobj, ped)
	    SetEntityVisible(grabobj, false, false)
	    AttachEntityToEntity(grabobj, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
	    local startedGrabbing = GetGameTimer()

	    Citizen.CreateThread(function()
		    while GetGameTimer() - startedGrabbing < 37000 do
			    Citizen.Wait(1)
			    DisableControlAction(0, 73, true)
			    if HasAnimEventFired(ped, GetHashKey("CASH_APPEAR")) then
				    if not IsEntityVisible(grabobj) then
					    SetEntityVisible(grabobj, true, false)
				    end
			    end
			    if HasAnimEventFired(ped, GetHashKey("RELEASE_CASH_DESTROY")) then
				    if IsEntityVisible(grabobj) then
                        SetEntityVisible(grabobj, false, false)
                        TriggerServerEvent("addItem", "money_stack", 1)
				    end
			    end
		    end
		    DeleteObject(grabobj)
	    end)
    end
    local emptyobj = 769923921

	if IsEntityPlayingAnim(Trolley, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 3) then
		return
    end
    local baghash = GetHashKey("hei_p_m_bag_var22_arm_s")

    RequestAnimDict("anim@heists@ornate_bank@grab_cash")
    RequestModel(baghash)
    RequestModel(emptyobj)
    while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") and not HasModelLoaded(emptyobj) and not HasModelLoaded(baghash) do
        Citizen.Wait(100)
    end
    while not NetworkHasControlOfEntity(Trolley) do
		Citizen.Wait(1)
		NetworkRequestControlOfEntity(Trolley)
	end
	GrabBag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), GetEntityCoords(ped), true, false, false)
    Grab1 = NetworkCreateSynchronisedScene(GetEntityCoords(Trolley), GetEntityRotation(Trolley), 2, false, false, 1065353216, 0, 1.3)
	NetworkAddPedToSynchronisedScene(ped, Grab1, "anim@heists@ornate_bank@grab_cash", "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(GrabBag, Grab1, "anim@heists@ornate_bank@grab_cash", "bag_intro", 4.0, -8.0, 1)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
	NetworkStartSynchronisedScene(Grab1)
	Citizen.Wait(1500)
	CashAppear()
    if not Grab2clear then
        Grab2 = NetworkCreateSynchronisedScene(GetEntityCoords(Trolley), GetEntityRotation(Trolley), 2, false, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(ped, Grab2, "anim@heists@ornate_bank@grab_cash", "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(GrabBag, Grab2, "anim@heists@ornate_bank@grab_cash", "bag_grab", 4.0, -8.0, 1)
        NetworkAddEntityToSynchronisedScene(Trolley, Grab2, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 4.0, -8.0, 1)
        NetworkStartSynchronisedScene(Grab2)
        Citizen.Wait(37000)
    end
    if not Grab3clear then
        Grab3 = NetworkCreateSynchronisedScene(GetEntityCoords(Trolley), GetEntityRotation(Trolley), 2, false, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(ped, Grab3, "anim@heists@ornate_bank@grab_cash", "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(GrabBag, Grab3, "anim@heists@ornate_bank@grab_cash", "bag_exit", 4.0, -8.0, 1)
        NetworkStartSynchronisedScene(Grab3)
        NewTrolley = CreateObject(emptyobj, GetEntityCoords(Trolley) + vector3(0.0, 0.0, - 0.985), true, false, false)
        SetEntityRotation(NewTrolley, GetEntityRotation(Trolley))
        while not NetworkHasControlOfEntity(Trolley) do
            Citizen.Wait(1)
            NetworkRequestControlOfEntity(Trolley)
        end
        DeleteObject(Trolley)
        while DoesEntityExist(Trolley) do
            Citizen.Wait(1)
            DeleteObject(Trolley)
        end
        PlaceObjectOnGroundProperly(NewTrolley)
    end
	Citizen.Wait(1800)
	if DoesEntityExist(GrabBag) then
        DeleteEntity(GrabBag)
    end
    SetPedComponentVariation(ped, 5, 45, 0, 0)
	RemoveAnimDict("anim@heists@ornate_bank@grab_cash")
	SetModelAsNoLongerNeeded(emptyobj)
	SetModelAsNoLongerNeeded(GetHashKey("hei_p_m_bag_var22_arm_s"))
end)

--[[ RegisterNetEvent("trolleymoney")
AddEventHandler("trolleymoney", function()
    Grab2clear = false
    Grab3clear = false
    Trolley = nil
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local model = "hei_prop_heist_cash_pile"

    Trolley = GetClosestObjectOfType(pedCoords, 1.0, 412463629, false, false, false)
    currentgrab = Trolley
    RequestModel(GetHashKey(model))
    RequestModel(GetHashKey("hei_p_m_bag_var22_arm_s"))
    RequestAnimDict("anim@heists@ornate_bank@grab_cash")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") or not HasModelLoaded(GetHashKey(model)) do
        Citizen.Wait(1)
    end
    GrabBag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), pedCoords, false, false, false)
    FreezeEntityPosition(GrabBag, true)
    SetEntityInvincible(GrabBag, true)
    SetEntityNoCollisionEntity(GrabBag, ped)
    FreezeEntityPosition(GrabBag, true)

    Multiply = 1
    Sceneid = 0
    local started = true
    local breakall = false
    Triggerreset = false
    local phase = 0
    local grabreset = false
    Nores = false
    local firsttime1 = true
    local firsttime2 = true
    local startingphase = 0.1566388
    if SavedPhases[currentgrab] ~= nil then
        startingphase = SavedPhases[currentgrab]
    end
    local l, m, n = GetEntityRotation(Trolley)
    Grab2 = CreateSynchronizedScene(GetEntityCoords(Trolley), 0.0, 0.0, n, 2, 1065353216, 0, 1065353216)
    PlaySynchronizedEntityAnim(Trolley, Grab2, "cart_cash_dissapear", "anim@heists@ornate_bank@grab_cash", 1000.0, -4.0, 1)
    SetSynchronizedScenePhase(Grab2, startingphase)
    SetSynchronizedSceneRate(Grab2, 0.0)
    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        while true do
            if IsEntityPlayingAnim(ped, "anim@heists@ornate_bank@grab_cash", "grab", 3) then
                if HasAnimEventFired(ped, GetHashKey("CASH_APPEAR")) then
                    phase = GetSynchronizedScenePhase(Grab2) + 0.01007371
                    if not IsEntityVisible(CashProp) then
                        SetEntityVisible(CashProp, true, false)
                    end
                end
                if HasAnimEventFired(ped, GetHashKey("RELEASE_CASH_DESTROY")) then
                    if Multiply >= 0 then
                        Multiply = Multiply - 1
                    end
                    Triggerreset = true
                    if Triggerreset then
                        if Multiply == 0 then
                            DeleteEntity(CashProp)
                            SetEntityAsNoLongerNeeded(CashProp)
                            SetSynchronizedSceneRate(Grab2, 0.0)
                            Sceneid = 10
                            Triggerreset = false
                            Nores = false
                        elseif Multiply == 1 then
                            if IsEntityVisible(CashProp) then
                                SetEntityVisible(CashProp, false, false)
                            end
                            SetSynchronizedSceneRate(Grab2, 0.85)
                            Triggerreset = false
                            Sceneid = 10
                        elseif Multiply == 2 then
                            if IsEntityVisible(CashProp) then
                                SetEntityVisible(CashProp, false, false)
                            end
                            SetSynchronizedSceneRate(Grab2, 1.05)
                            Triggerreset = false
                            Sceneid = 10
                        elseif Multiply == 3 then
                            if IsEntityVisible(CashProp) then
                                SetEntityVisible(CashProp, false, false)
                            end
                            SetSynchronizedSceneRate(Grab2, 1.2)
                            Triggerreset = false
                            Sceneid = 10
                        elseif Multiply == 4 then
                            if IsEntityVisible(CashProp) then
                                SetEntityVisible(CashProp, false, false)
                            end
                            SetSynchronizedSceneRate(Grab2, 1.42)
                            Triggerreset = false
                            Sceneid = 10
                        end
                    end
                end
            end
            if breakall then
                break
            end
            Citizen.Wait(1)
        end
    end)
    Citizen.CreateThread(function()
        while true do
            if (Sceneid == 10) or (Sceneid == 20) then
                if IsControlJustPressed(2, 237) then
                    if not grabreset and not Nores then
                        grabreset = true
                    end
                    if Multiply == 0 then
                        SetSynchronizedSceneRate(Grab2, 0.85)
                        Multiply = Multiply + 1
                        Sceneid = 20
                    elseif Multiply == 1 then
                        SetSynchronizedSceneRate(Grab2, 1.05)
                        Multiply = Multiply + 1
                        Sceneid = 20
                    elseif Multiply == 2 then
                        SetSynchronizedSceneRate(Grab2, 1.20)
                        Multiply = Multiply + 1
                        Sceneid = 20
                    elseif Multiply == 3 then
                        SetSynchronizedSceneRate(Grab2, 1.42)
                        Multiply = Multiply + 1
                        Sceneid = 20
                    end
                end
            end
            if breakall then
                break
            end
            Citizen.Wait(1)
        end
    end)
    Citizen.CreateThread(function()
        while true do
            local ped = PlayerPedId()

            if (Sceneid == 10) or (Sceneid == 20) then
                DisplayText("HACK", "MC_GRAB_3_MK")
            end
            if started then
                if Sceneid == 0 then
                    if not IsSynchronizedSceneRunning(Grab1) then
                        local x, y, z = table.unpack(GetEntityCoords(Trolley))
                        local rotx, roty, rotz = table.unpack(GetEntityRotation(Trolley))

                        Grab1 = CreateSynchronizedScene(x, y, z, 0.0, 0.0, rotz, 2, true, false, 1065353216, 0, 1065353216)
                        if DoesEntityExist(GrabBag) then
                            PlaySynchronizedEntityAnim(GrabBag, Grab1, "bag_intro", "anim@heists@ornate_bank@grab_cash", 1.0, -1.0, 0, 0x447a0000)
                            ForceEntityAiAndAnimationUpdate(GrabBag)
                        end
                        TaskSynchronizedScene(ped, Grab1, "anim@heists@ornate_bank@grab_cash", "intro", 1.5, -1.0, 13, 16, 1.5, 0)
                        Grab2 = CreateSynchronizedScene(x, y, z, 0.0, 0.0, rotz, 2, true, false, 1065353216, 1.0, 0.0)
                    elseif IsSynchronizedSceneRunning(Grab1) then
                        if GetSynchronizedScenePhase(Grab1) >= 0.99 then
                            Sceneid = 10
                        end
                    end
                elseif Sceneid == 10 then
                    local x, y, z = table.unpack(GetEntityCoords(Trolley))
                    local rotx, roty, rotz = table.unpack(GetEntityRotation(Trolley))

                    if not IsSynchronizedSceneRunning(Grab1) then
                        if Multiply == 0 then
                            Grab2 = CreateSynchronizedScene(x, y, z, 0.0, 0.0, rotz, 2, true, false, 1065353216, 1.0, 0.0)
                            if DoesEntityExist(Trolley) then
                                PlaySynchronizedEntityAnim(Trolley, Grab2, "cart_cash_dissapear", "anim@heists@ornate_bank@grab_cash", 1000.0, -4.0, 1)
                                ForceEntityAiAndAnimationUpdate(Trolley)
                                SetSynchronizedScenePhase(Grab2, phase)
                                SetSynchronizedSceneRate(Grab2, 0.0)
                            end
                            Grab1 = CreateSynchronizedScene(x, y, z, 0.0, 0.0, rotz, 2, false, true, 1065353216, 0, 1065353216)
                            if DoesEntityExist(GrabBag) then
                                PlaySynchronizedEntityAnim(GrabBag, Grab1, "bag_grab_idle", "anim@heists@ornate_bank@grab_cash", 1000.0, 1.0, 0, 0x447a0000)
                                ForceEntityAiAndAnimationUpdate(GrabBag)
                            end
                            TaskSynchronizedScene(ped, Grab1, "anim@heists@ornate_bank@grab_cash", "grab_idle", 2.0, 1.0, 13, 16, 1148846080, 0)
                        end
                    end
                    if Multiply > 0 then
                        Sceneid = 20
                    elseif GetSynchronizedScenePhase(Grab2) >= 0.99 then
                        Sceneid = 30
                    else
                        if IsControlJustPressed(2, 238) then
                            Sceneid = 30
                        end
                    end
                elseif Sceneid == 20 then
                    local x, y, z = table.unpack(GetEntityCoords(Trolley))
                    local rotx, roty, rotz = table.unpack(GetEntityRotation(Trolley))

                    if grabreset then
                        Nores = true
                        Grab2 = CreateSynchronizedScene(x, y, z, 0.0, 0.0, rotz, 2, true, false, 1065353216, 1.0, 0.0)
                        SetSynchronizedSceneRate(Grab2, 0.89)
                        if DoesEntityExist(GrabBag) then
                            PlaySynchronizedEntityAnim(GrabBag, Grab2, "bag_grab", "anim@heists@ornate_bank@grab_cash", 1000.0, 1.0, 0, 0x447a0000)
                            if firsttime1 then
                                SetSynchronizedScenePhase(Grab1, startingphase)
                                phase = startingphase
                                firsttime1 = false
                            end
                            ForceEntityAiAndAnimationUpdate(GrabBag)
                        end
                        TaskSynchronizedScene(ped, Grab2, "anim@heists@ornate_bank@grab_cash", "grab", 4.0, 1.0, 13, 16, 1148846080, 0)
                        if DoesEntityExist(Trolley) then
                            SetSynchronizedScenePhase(Grab2, phase)
                            CashProp = CreateObject(GetHashKey(model), GetEntityCoords(ped), false, false)
                            FreezeEntityPosition(CashProp, true)
                            SetEntityInvincible(CashProp, true)
                            SetEntityNoCollisionEntity(CashProp, ped)
                            SetEntityVisible(CashProp, false, false)
                            AttachEntityToEntity(CashProp, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                            PlaySynchronizedEntityAnim(Trolley, Grab2, "cart_cash_dissapear", "anim@heists@ornate_bank@grab_cash", 1000.0, -4.0, 1)
                            if firsttime2 then
                                SetSynchronizedScenePhase(Grab1, startingphase)
                                firsttime2 = false
                            end
                            ForceEntityAiAndAnimationUpdate(Trolley)
                            grabreset = false
                        end
                    end
                elseif Sceneid == 30 then
                    local x, y, z = table.unpack(GetEntityCoords(Trolley))
                    local rotx, roty, rotz = table.unpack(GetEntityRotation(Trolley))

                    Grab2 = CreateSynchronizedScene(x, y, z, 0.0, 0.0, rotz, 2, true, false, 1065353216, 1.0, 0.0)
                    PlaySynchronizedEntityAnim(GrabBag, Grab2, "bag_exit", "anim@heists@ornate_bank@grab_cash", 1000.0, -1000.0, 0, 0x447a0000)
                    ForceEntityAiAndAnimationUpdate(GrabBag)
                    TaskSynchronizedScene(ped, Grab2, "anim@heists@ornate_bank@grab_cash", "exit", 4.0, -4.0, 13, 16, 1148846080, 0)
                    Grab1 = CreateSynchronizedScene(x, y, z, 0.0, 0.0, rotz, 2, false, true, 1065353216, 0, 1065353216)
                    PlaySynchronizedEntityAnim(Trolley, Grab1, "cart_cash_dissapear", "anim@heists@ornate_bank@grab_cash", 1000.0, -4.0, 1)
                    SetSynchronizedScenePhase(Grab1, phase)
                    SetSynchronizedSceneRate(Grab1, 0.0)
                    SavedPhases[currentgrab] = phase
                    TriggerServerEvent("savePhases", SavedPhases)
                    Sceneid = 40
                elseif Sceneid == 40 then
                    print("Scene 40")
                    if GetSynchronizedScenePhase(Grab2) >= 0.99 then
                        print("Scene 40 Pass")
                        DeleteEntity(GrabBag)
                        SetEntityAsNoLongerNeeded(GrabBag)
                        ClearPedTasks(ped)
                        StopSynchronizedEntityAnim(Trolley, Grab1)
                        DisposeSynchronizedScene(Grab1)
                        DisposeSynchronizedScene(Grab2)
                        if phase >= 0.99 then
                            exports['qtarget']:RemoveZone("Trolley-"..Trolley)
                            emptyobj =769923921
                            RequestModel(emptyobj)
                            while not HasModelLoaded(emptyobj) do
                                Citizen.Wait(100)
                            end
                            NewTrolley = CreateObject(emptyobj, GetEntityCoords(Trolley) + vector3(0.0, 0.0, - 0.985), true, false, false)
                            SetEntityRotation(NewTrolley, GetEntityRotation(Trolley))
                            while not NetworkHasControlOfEntity(Trolley) do
                                Citizen.Wait(1)
                                NetworkRequestControlOfEntity(Trolley)
                            end
                            DeleteObject(Trolley)
                            while DoesEntityExist(Trolley) do
                                Citizen.Wait(1)
                                DeleteObject(Trolley)
                            end
                            PlaceObjectOnGroundProperly(NewTrolley)
                        end
                        grabreset = false
                        Multiply = 0
                        Nores = false
                        phase = 0
                        firsttime1 = true
                        firsttime2 = false
                        Sceneid = -1
                        started = false
                        Triggerreset = false
                    end
                end
            end
            if breakall then
                break
            end
            Citizen.Wait(1)
        end
    end)
end) ]]

RegisterNetEvent("blowdoor")
AddEventHandler("blowdoor", function()
    exports['qtarget']:RemoveZone("PlantThermite")
    data = Location()
    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end
    local ped = PlayerPedId()

    SetEntityHeading(ped, data.doors.secondloc.h)
    Citizen.Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(ped)))
    local bagscene = NetworkCreateSynchronisedScene(data.prop.second.coords, rotx, roty, rotz, 2, false, false, 1065353216, 0, 1.3) --148.9, -1047.1, 29.7
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), 148.9, -1047.1, 29.7,  true,  true, false)

    SetEntityCollision(bag, false, true)
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    NetworkStartSynchronisedScene(bagscene)
    Citizen.Wait(1500)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local bomba = CreateObject(GetHashKey("hei_prop_heist_thermite"), x, y, z + 0.2,  true,  true, true)

    SetEntityCollision(bomba, false, true)
    AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    Citizen.Wait(4000)
    DeleteObject(bag)
    SetPedComponentVariation(ped, 5, 45, 0, 0)
    DetachEntity(bomba, 1, 1)
    FreezeEntityPosition(bomba, true)
    SetPtfxAssetNextCall("scr_ornate_heist")
    local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", data.prop.second.particles, 0.0, 0.0, 0.0, 1.0, false, false, false, false)

    NetworkStopSynchronisedScene(bagscene)
    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)
    Citizen.Wait(2000)
    ClearPedTasks(ped)
    Citizen.Wait(2000)
    DeleteObject(bomba)
    Citizen.Wait(9000)
    StopParticleFxLooped(effect, 0)
    local gate = GetClosestObjectOfType(data.doors.secondloc.x, data.doors.secondloc.y, data.doors.secondloc.z, 3.0, Config.door)
    FreezeEntityPosition(gate, false)
end)

function DisplayText(gxt, msg)
    RequestAdditionalText(gxt, 3)
    while not HasAdditionalTextLoaded(3) do
        Citizen.Wait(1)
    end
    DisplayHelpTextThisFrame(msg, 1)
end
           
for k, v in pairs(Config.Banks) do
    data = Config.Banks[k]
    exports['qtarget']:AddBoxZone("RobBank"..k, vector3(data.prop.first.coords), 0.4, 0.6, { -- 147.32, -1046.3, 29.37
    name="RobBank"..k,
    heading=data.doors.startloc.h,
    debugPoly=true,
    minZ=data.doors.startloc.z - 0.1,
    maxZ=data.doors.startloc.z + 0.5
    }, {
        options = {
            {
                event = "startRobbery",
                icon = "far fa-clipboard",
                label = "Start Robbery",
            },
        },
        distance = 10
    })
end