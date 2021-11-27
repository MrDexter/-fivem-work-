local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function Draw3DText(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local p = GetGameplayCamCoords()
	local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
	local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	local scale = scale * fov
	if onScreen then
		SetTextScale(0.0, 0.35)
		SetTextFont(0)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end

function Notifacation(text)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandThefeedPostTicker(false, true)
end

function BodyWork()
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)

	--local location = {[0] = "door_dside_f", [1] = "door_pside_f", [2] = "door_dside_r", [3] = "door_pside_r", [4] = "bonnet", [5] = "boot"}
	--exports['progressBars']:startUI(1000, "Removing " .. location[num])
	--Wait(1000)
	local doorstate = {
		{"door_dside_f", 0, true},
		{"door_pside_f", 1, true},
		{"door_dside_r", 2, true},
		{"door_pside_r", 3, true},
		{"bonnet", 4, true},
		{"boot", 5, true},
	}
	print("Before: ",doorstate[3][3])
	doorstates = {}
	for k, door in pairs(doorstate) do
		local state = IsVehicleDoorDamaged(vehicle, door[2])
		print("K", k-1)
		print("Door ",door[2])
		print("state ",state)
		j = k -1
		print("Table", doorstate[j][3])
		
		--table.insert(doorstates, state)
	end
	
	--SetVehicleDoorBroken(vehicle, num, 1)
	
end 

RegisterNetEvent('RepairVehicle')
AddEventHandler('RepairVehicle', function()
		local ped = PlayerPedId()
		local plyCoords = GetEntityCoords(ped, false)
		local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71)
		SetVehicleEngineHealth(vehicle, 100)
		SetVehicleBodyHealth(vehicle, 100)
		SetVehicleFixed(vehicle)
		--ShowNotification("Vehicle Fixed")
end)

 RegisterCommand("repair", function(source)
	TriggerEvent('RepairVehicle')
end, false)

RegisterCommand("bumpers", function(source)
	bumpers()
end, false)

function bumpers(mod)
	print("Going now")
	local bumpers = {}
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local veh = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71)
	for i = 0,   tonumber(GetNumVehicleMods(veh,mod)) - 1 do
		local lbl = GetModTextLabel(veh,mod,i)
		if lbl ~= nil then
			local mname = GetLabelText(lbl)
 			if mname == "NULL" then
				mname = "Custom Part"
			end
		table.insert(bumpers, mname)
		end
	end	
	return bumpers
end

local doors = {
	{"door_dside_f", 0},
	{"door_pside_f", 1},
	{"door_dside_r", 2},
	{"door_pside_r", 3},
	{"bonnet", 4},
	{"boot", 5},
}

--[[ function VehicleInFront(ped)

    local pos = GetEntityCoords(ped)
    local entityWorld = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, ped, 0)
    local _, _, _, _, result = GetRaycastResult(rayHandle)
	
    return result
end ]]

Citizen.CreateThread(function() -- Open bonnet
	while true do
    	Citizen.Wait(0)
			
		local ped = PlayerPedId()
		local plyCoords = GetEntityCoords(ped, false)
   		if IsControlJustReleased(0, 38) and running ~= true and GetVehiclePedIsIn(ped, false) == 0 and not (GetSelectedPedWeapon(ped) == 419712736) then
      		local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71)
			local vehpos = GetEntityCoords(vehicle)
				
      		running = true -- stops spamming open close
				
      		if vehicle ~= nil then
				local plyCoords = GetEntityCoords(ped, false)
        		local doorDistances = {}
					
        		for k, door in pairs(doors) do
          			local doorBone = GetEntityBoneIndexByName(vehicle, door[1])
          			local doorPos = GetWorldPositionOfEntityBone(vehicle, doorBone)
          			local distance = GetDistanceBetweenCoords(plyCoords.x, plyCoords.y, plyCoords.z, doorPos.x, doorPos.y, doorPos.z)
						
          			table.insert(doorDistances, distance)
        		end
					
        		local key, min = 1, doorDistances[1]
					
        		for k, v in ipairs(doorDistances) do
          			if doorDistances[k] < min then
           				key, min = k, v
          			end
				end
				if 	GetVehicleDoorAngleRatio(vehicle, doors[key][2]) > 0.0 and GetVehicleDoorAngleRatio(vehicle, doors[key][2]) < 0.75 then 
					SetVehicleDoorOpen(vehicle, doors[key][2], 0,0)
				else
					SetVehicleDoorShut(vehicle, doors[key][2], 0,0)
				end
     		end
				
      		running = false
    	end
  	end
