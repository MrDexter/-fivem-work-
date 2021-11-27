local ESX = nil
local showText = false
local modStage = ""
local modifacation = ""
local currentStage = ""
local maxStage = 3
local minStage = -1
local prevBumper
local modname = {
	["11"] = {11, "Engine"},
	["12"] = {12, "Brakes"},
	["13"] = {13, "Transmission"},
	["15"] = {15, "Suspension"},
	["18"] = {18, "Turbo"}
}
local stageName = {
	[-1] = {"Stock", ""},
	[0] = {"One", "Remove"},
	[1] = {"Two", "Install"},
	[2] = {"Three", ""},
	[3] = {"Four", ""},
}
local doors = {
	{"door_dside_f", 0},
	{"door_pside_f", 1},
	{"door_dside_r", 2},
	{"door_pside_r", 3},
	{"bonnet", 4},
	{"boot", 5},
}
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

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)	
end

RegisterNetEvent('bumperupgrade')
AddEventHandler('bumperupgrade', function()
	modifacation = "Bumper"
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71)
	TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
	prevBumper = GetVehicleMod(vehicle, 1)
	modStage = 1
	showText = true
	Wait(2500)
	ClearPedTasks(ped)
	while showText == true do Wait(500) end
	TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
	Progress("Bolts", "Tightening ", 2500)
	SetVehicleMod(vehicle, 1, modStage - 1)
	ClearPedTasks(ped)
end)

RegisterCommand('texttest', function(source, args) 
	if args[1] == "true" then
		modifacation = "Bumper"
		prevBumper = GetVehicleMod(vehicle, 1)
		modStage = 1
		showText = true
	else 
		showText = false
	end
end, false)

function SetIbuttons(buttons, layout)
	Citizen.CreateThread(function()
		if not HasScaleformMovieLoaded(Ibuttons) then
			Ibuttons = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
			while not HasScaleformMovieLoaded(Ibuttons) do
				Citizen.Wait(0)
			end
		else
			Ibuttons = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
			while not HasScaleformMovieLoaded(Ibuttons) do
				Citizen.Wait(0)
			end
		end
		local sf = Ibuttons
		local w,h = GetScreenResolution()
		PushScaleformMovieFunction(sf,"CLEAR_ALL")
		PopScaleformMovieFunction()
		PushScaleformMovieFunction(sf,"SET_DISPLAY_CONFIG")
		PushScaleformMovieFunctionParameterInt(w)
		PushScaleformMovieFunctionParameterInt(h)
		PushScaleformMovieFunctionParameterFloat(0.03)
		PushScaleformMovieFunctionParameterFloat(0.98)
		PushScaleformMovieFunctionParameterFloat(0.01)
		PushScaleformMovieFunctionParameterFloat(0.95)
		PushScaleformMovieFunctionParameterBool(true)
		PushScaleformMovieFunctionParameterBool(false)
		PushScaleformMovieFunctionParameterBool(false)
		PushScaleformMovieFunctionParameterInt(w)
		PushScaleformMovieFunctionParameterInt(h)
		PopScaleformMovieFunction()
		PushScaleformMovieFunction(sf,"SET_MAX_WIDTH")
		PushScaleformMovieFunctionParameterInt(1)
		PopScaleformMovieFunction()
		
		for i,btn in pairs(buttons) do
			PushScaleformMovieFunction(sf,"SET_DATA_SLOT")
			PushScaleformMovieFunctionParameterInt(i-1)
			PushScaleformMovieFunctionParameterString(btn[1])
			PushScaleformMovieFunctionParameterString(btn[2])
			PopScaleformMovieFunction()
			
		end
		if layout ~= 1 then
			PushScaleformMovieFunction(sf,"SET_PADDING")
			PushScaleformMovieFunctionParameterInt(10)
			PopScaleformMovieFunction()
		end
		PushScaleformMovieFunction(sf,"DRAW_INSTRUCTIONAL_BUTTONS")
		PushScaleformMovieFunctionParameterInt(layout)
		PopScaleformMovieFunction()
	end)
end

function DrawIbuttons()
	if HasScaleformMovieLoaded(Ibuttons) then
		DrawScaleformMovie(Ibuttons, 0.5, 0.5, 1.0, 1.0, 255, 255, 255, 255)
	end
end

function Notifacation(text)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandThefeedPostTicker(false, true)
end

