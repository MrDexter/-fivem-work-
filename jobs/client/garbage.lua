ESX = nil
local esxloaded, currentstop = false, 0
local clockedin, vehiclespawned, albetogetbags = false, false, false
local work_truck, NewDrop, LastDrop, binpos, truckpos, garbagebag, truckplate, mainblip, currentstop
local Blips, CollectionJobs, CollectionBins, binlist = {}, {}, {}, {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	PlayerData = ESX.GetPlayerData()
		
	if PlayerData.job.name == Config.JobName then
		mainblip = AddBlipForCoord(Config.Zones[2].pos)

		SetBlipSprite (mainblip, 318)
		SetBlipDisplay(mainblip, 4)
		SetBlipScale  (mainblip, 1.2)
		SetBlipColour (mainblip, 5)
		SetBlipAsShortRange(mainblip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Garbage Man")
		EndTextCommandSetBlipName(mainblip)
	end
		
	esxloaded = true
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	TriggerServerEvent('esx_garbagecrew:setconfig')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	TriggerEvent('esx_garbagecrew:checkjob')
end)

RegisterNetEvent('esx_garbagecrew:movetruckcount')
AddEventHandler('esx_garbagecrew:movetruckcount', function(count)
	Config.TruckPlateNumb = count
end)

RegisterNetEvent('esx_garbagecrew:updatejobs')
AddEventHandler('esx_garbagecrew:updatejobs', function(newjobtable, newbintable)
	CollectionJobs = newjobtable
	CollectionBins = newbintable
end)


RegisterNetEvent('esx_garbagecrew:selectnextjob')
AddEventHandler('esx_garbagecrew:selectnextjob', function()
	if currentstop < Config.MaxStops then
		RemoveBlip(radius)
		SetVehicleDoorShut(work_truck, 5, false)
		FindDeliveryLoc()
		albetogetbags = false
	else
		NewDrop = nil
		oncollection = false
		SetVehicleDoorShut(work_truck, 5, false)
		RemoveBlip(radius)
		SetBlipRoute(Blips['endmission'], true)
		albetogetbags = false
		ESX.ShowNotification("Return to the depot")
		TriggerServerEvent("esx_garbagecrew:resetbins", binlist)
		binlist = {}
	end
end)

AddEventHandler('esx_garbagecrew:checkjob', function()
	if PlayerData.job.name ~= Config.JobName then
		if mainblip ~= nil then
			RemoveBlip(mainblip)
			mainblip = nil
		end
	elseif mainblip == nil then
		mainblip = AddBlipForCoord(Config.Zones[2].pos)

		SetBlipSprite (mainblip, 318)
		SetBlipDisplay(mainblip, 4)
		SetBlipScale  (mainblip, 1.2)
		SetBlipColour (mainblip, 5)
		SetBlipAsShortRange(mainblip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Garbage Collection")
		EndTextCommandSetBlipName(mainblip)
	end
end)

function CollectBagFromBin(thiszone, binpos)

	if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
		RequestAnimDict("anim@heists@narcotics@trash") 
		while not HasAnimDictLoaded("anim@heists@narcotics@trash") do 
			Citizen.Wait(0)
		end
	end

	if DoesEntityExist(work_truck) and GetDistanceBetweenCoords(GetEntityCoords(work_truck), GetEntityCoords(GetPlayerPed(-1)), true) < 25.0 then
		truckpos = GetOffsetFromEntityInWorldCoords(work_truck, 0.0, -5.25, 0.0)
		TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
		TriggerServerEvent('esx_garbagecrew:bagremoval', thiszone.pos, binpos) 
		trashcollection = false
		Citizen.Wait(1000)
		ClearPedTasks(PlayerPedId())
		local randombag = math.random(0,2)

		if randombag == 0 then
			garbagebag = CreateObject(GetHashKey("prop_cs_street_binbag_01"), 0, 0, 0, true, true, true) -- creates object
			AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true) -- object is attached to right hand    
			--AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 18905), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true) -- object is attached to left hand, progression?
		elseif randombag == 1 then
			garbagebag = CreateObject(GetHashKey("bkr_prop_fakeid_binbag_01"), 0, 0, 0, true, true, true) -- creates object
			AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), .65, 0, -.1, 0, 270.0, 60.0, true, true, false, true, 1, true) -- object is attached to right hand   
			--AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 18905), .65, 0, -.1, 0, 270.0, 60.0, true, true, false, true, 1, true) -- object is attached to left hand    
		elseif randombag == 2 then
			garbagebag = CreateObject(GetHashKey("hei_prop_heist_binbag"), 0, 0, 0, true, true, true) -- creates object
			AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true) -- object is attached to right hand 
			--AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 18905), 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true) -- object is attached to left hand    
		end  

		TaskPlayAnim(PlayerPedId(), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0,-1,49,0,0, 0,0)
		Citizen.Wait(500)
		ClearPedTasks(PlayerPedId())
		if CollectionBins[bin] > 0 then
			ESX.ShowNotification(string.format("%s Bags Remaining", tostring(CollectionBins[bin])))	
		else
			ESX.ShowNotification(string.format("%s/15 Bins Emptied", tostring(CollectionJobs[thiszone.pos].binsremaining)))
		end
	else
		ESX.ShowNotification("No garbage truck nearby")
		TriggerServerEvent('esx_garbagecrew:unknownlocation', thiszone.pos)
	end