end)

--[[ Citizen.CreateThread(function() -- Idea for vehicle lifts?
	while true do
    	Citizen.Wait(0)
			
		local ped = PlayerPedId()
		local plyCoords = GetEntityCoords(ped, false)
      	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71)
		local vehpos = GetEntityCoords(vehicle)
   		if IsControlJustReleased(0, 172) and GetVehiclePedIsIn(ped, false) == 0 then	
			FreezeEntityPosition(vehicle, true)	
			SetEntityCoordsNoOffset(vehicle, vehpos.x, vehpos.y, vehpos.z + 0.1, true, true, true)
		end
		
		if IsControlJustReleased(0, 173) and GetVehiclePedIsIn(ped, false) == 0 then			  
		  SetEntityCoordsNoOffset(vehicle, vehpos.x, vehpos.y, vehpos.z - 0.1, true, true, true)
		end
		if IsControlJustReleased(0, 174) and GetVehiclePedIsIn(ped, false) == 0 then			  
			FreezeEntityPosition(vehicle, false)	
		end
	end
end) ]]



--[[ -- Get into passenger seat with empty car
Citizen.CreateThread(function()
	while true do
    	Citizen.Wait(0)
			
		local ped = PlayerPedId()
			
   		if IsControlJustReleased(0, 23) and running ~= true and GetVehiclePedIsIn(ped, false) == 0 then
      		local vehicle = VehicleInFront(ped)
				
      		running = true
				
      		if vehicle ~= nil then
				local plyCoords = GetEntityCoords(ped, false)
        		local doorDistances = {}
					
        		for k, door in pairs(doors) do
          			local doorBone = GetEntityBoneIndexByName(vehicle, door[1])
          			local doorPos = GetWorldPositionOfEntityBone(vehicle, doorBone)
          			local distance = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, doorPos.x, doorPos.y, doorPos.z)
						
          			table.insert(doorDistances, distance)
        		end
					
        		local key, min = 1, doorDistances[1]
					
        		for k, v in ipairs(doorDistances) do
          			if doorDistances[k] < min then
           				key, min = k, v
          			end
				end
				print(doors[key][2])
				SetVehicleDoorBroken(vehicle, doors[key][2])
        		TaskEnterVehicle(ped, vehicle, -1, doors[key][2], 1.5, 1, 0)
     		end
				
      		running = false
    	end
  	end
end) ]]

RegisterCommand("lights", function(source, args)
	tunerlights(args[1], args[2])
end, false)

function tunerlights(type, color)
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71)
	Colors = {
		["0"] = 0,
		["1"] = 1,
		["2"] = 2,
		["3"] = 3,
		["4"] = 4,
		["5"] = 5,
		["6"] = 6,
		["7"] = 7,
		["8"] = 8,
		["9"] = 9,
		["10"] = 10,
		["11"] = 11,
		["12"] = 12,
	}
	if type == "Stock" then
		ToggleVehicleMod(vehicle, 22, 0)
		SetVehicleHeadlightsColour(vehicle, -1)
	elseif type == "Xenon" then
		ToggleVehicleMod(vehicle, 22, 1)
		SetVehicleHeadlightsColour(vehicle, -1)
	elseif type == "Color" then
		ToggleVehicleMod(vehicle, 22, 1)
		SetVehicleHeadlightsColour(vehicle, Colors[color])
	end
end