function Progress(type, stage, time)
	local ProgressText = {
		Service = "",
		TireChange = "",
		Engine = ""
	}
	Wait(1000)
	exports["progressBars"]:startUI(time, "Preparing...")
	Wait(time)
	local finished = exports["skillbar"]:taskBar(time,math.random(1,5))
	print(finished)
	if finished ~= 100 then
		local finishedchance = exports["skillbar"]:taskBar(time / 2,math.random(3,5))
		if finishedchance ~= 100 then
			ClearPedTasks(ped)
			return false
		else
			exports["progressBars"]:startUI(time, "Getting back on Track")
			Wait(time)
		end
	end
	Wait(1000)
	exports["progressBars"]:startUI(time,stage .. " " .. type)
	Wait(time)
	local finished2 = exports["skillbar"]:taskBar(time,math.random(1,5))
	if finished2 ~= 100 then
		local finished2chance = exports["skillbar"]:taskBar(time / 2,math.random(3,6))
		if finishedchance ~= 100 then
			ClearPedTasks(ped)
			return false
		else
			exports["progressBars"]:startUI(time, "Getting back on Track")
			Wait(time)
		end
	end
	Wait(1000)
	exports["progressBars"]:startUI(time, "Completing Process")
	Wait(time)	
	return true
end

function GetClosestDoor(vehicle, plyCoords)
	local doorDistances = {}
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
	return doors[key][2]
end

function GetClosestWheel(vehicle, plyCoords)
	local wheelDistances = {}
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
	return wheels[key][2]
end

RegisterCommand("closestdoor", function(source)
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71)
	local closestDoor = GetClosestDoor(vehicle, plyCoords)
	print(closestDoor)
end, false)

RegisterNetEvent('vehicle:body')
AddEventHandler('vehicle:body', function()
	print("HIIIII")
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71)
	local closestDoor = GetClosestDoor(vehicle, plyCoords)

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
	doorDistances = {}


	for k, door in pairs(doorstate) do
		local entryCoords
		if door[2] == 4 then
			 entryCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 2.5, 0.0)
		elseif door[2] == 5 then
			entryCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.0)
		else
			entryCoords = GetEntryPositionOfDoor(vehicle, door[2])
		end
		local distance = GetDistanceBetweenCoords(plyCoords.x, plyCoords.y, plyCoords.z, entryCoords.x, entryCoords.y, entryCoords.z, false)
		table.insert(doorDistances, distance)
		local state = IsVehicleDoorDamaged(vehicle, door[2])
		if state then--closestDoor ~= door[2] then
			door[3] = false
		end
	end
	local key, min = 1, doorDistances[1]
		
	for k, v in ipairs(doorDistances) do
			if doorDistances[k] < min then
				key, min = k, v
			end
	end 
	doorstate[key][3] = true

	TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
	--local Passed = Progress("Fixing", "More", 2500)
	Passed = true
	if Passed then 
		Wait(1000)
		ClearPedTasks(ped)
		--SetVehicleDeformationFixed(vehicle)
		SetVehicleFixed(vehicle)
		--SetVehicleBodyHealth(vehicle, 1000.0)
		for k, door in pairs(doorstate) do
			if door[3] == false then
				SetVehicleDoorBroken(vehicle, door[2], 1)
			end			
		end
	else
		Notifacation("Failed")
		ClearPedTasks(ped)
	end		
end)

--[[ RegisterNetEvent('RepairVehicle')
AddEventHandler('RepairVehicle', function()
		local ped = PlayerPedId()
		local plyCoords = GetEntityCoords(ped, false)
		local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71)
		--SetVehicleEngineHealth(vehicle, 100)
		SetVehicleBodyHealth(vehicle, 1000.0)
		SetVehicleDeformationFixed(vehicle)
		--SetVehicleFixed(vehicle)
		--ShowNotification("Vehicle Fixed")
end)

 RegisterCommand("repair", function(source)
	TriggerEvent('RepairVehicle')
end, false) ]]

RegisterCommand("bumpers", function(source, args)
	local bumpers = bumpers(args[1])
	print(bumpers[1], bumpers[2])
end, false)

function bumpers(mod)
	mod = 1
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
	print(bumpers[1], bumpers[2])
	return bumpers