end

function PlaceBagInTruck(thiszone)
	if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
		RequestAnimDict("anim@heists@narcotics@trash") 
		while not HasAnimDictLoaded("anim@heists@narcotics@trash") do 
			Citizen.Wait(0)
		end
	end
	ClearPedTasksImmediately(GetPlayerPed(-1))
	TaskPlayAnim(PlayerPedId(), 'anim@heists@narcotics@trash', 'throw_b', 1.0, -1.0,-1,2,0,0, 0,0)
	Citizen.Wait(800)
	local garbagebagdelete = DeleteEntity(garbagebag)
	garbagebag = nil
	Citizen.Wait(100)
	ClearPedTasksImmediately(GetPlayerPed(-1))
	truckpos = nil
	TriggerServerEvent('esx_garbagecrew:bagdumped', thiszone.pos, truckplate)
end

function SelectBinAndCrew(location)
		truckplate = GetVehicleNumberPlateText(work_truck)
		truckid = NetworkGetNetworkIdFromEntity(work_truck)
	 	TriggerServerEvent('esx_garbagecrew:setworkers', location, truckplate, truckid )
end

function FindDeliveryLoc()
	randomloc = math.random(1,Config.Count)
	local count = 0
	if NewDrop ~= nil then
		while randomloc == lastrandloc and count < 10 do
			randomloc = math.random(1,Config.Count)
			count = count + 1
		end
	end
	currentstop = currentstop + 1
	lastrandloc = randomloc
	NewDrop = Config.Locations[randomloc]
	if NewDrop == LastDrop then end
	LastDrop = NewDrop
	
	if Blips['endmission'] ~= nil then
		RemoveBlip(Blips['endmission'])
		Blips['endmission'] = nil
	end
	radius = AddBlipForRadius(NewDrop.pos, NewDrop.size)
	SetBlipAlpha(radius, 60)
	SetBlipColour(radius, 5)
	
	Blips['endmission'] = AddBlipForCoord(Config.Zones[1].pos)
	SetBlipSprite (Blips['endmission'], 318)
	SetBlipColour(Blips['endmission'], 1)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Return Point")
	EndTextCommandSetBlipName(Blips['endmission'])

	oncollection = true
	SelectBinAndCrew(NewDrop.pos)
	ESX.ShowNotification(NewDrop.name .. " Is your dedicated zone")
end

function startJob()
		currentstop = 0
		FindDeliveryLoc()
end

RegisterCommand("clockin", function(source)
	clockedin = true
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
		if skin.sex == 0 then
			TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
		else
			TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
		end
	end)