function tunerperformance(mod, stage)
	local doorDistances = {}
	local modname = {
		["11"] = {11, "Engine"},
		["12"] = {12, "Brakes"},
		["13"] = {13, "Transmission"},
		["15"] = {15, "Suspension"},
		["18"] = {18, "Turbo"}
	}
	local modid = {
		["-1"] = {-1, ""},
		["0"] = {0, "Removing", false},
		["1"] = {1, "Installing", true},
		["2"] = {2, ""},
		["3"] = {3, ""}
	}
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71) --VehicleInFront(ped)
	local notCar = IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelAQuadbike(GetEntityModel(vehicle))
		for k, vehdoor in pairs(doors) do
			local doorBone = GetEntityBoneIndexByName(vehicle, vehdoor[1])
			local doorPos = GetWorldPositionOfEntityBone(vehicle, doorBone)
			local distance = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, doorPos.x, doorPos.y, doorPos.z)
			
			table.insert(doorDistances, distance)
		end
		local key, min = 1, doorDistances[1]
			
		for k, v in ipairs(doorDistances) do
				if doorDistances[k] < min then
					key, min = k, v
				end
		end 
		print(notCar)
	if (doors[key][2] == 4 and GetVehicleDoorAngleRatio(vehicle, 4) > 0.75) or notCar then
		if modname[mod][2] == "Turbo" then
			ESX.TriggerServerCallback('tuner:itemamount', function(amount)
				if not (IsToggleModOn(vehicle, 18)) == modid[stage][3] and amount >= modid[stage][1] then
					TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
					Wait(1000)
					exports["progressBars"]:startUI(5000, "Preparing...")
					Wait(5000)
					local finished = exports["skillbar"]:taskBar(5000,math.random(1,5))
					if finished ~= 100 then
						local finishedchance = exports["skillbar"]:taskBar(2500,math.random(3,5))
						if finishedchance ~= 100 then
							Notifacation("Process Failed")
							ClearPedTasks(ped)
							return
						else
							exports["progressBars"]:startUI(5000, "Getting back on Track")
							Wait(5000)
						end
					end
					Wait(1000)
					exports["progressBars"]:startUI(5000, modid[stage][2] .. " Turbo")
					Wait(5000)
					local finished2 = exports["skillbar"]:taskBar(5000,math.random(1,5))
					if finished2 ~= 100 then
						local finished2chance = exports["skillbar"]:taskBar(2500,math.random(3,6))
						if finishedchance ~= 100 then
							Notifacation("Process Failed")
							ClearPedTasks(ped)
							return
						else
							exports["progressBars"]:startUI(5000, "Getting back on Track")
							Wait(5000)
						end
					end
					Wait(1000)
					exports["progressBars"]:startUI(5000, "Completing Process")
					Wait(5000)
					ToggleVehicleMod(vehicle, modname[mod][1], modid[stage][1])
					if modid[stage][1] == 1 then
						TriggerServerEvent('tuner:removeitem', 'turbo', 1)
					elseif modid[stage][1] == 0 then
						TriggerServerEvent('tuner:additem', 'turbo', 1)
					end
					ClearPedTasks(ped)
				elseif amount < modid[stage][1] then
					Notifacation("You don't have a Turbo")
				elseif IsToggleModOn(vehicle, 18) == false and modid[stage][3] == false then
					Notifacation("Vehicle Doesn't have a Turbo")
				else
					Notifacation("Vehicle already has a Turbo")
				end
			end, "turbo")
		else
			ESX.TriggerServerCallback('tuner:itemamount', function(amount)
				if not (GetVehicleMod(vehicle, modname[mod][1]) == modid[stage][1]) and amount > 0 then
					TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
					Wait(1000)
					exports["progressBars"]:startUI(5000, "Preparing")
					Wait(5000)
					local finished = exports["skillbar"]:taskBar(5000,math.random(1,5))
					if finished ~= 100 then
						local finishedchance = exports["skillbar"]:taskBar(2500,math.random(3,5))
						if finishedchance ~= 100 then
							Notifacation("Process Failed")
							ClearPedTasks(ped)
							return
						else
							exports["progressBars"]:startUI(5000, "Getting back on Track")
							Wait(5000)
						end
					end
					Wait(1000)
					exports["progressBars"]:startUI(5000, "Installing Stage " .. modid[stage][1] + 1 .. " " .. modname[mod][2])
					Wait(5000)
					local finished2 = exports["skillbar"]:taskBar(5000,math.random(1,5))
					if finished2 ~= 100 then
						local finished2chance = exports["skillbar"]:taskBar(2500,math.random(3,6))
						if finishedchance ~= 100 then
							Notifacation("Process Failed")
							ClearPedTasks(ped)
							return
						else
							exports["progressBars"]:startUI(5000, "Getting back on Track")
							Wait(5000)
						end
					end
					Wait(1000)
					exports["progressBars"]:startUI(5000, "Completing Change")
					Wait(5000)
					SetVehicleMod(vehicle, modname[mod][1], modid[stage][1], false)
					ClearPedTasks(ped)
				else
					Notifacation("Vehicle already at "..modname[mod][2] .. " Stage: " .. modid[stage][1] + 1 )
				end
			end, "tuning_laptop")
		end
	elseif not notCar and GetVehicleDoorAngleRatio(vehicle, 4) < 0.75 then
		Notifacation("Hood not open")
	elseif not notCar and doors[key][2] ~= 4 then
		Notifacation("You need to be at the Hood")
	else
		Notifacation("You appear to have found an issue :/")
	end