end



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
   		if IsControlJustReleased(0, 38) and running ~= true and GetVehiclePedIsIn(ped, false) == 0 and not (GetSelectedPedWeapon(ped) == 419712736) then
			local plyCoords = GetEntityCoords(ped, false)
      		local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71)
				
      		running = true -- stops spamming open close
				
      		if vehicle ~= nil then
				local plyCoords = GetEntityCoords(ped, false)
				local closestDoor = GetClosestDoor(vehicle, plyCoords)
				if 	GetVehicleDoorAngleRatio(vehicle, closestDoor) > 0.0 and GetVehicleDoorAngleRatio(vehicle, closestDoor) < 0.75 then 
					SetVehicleDoorOpen(vehicle, closestDoor, 0,0)
				else
					SetVehicleDoorShut(vehicle, closestDoor, 0,0)
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
	local closestDoor = GetClosestDoor(vehicle, plyCoords)
	Colors = {
		["-1"] = {-1, "No Color"},
		["0"] = {0, "White"},
		["1"] = {1, "Blue"},
		["2"] = {2, "Electric Blue"},
		["3"] = {3, "Mint Green"},
		["4"] = {4, "Lime Green"},
		["5"] = {5, "Yellow"},
		["6"] = {6, "Golden Shower"},
		["7"] = {7, "Orange"},
		["8"] = {8, "Red"},
		["9"] = {9, "Pony Pink"},
		["10"] = {10, "Hot Pink"},
		["11"] = {11, "Purple"},
		["12"] = {12, "Blacklight"},
	}
	Types = {
		["Stock"] = {"Stock", false},
		["Xenon"] = {"Xenon", 1},
		["Color"] = {Colors[color][2], Colors[color][1]}
	}
	ESX.TriggerServerCallback('tuner:itemamount', function(amount)
		if (closestDoor == 4 and GetVehicleDoorAngleRatio(vehicle, 4) > 0.75) and amount > 0 or notCar and amount > 0 then
			if (type ~= "Color" and IsToggleModOn(vehicle, 22) ~= Types[type][2]) or (type == "Color" and GetVehicleXenonLightsColour(vehicle) ~= Types[type][2]) then
				TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
				Passed = Progress(Types[type][1], "Installing Headlights - ", 2500)
				if Passed then
					if type == "Color" then
						ToggleVehicleMod(vehicle, 22, 1)
						SetVehicleXenonLightsColour(vehicle, Types[type][2])
						TriggerServerEvent('tuner:removeitem', 'lightbulb', 1)
					else
						ToggleVehicleMod(vehicle, 22, Types[type][2])
						SetVehicleXenonLightsColour(vehicle, -1)
						TriggerServerEvent('tuner:removeitem', 'lightbulb', 1)
					end
				else
					Notifacation("Installation Failed")
					ClearPedTasks(ped)
				end
			else
				Notifacation("Already have this Installed")
			end
			ClearPedTasks(ped)
		elseif amount == 0 then
			Notifacation("You do not have a Lightbulb")
		elseif not notCar and GetVehicleDoorAngleRatio(vehicle, 4) < 0.75 then
			Notifacation("Hood not open")
		elseif not notCar and closestDoor ~= 4 then
			Notifacation("You need to be at the Hood")
		else
			Notifacation("You appear to have found an issue :/")
		
		end
	end, "lightbulb")
end

function tunerperformance(mod)
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71) --VehicleInFront(ped)
	local notCar = IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelAQuadbike(GetEntityModel(vehicle))
	local closestDoor = GetClosestDoor(vehicle, plyCoords)
	if (closestDoor == 4 and GetVehicleDoorAngleRatio(vehicle, 4) > 0.75) or notCar then
		if modname[mod][2] == "Turbo" then
			ESX.TriggerServerCallback('tuner:itemamount', function(amount)
				currentStage = tonumber(IsToggleModOn(vehicle, 18))
				if currentStage == nil then currentStage = 0 end
				modifacation = modname[mod][2]
				modStage = currentStage
				if amount >= modStage then
				TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
				showText = true
				while showText == true do Citizen.Wait(100) end
					Passed = Progress(modname[mod][2], stageName[modStage][2], 5000)
					if Passed then
						ToggleVehicleMod(vehicle, modname[mod][1], modStage)
						if modStage == 1 then
							TriggerServerEvent('tuner:removeitem', 'turbo', 1)
						elseif modStage == 0 then
							TriggerServerEvent('tuner:additem', 'turbo', 1)
						end
						ClearPedTasks(ped)
					else
						Notifacation("Installation Failed")
						ClearPedTasks(ped)
					end
				elseif amount < modStage then
					Notifacation("You don't have a Turbo")
				elseif IsToggleModOn(vehicle, 18) == false and modid[modStage][3] == false then
					Notifacation("Vehicle Doesn't have a Turbo")
				else
					Notifacation("Vehicle already has a Turbo")
					ClearPedTasks(ped)
				end
			end, "turbo")
		else
			ESX.TriggerServerCallback('tuner:itemamount', function(amount)
				if amount > 0 then
					TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
					currentStage = GetVehicleMod(vehicle, modname[mod][1])
					showText = true
					modifacation = mod --modname[mod][2]
					modStage = currentStage
					while showText == true do Citizen.Wait(100) end
					if (modifacation and modStage) == "" then return end
					if modStage ~= currentStage then
						Citizen.Wait(1000)
						Passed = Progress(modname[mod][2], "Stage " .. stageName[modStage][1], 2500)
						if Passed then
							SetVehicleMod(vehicle, modname[mod][1], modStage, false)
							ClearPedTasks(ped)
						else
							Notifacation("Installation Failed")
							ClearPedTasks(ped)
						end
					else
						Notifacation("Vehicle already at "..modname[mod][2] .. " Stage: " .. stageName[modStage][1] )
					end
				else
					Notifacation("You need a Tuning Laptop")
				end
			end, "tuning_laptop")
		end
	elseif not notCar and GetVehicleDoorAngleRatio(vehicle, 4) < 0.75 then
		Notifacation("Hood not open")
	elseif not notCar and closestDoor ~= 4 then
		Notifacation("You need to be at the Hood")
	else
		Notifacation("You appear to have found an issue :/")
	end