end, false)
RegisterCommand("clockout", function(source)
	clockedin = true
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
		if skin.sex == 0 then
			TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
		else
			TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
		end
	end)
end, false)
RegisterCommand("endjob", function(source)
	if IsPedInAnyVehicle(GetPlayerPed(-1)) then
		local getvehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		TaskLeaveVehicle(GetPlayerPed(-1), getvehicle, 0)
	end
	while IsPedInAnyVehicle(GetPlayerPed(-1)) do
		Citizen.Wait(0)
	end
	Citizen.InvokeNative( 0xAE3CBE5BF394C9C9, Citizen.PointerValueIntInitialized( work_truck ) )
	RemoveBlip(radius)
	if Blips['endmission'] ~= nil then
		RemoveBlip(Blips['endmission'])
		Blips['endmission'] = nil
	end
	SetBlipRoute(Blips['endmission'], false)
	vehiclespawned = false
	albetogetbags = false
end, false)

RegisterCommand("gt", function(source)
	ESX.Game.SpawnVehicle(Config.Trucks[1], GetEntityCoords(GetPlayerPed(-1)), 270.0, function(vehicle)
		local trucknumber = Config.TruckPlateNumb + 1
		if trucknumber <=9 then
			SetVehicleNumberPlateText(vehicle, 'GCREW00'..trucknumber)
			worktruckplate =   'GCREW00'..trucknumber 
		elseif trucknumber <=99 then
			SetVehicleNumberPlateText(vehicle, 'GCREW0'..trucknumber)
			worktruckplate =   'GCREW0'..trucknumber 
		else
			SetVehicleNumberPlateText(vehicle, 'GCREW'..trucknumber)
			worktruckplate =   'GCREW'..trucknumber 
		end
		TriggerServerEvent('esx_garbagecrew:movetruckcount')   
		SetEntityAsMissionEntity(vehicle,true, true)
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)  
		vehiclespawned = true 
		albetogetbags = false
		work_truck = vehicle
	end)
end, false)

RegisterCommand("dr", function(source)
	zone = Config.Locations[randomloc]
	ply = GetPlayerPed(-1)
	plyloc = GetEntityCoords(ply)
	if GetDistanceBetweenCoords(plyloc, truckpos, true) < 10.0  then
		sleep = 0
		PlaceBagInTruck(zone)
	end
end, false)

RegisterCommand("sj", function(source)
	-- if IsPedInAnyVehicle(GetPlayerPed(-1)) and GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false)) == worktruckplate then
	-- 	ESX.ShowNotification("Please ensure all crew members are in the truck in the next 10 seconds.")
	-- 	Citizen.Wait(10000)
		startJob()
	-- else
	-- 	ESX.ShowNotification("Get in the truck first.")
	-- end
end, false)

function findingbins(zone)
	ply = GetPlayerPed(-1)
	plyloc = GetEntityCoords(ply)
	if GetDistanceBetweenCoords(zone.pos, plyloc, true) < zone.size then
		for i, v in pairs(Config.DumpstersAvaialbe) do
			bin = GetClosestObjectOfType(plyloc, 5.0, v, false, false, false )
			if bin ~= 0 and (CollectionBins[bin] == nil or CollectionBins[bin] > 0) then break end
		end
		if  bin ~= 0 then
			if CollectionBins[bin] == nil or CollectionBins[bin]> 0 then
				binpos = GetEntityCoords(bin)
				table.insert(binlist, bin)
				CollectBagFromBin(zone, bin)
			else
				ESX.ShowNotification("Bin Empty")
			end
		else
			ESX.ShowNotification("No bin nearby or bin empty")
		end
	else
		ESX.ShowNotification("You are not in your dedicated zone")
	end	
end

RegisterCommand("cr", function(source)
	zone = Config.Locations[randomloc]
	if garbagebag == nil then
		findingbins(zone)
	else
		ESX.ShowNotification("You already have a bag")
	end
end, false)