end

function tunerservice()
	local doorDistances = {}
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71) --VehicleInFront(ped)
	local notCar = IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelAQuadbike(GetEntityModel(vehicle))
	ESX.TriggerServerCallback('tuner:itemamount', function(amount)
			for k, vehdoor in pairs(doors) do
				local doorBone = GetEntityBoneIndexByName(vehicle, vehdoor[1])
				local doorPos = GetWorldPositionOfEntityBone(vehicle, doorBone)
				local distance = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, doorPos.x, doorPos.y, doorPos.z)
				
				table.insert(doorDistances, distance)
			end
			local key, min = 1, doorDistances[1]
				
			for k, v in ipairs(doorDistances) do
					if doorDistances[k] < min then
						key, min = k, v
					end
			end -- Bikes need servicing too
		if doors[key][2] == 4 and GetVehicleDoorAngleRatio(vehicle, 4) > 0.75 and GetVehicleEngineHealth(vehicle) < 1000.0 and amount > 0 or notCar and GetVehicleEngineHealth(vehicle) < 1000.0 then
			TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
			Wait(1000)
			exports["progressBars"]:startUI(5000, "Preparing for Service")
			Wait(5000)
			local finished = exports["skillbar"]:taskBar(5000,math.random(1,5))
			if finished ~= 100 then
				local finishedchance = exports["skillbar"]:taskBar(2500,math.random(3,5))
				if finishedchance ~= 100 then
					Notifacation("Service Failed")
					ClearPedTasks(ped)
					return
				else
					exports["progressBars"]:startUI(5000, "Getting back on Track")
					Wait(5000)
				end
			end
			Wait(1000)
			exports["progressBars"]:startUI(5000, "Servicing Engine")
			Wait(5000)
			local finished2 = exports["skillbar"]:taskBar(5000,math.random(1,5))
			if finished2 ~= 100 then
				local finished2chance = exports["skillbar"]:taskBar(2500,math.random(3,6))
				if finishedchance ~= 100 then
					Notifacation("Service Failed")
					ClearPedTasks(ped)
					return
				else
					exports["progressBars"]:startUI(5000, "Getting back on Track")
					Wait(5000)
				end
			end
			Wait(1000)
			exports["progressBars"]:startUI(5000, "Finishing Service")
			Wait(5000)
			SetVehicleEngineHealth(vehicle, 1000.0)
			SetVehicleOilLevel(vehicle, 1000.0)
			TriggerServerEvent('tuner:removeitem', 'servicekit', 1)
			Notifacation("Service Complete")
			ClearPedTasks(ped)
		elseif GetVehicleEngineHealth(vehicle) == 1000.0 then
			Notifacation("Engine already in good Condition")
		elseif not notCar and GetVehicleDoorAngleRatio(vehicle, 4) < 0.75 then
			Notifacation("Hood not Open")
		elseif amount == 0 then
			Notifacation("You don't have an Engine Service Kit")
		else
			Notifacation("You appear to have found an issue :/")
		end	
	end, "servicekit")