end

RegisterNetEvent('vehicle:service')
AddEventHandler('vehicle:service', function()
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71) --VehicleInFront(ped)
	local notCar = IsThisModelABike(GetEntityModel(vehicle)) or IsThisModelAQuadbike(GetEntityModel(vehicle))
	local closestDoor = GetClosestDoor(vehicle, plyCoords)
	ESX.TriggerServerCallback('tuner:itemamount', function(amount)
		if closestDoor == 4 and GetVehicleDoorAngleRatio(vehicle, 4) > 0.75 and GetVehicleEngineHealth(vehicle) < 1000.0 and amount > 0 or notCar and GetVehicleEngineHealth(vehicle) < 1000.0 then
			TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
			Passed = Progress("Servicing Engine", "", 5000)
			if Passed then 
				SetVehicleEngineHealth(vehicle, 1000.0)
				SetVehicleOilLevel(vehicle, 1000.0)
				TriggerServerEvent('tuner:removeitem', 'servicekit', 1)
				Notifacation("Service Complete")
				ClearPedTasks(ped)
			else
				Notifacation("Installation Failed")
				ClearPedTasks(ped)
			end
		elseif amount == 0 then
			Notifacation("You don't have an Engine Service Kit")
		elseif GetVehicleEngineHealth(vehicle) == 1000.0 then
			Notifacation("Engine already in good Condition")
		elseif not notCar and GetVehicleDoorAngleRatio(vehicle, 4) < 0.75 then
			Notifacation("Hood not Open")
		elseif not notCar and closestDoor ~= 4 then
			Notifacation("You need to be at the Hood")
		else
			Notifacation("You appear to have found an issue :/")
		end	
	end, "servicekit")
end)




RegisterNetEvent('vehicle:tire')
AddEventHandler('vehicle:tire', function()
	local ped = PlayerPedId()
	local plyCoords = GetEntityCoords(ped, false)
	local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71) --VehicleInFront(ped)
	local closestWheel = GetClosestWheel(vehicle, plyCoords)
	ESX.TriggerServerCallback('tuner:itemamount', function(amount)
		if IsVehicleTyreBurst(vehicle, closestWheel, false) and amount > 0 then
			TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)
			Progress("Installing New Tire... ", "", 5000)
			SetVehicleTyreFixed(vehicle, closestWheel)
			SetVehicleWheelHealth(vehicle, closestWheel, 100)
			Notifacation("Wheel Repaired")
			TriggerServerEvent('tuner:removeitem', 'puncturekit', 1)
		elseif amount == 0 then
			Notifacation("You do not have a Tire to replace it with")
		elseif not IsVehicleTyreBurst(vehicle, closestWheel, false) then
			Notifacation("Tyre already in Good Condition")
		end
		ClearPedTasks(ped)
	end, "tire")
end)

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

RegisterNetEvent('vehicle:hood')
AddEventHandler("vehicle:hood", function()
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	if GetVehicleDoorAngleRatio(vehicle, 4) < 0.1 then
		SetVehicleDoorOpen(vehicle, 4, 1, 0)
	end
end)