end

local wheels = {
	{"wheel_lf", 0}, 
	{"wheel_rf", 1}, 
	{"wheel_lm1", 2}, 
	{"wheel_rm1", 3}, 
	{"wheel_lm2", 45},
	{"wheel_rm2", 47}, 
	{"wheel_lm3", 46}, 
	{"wheel_rm3", 48}, 
	{"wheel_lr", 4}, 
	{"wheel_rr", 5},
}

function tirereplacement()
	local wheelDistances = {}
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71) --VehicleInFront(ped)
	ESX.TriggerServerCallback('tuner:itemamount', function(amount)
		for k, vehwheel in pairs(wheels) do
			local wheelBone = GetEntityBoneIndexByName(vehicle, vehwheel[1])
			local wheelPos = GetWorldPositionOfEntityBone(vehicle, wheelBone)
			local distance = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, wheelPos.x, wheelPos.y, wheelPos.z)
			
			table.insert(wheelDistances, distance)
		end
		local key, min = 1, wheelDistances[1]
			
		for k, v in ipairs(wheelDistances) do
				if wheelDistances[k] < min then
					key, min = k, v
				end
		end 
		if IsVehicleTyreBurst(vehicle, wheels[key][2], false) and amount > 0 then
			TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)
			Wait(1000)
			exports["progressBars"]:startUI(5000, "Removing Tire...")
			Wait(5000)
			local finished = exports["skillbar"]:taskBar(5000,math.random(1,5))
			if finished ~= 100 then
				local finishedchance = exports["skillbar"]:taskBar(2500,math.random(3,8))
				if finishedchance ~= 100 then
					Notifacation("Attempt Failed")
					ClearPedTasks(ped)
					return
				else
					exports["progressBars"]:startUI(5000, "Getting back on Track")
					Wait(5000)
				end
			end
			Wait(1000)
			exports["progressBars"]:startUI(5000, "Installing new tire...")
			Wait(5000)
			local finished2 = exports["skillbar"]:taskBar(5000,math.random(1,5))
			if finished2 ~= 100 then
				local finished2chance = exports["skillbar"]:taskBar(2500,math.random(3,8))
				if finishedchance ~= 100 then
					Notifacation("Attempt Failed")
					ClearPedTasks(ped)
					return
				else
					exports["progressBars"]:startUI(5000, "Getting back on Track")
					Wait(5000)
				end
			end
			Wait(1000)
			exports["progressBars"]:startUI(5000, "Pumping tire up...")
			Wait(5000)
			SetVehicleTyreFixed(vehicle, wheels[key][2])
			SetVehicleWheelHealth(vehicle, wheels[key][2], 100)
			Notifacation("Wheel Repaired")
			TriggerServerEvent('tuner:removeitem', 'puncturekit', 1)
		elseif amount == 0 then
			Notifacation("You do not have a Tire to replace it with")
		elseif not IsVehicleTyreBurst(vehicle, wheels[key][2], false) then
			Notifacation("Tyre already in Good Condition")
		end
		ClearPedTasks(ped)
	end, "tire")
end