RegisterNetEvent('vehicle:tunershopupgrades')
AddEventHandler("vehicle:tunershopupgrades", function(params)
	local player = GetPlayerPed(-1)
	if (GetSelectedPedWeapon(player) == 419712736) then
		tunerperformance(params[1], params[2])
	end
end)

RegisterCommand("hood", function(source)
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		if GetVehicleDoorAngleRatio(vehicle, 4) < 0.1 then
			SetVehicleDoorOpen(vehicle, 4, 1, 0)
		end
end, false)
RegisterCommand("window", function(source, args)
	windowrolling(args[1])
end, false)
RegisterCommand("tunershopupgrades", function(source, args)
	local player = GetPlayerPed(-1)
	if (GetSelectedPedWeapon(player) == 419712736) then
		tunerperformance(args[1])
	end
end, false)
RegisterCommand("tunershoprepair", function(source, args)
	local player = GetPlayerPed(-1)
	print("EWWW")
	print(args[1])
	if (GetSelectedPedWeapon(player) == 419712736) then
		if args[1] == "service" then
			TriggerEvent('vehicle:service')
		elseif args[1] == "tire" then
			TriggerEvent('vehicle:tire')
		elseif args[1] == "body" then
			print("YEPPPP")
			TriggerEvent('vehicle:body')
		end
	end
end, false)



Citizen.CreateThread(function() 
	while true do
		Citizen.Wait(0)
				local ped = PlayerPedId()
				local plyCoords = GetEntityCoords(ped, false)
				local vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0,0,71) --VehicleInFront(ped)
		if showText == true then
			--drawTxt('~h~Select ' .. modifacation .. ' Stage:~h~~n~' .. stageName[modStage][1], 4, 1, 0.5, 0.8, 0.75, 255,255,255,255 )
			if modifacation == "Turbo" then
				maxStage = 1 
				minStage = 0 
				drawTxt('~h~Select ' .. modifacation .. ' Stage:~h~~n~' .. stageName[modStage][2], 4, 1, 0.5, 0.8, 0.75, 255,255,255,255 )
			elseif modifacation == "Bumper" then
				maxStage = tonumber(GetNumVehicleMods(vehicle,1))
				minStage = 0
				local bumpers = bumpers(1)
				bumpers[0] = "Stock"
				drawTxt('~h~Select ' .. modifacation .. '~h~~n~' .. bumpers[modStage], 4, 1, 0.5, 0.8, 0.75, 255,255,255,255 )
			else
				print(tonumber(GetNumVehicleMods(vehicle,modname[modifacation][1])))
				maxStage = GetNumVehicleMods(vehicle,modname[modifacation][1]) - 1
				minStage = -1
				drawTxt('~h~Select ' .. modname[modifacation][2] .. ' Stage:~h~~n~' .. stageName[modStage][1], 4, 1, 0.5, 0.8, 0.75, 255,255,255,255 )
			end
			DrawIbuttons()
			SetIbuttons({
				{GetControlInstructionalButton(1,177, 0),"Cancel"},
				{GetControlInstructionalButton(1,175, 0),"Increase"},
				{GetControlInstructionalButton(1,174, 0),"Decrease"},
				{GetControlInstructionalButton(1,201, 0),"Install"},
				{GetControlInstructionalButton(1,29, 0),"Preview"}
			 },0)
		end
		if showText == true and IsControlJustReleased(0, 201) then
			if currentStage == modStage  then
				if modifacation == "Turbo" then
					if modStage == 1 then
						Notifacation("Vehicle already has a Turbo installed" )
					else
						Notifacation("Vehicle doesn't have a Turbo to remove" )
					end
				else
					Notifacation("Vehicle already has this installed")
				end
			else
				showText = false
			end
		elseif showText == true and IsControlJustReleased(0, 175) and modStage < maxStage then
			modStage = modStage + 1
		elseif showText == true and IsControlJustReleased(0, 174) and modStage > minStage then
			modStage = modStage - 1
		elseif showText == true and IsControlJustReleased(0, 29) then
			if modifacation == "Bumper" then
				SetVehicleMod(vehicle, 1, modStage - 1, false)
			else
				Notifacation("Cannot Preview this Mod")
			end
		elseif showText == true and IsControlJustReleased(0, 177) then
			if modifacation == "Bumper" then
				SetVehicleMod(vehicle, 1, prevBumper, false)
			end
			showText = false
			local ped = PlayerPedId()
			ClearPedTasks(ped)
			modifacation = ""
			modStage = ""
		end
	end
end)