RegisterNetEvent('repair:puncturekit')
AddEventHandler('repair:puncturekit', function()
	local wheelDistances = {}
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71) --VehicleInFront(ped)
	ESX.TriggerServerCallback('tuner:itemamount', function(amount)
		for k, vehwheel in pairs(wheels) do
			local wheelBone = GetEntityBoneIndexByName(vehicle, vehwheel[1])
			local wheelPos = GetWorldPositionOfEntityBone(vehicle, wheelBone)
			local distance = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, wheelPos.x, wheelPos.y, wheelPos.z)
			
			table.insert(wheelDistances, distance)
		end
		local key, min = 1, wheelDistances[1]
			
		for k, v in ipairs(wheelDistances) do
				if wheelDistances[k] < min then
					key, min = k, v
				end
		end 
		if not IsVehicleTyreBurst(vehicle, wheels[key][2], true) and IsVehicleTyreBurst(vehicle, wheels[key][2], false) and amount > 0 then
			TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)
			Wait(1000)
			exports["progressBars"]:startUI(5000, "Attaching Sealant...")
			Wait(5000)
			local finished = exports["skillbar"]:taskBar(5000,math.random(1,5))
			if finished ~= 100 then
				local finishedchance = exports["skillbar"]:taskBar(2500,math.random(3,8))
				if finishedchance ~= 100 then
					Notifacation("Attempt Failed")
					ClearPedTasks(ped)
					return
				else
					exports["progressBars"]:startUI(5000, "Getting back on Track")
					Wait(5000)
				end
			end
			Wait(1000)
			exports["progressBars"]:startUI(5000, "Injecting Sealant...")
			Wait(5000)
			local finished2 = exports["skillbar"]:taskBar(5000,math.random(1,5))
			if finished2 ~= 100 then
				local finished2chance = exports["skillbar"]:taskBar(2500,math.random(3,8))
				if finishedchance ~= 100 then
					Notifacation("Attempt Failed")
					ClearPedTasks(ped)
					return
				else
					exports["progressBars"]:startUI(5000, "Getting back on Track")
					Wait(5000)
				end
			end
			Wait(1000)
			exports["progressBars"]:startUI(5000, "Pumping tire up...")
			Wait(5000)
			SetVehicleTyreFixed(vehicle, wheels[key][2])
			SetVehicleWheelHealth(vehicle, wheels[key][2], 100)
			Notifacation("Wheel Repaired")
			TriggerServerEvent('tuner:removeitem', 'puncturekit', 1)
		elseif amount == 0 then
			Notifacation("You do not have a Puncture Kit")
		elseif not IsVehicleTyreBurst(vehicle, wheels[key][2], false) then
			Notifacation("Tyre already in Good Condition")
		elseif IsVehicleTyreBurst(vehicle, wheels[key][2], true) then
			Notifacation("You will need a new Tire for this")
		end
		ClearPedTasks(ped)
	end, "puncturekit")
end)

local windows = {
	["fl"] = 0, -- Front Left
	["fr"] = 1, -- Front Right
	["rl"] = 2, -- Rear Left
	["rr"] = 3, -- Rear Right
}
 function windowrolling(windowid)
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	if IsVehicleWindowIntact(vehicle, windows[windowid]) then
		RollDownWindow(vehicle, windows[windowid])
	else
		RollUpWindow(vehicle, windows[windowid])
	end
end

RegisterCommand("bodywork", function(source)
		BodyWork()
end, false)

RegisterCommand("hood", function(source)
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	if GetVehicleDoorAngleRatio(vehicle, 4) < 0.1 then
		SetVehicleDoorOpen(vehicle, 4, 1, 0)
	end
end, false)
RegisterCommand("windowroll", function(source, args)
	windowrolling(args[1])
end, false)
RegisterCommand("tunershopupgrades", function(source, args)
	local player = GetPlayerPed(-1)
	if (GetSelectedPedWeapon(player) == 419712736) then
		tunerperformance(args[1], args[2])
	end
end, false)
RegisterCommand("tunershoprepair", function(source, args)
	local player = GetPlayerPed(-1)
	if (GetSelectedPedWeapon(player) == 419712736) then
		if args[1] == "service" then
			tunerservice()
		elseif args[1] == "tire" then
			tirereplacement()
		end
	end
end, false)