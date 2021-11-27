--[[
Doing:
Change Camera

]]
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

seatSideAngle = 30
renderScaleform = false
renderTime = false
renderBet = false
renderHand = false
selectedBet = 1
aimingAtBet = -1
lastAimedBet = -1
hoverObjects = {}
tables = {}
betObjects = {}
dealer = {}
numbersData = {}
betData = {}
Table = {}
cameraMode = 1

RegisterCommand("roulette", function(source, args)
	if args[1] == "1" then
		print("Roulette = True") 
		inZone = true
	else
		inZone = false
		print("Roulette = False") 
	end
end)

-- Hud
Citizen.CreateThread(function()

    scaleform = RequestScaleformMovie_2("INSTRUCTIONAL_BUTTONS")

    repeat Wait(0) until HasScaleformMovieLoaded(scaleform)

	while true do Wait(0)
		if renderScaleform == true then
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
		end

        local barCount = {1}
        
        if renderTime == true and tables[scrollerIndex].ido ~= nil then
			if tables[scrollerIndex].ido > 0 then
				DrawTimerBar(barCount, "TIME", s2m(tables[scrollerIndex].ido))
			end
		end

		if renderBet == true then
			DrawTimerBar(barCount, "BET", bet)
		end
    
    end

end)

-- Create Tables, Peds,  sit down
function ProcessTables()  --RUNS ONCE from resource start, but hangs around till player dead
	RequestAnimDict("anim_casino_b@amb@casino@games@shared@player@")

    RequestModel(GetHashKey('vw_prop_casino_roulette_01'))
    RequestModel(GetHashKey('S_F_Y_Casino_01'))
    while not HasModelLoaded(GetHashKey('vw_prop_casino_roulette_01')) or not HasModelLoaded(GetHashKey('S_F_Y_Casino_01')) do
        Citizen.Wait(1)
    end

    
    for i,k in pairs (Config.Tables) do
        local tableModel = 'vw_prop_casino_roulette_01'
        if k.highStakes == true then
            tableModel = 'vw_prop_casino_roulette_01b'
        end
        Table[i] = CreateObject(GetHashKey(tableModel), Config.Tables[i].coords, false)
        SetEntityHeading(Table[i], Config.Tables[i].rot)
        loadTableData(Table[i], i)
        if k.highStakes then
            SetObjectTextureVariant(Table[i],1) -- 0 = Green, 1 == Red, 2 == Blue, 3 == Purple
        end

        local model = `s_f_y_casino_01`
        local dealerOffset = GetObjectOffsetFromCoords(Config.Tables[i].coords, Config.Tables[i].rot, 0.0, 0.7, 1.0)
        dealer[i] = CreatePed(4, model, dealerOffset, Config.Tables[i].rot + 180.0, false, true)
		
		SetEntityCanBeDamaged(dealer[i], false)
		SetBlockingOfNonTemporaryEvents(dealer[i], true)
		SetPedCanRagdollFromPlayerImpact(dealer[i], false)

		SetDealerVoice(dealer[i], 1)

		SetPedResetFlag(dealer[i], 249, true)
		SetPedConfigFlag(dealer[i], 185, true)
		SetPedConfigFlag(dealer[i], 108, true)
		SetPedConfigFlag(dealer[i], 208, true)

		SetDealerOutfit(dealer[i], 1+6)

		local scene = CreateSynchronizedScene(Config.Tables[i].coords, 0.0, 0.0, Config.Tables[i].rot, 2)
		TaskSynchronizedScene(dealer[i], scene, "anim_casino_b@amb@casino@games@shared@dealer@", "idle", 1000.0, -8.0, 4, 1, 1148846080, 0)
    end


	while true do Wait(0)

		if inZone then

			playerPed = PlayerPedId()

			if not IsEntityDead(playerPed) and not IsEntityPlayingAnim(playerPed, 'misslamar1dead_body', 'dead_idle', 3) then --Player Alive?
				for i,v in pairs(Config.Tables) do       --iterate all tables
					local cord = v.coords
					local highStakes = v.highStakes
						local pCoords = GetEntityCoords(playerPed)

					if GetDistanceBetweenCoords(cord.x, cord.y, cord.z, pCoords, true) < 3.0 then --player near tables

						-- local pCoords = vector3(cord.x, cord.y, cord.z)
						tableObj = GetClosestObjectOfType(pCoords, 1.0, `vw_prop_casino_roulette_01`, false, false, false)

                        if GetEntityCoords(tableObj) == vector3(0.0, 0.0, 0.0) then-- highStakes
							tableObj = GetClosestObjectOfType(pCoords, 1.0, `vw_prop_casino_roulette_01b`, false, false, false)
						end

						if GetEntityCoords(tableObj) ~= vector3(0.0, 0.0, 0.0) then --we have a valid table, find the nearest chair (bit hacky tbh)
							closestChair = 1
							local coords = GetWorldPositionOfEntityBone(tableObj, GetEntityBoneIndexByName(tableObj, "Chair_Base_0"..closestChair))
							local rot = GetWorldRotationOfEntityBone(tableObj, GetEntityBoneIndexByName(tableObj, "Chair_Base_0"..closestChair))
							dist = GetDistanceBetweenCoords(coords, GetEntityCoords(playerPed), true) --why not set dist to 10 and just do loop below?

							for i=1,4 do
								local coords = GetWorldPositionOfEntityBone(tableObj, GetEntityBoneIndexByName(tableObj, "Chair_Base_0"..i))
								if GetDistanceBetweenCoords(coords, GetEntityCoords(playerPed), true) < dist then
									dist = GetDistanceBetweenCoords(coords, GetEntityCoords(playerPed), true) --gurgle... sucky... wasted repeat
									closestChair = i
								end
							end

							local coords = GetWorldPositionOfEntityBone(tableObj, GetEntityBoneIndexByName(tableObj, "Chair_Base_0"..closestChair)) --oof, we already had this!
							local rot = GetWorldRotationOfEntityBone(tableObj, GetEntityBoneIndexByName(tableObj, "Chair_Base_0"..closestChair))

							g_coords = coords --ok, so we got there in the end. Coords and Rotation of closest chair
							g_rot = rot

							local angle = rot.z-findRotation(coords.x, coords.y, pCoords.x, pCoords.y)+90.0

							local seatAnim = "sit_enter_"

							if angle > 0 then seatAnim = "sit_enter_left" end
							if angle < 0 then seatAnim = "sit_enter_right" end
							if angle > seatSideAngle or angle < -seatSideAngle then seatAnim = seatAnim .. "_side" end

							local canSit = true

							if canSitDownCallback ~= nil then
								canSit = canSitDownCallback()
							end

							if GetDistanceBetweenCoords(coords, GetEntityCoords(playerPed), true) < 1.5 and not IsSeatOccupied(coords, 0.5) and canSit then
								if highStakes then
									DisplayHelpText("Press ~INPUT_CONTEXT~ to play High-Limit Roulette.")
								else
									DisplayHelpText("Press ~INPUT_CONTEXT~ to play Roulette.")
								end

								if IsControlJustPressed(1, 51) then --pressed E to sit and join the table
									if satDownCallback ~= nil then
										satDownCallback()
									end

									local initPos = GetAnimInitialOffsetPosition("anim_casino_b@amb@casino@games@shared@player@", seatAnim, coords, rot, 0.01, 2)
									--local initRot = GetAnimInitialOffsetRotation("anim_casino_b@amb@casino@games@shared@player@", seatAnim, coords, rot, 0.01, 2)

									TaskGoStraightToCoord(playerPed, initPos, 1.0, 5000, initPos.z, 0.01)
									repeat
										Wait(0)
									until GetScriptTaskStatus(playerPed, 2106541073) == 7
									Wait(50)

									SetPedCurrentWeaponVisible(playerPed, 0, true, 0, 0)

									local scene = NetworkCreateSynchronisedScene(coords, rot, 2, true, true, 1065353216, 0, 1065353216)
									NetworkAddPedToSynchronisedScene(playerPed, scene, "anim_casino_b@amb@casino@games@shared@player@", seatAnim, 2.0, -2.0, 13, 16, 1148846080, 0)
									NetworkStartSynchronisedScene(scene)

									local scene = NetworkConvertSynchronisedSceneToSynchronizedScene(scene)
									repeat
										Wait(0)
										--DebugPrint("second GetSynchronizedScenePhase loop")
									until GetSynchronizedScenePhase(scene) >= 0.99 or HasAnimEventFired(playerPed, 2038294702) or HasAnimEventFired(playerPed, -1424880317)

									Wait(1000) --player should be sitting down now.


									idleVar = "idle_cardgames"

									scene = NetworkCreateSynchronisedScene(coords, rot, 2, true, true, 1065353216, 0, 1065353216)
									NetworkAddPedToSynchronisedScene(playerPed, scene, "anim_casino_b@amb@casino@games@shared@player@", "idle_cardgames", 2.0, -2.0, 13, 16, 1148846080, 0)
									NetworkStartSynchronisedScene(scene)

									repeat Wait(0) until IsEntityPlayingAnim(playerPed, "anim_casino_b@amb@casino@games@shared@player@", "idle_cardgames", 3) == 1

									g_bjtable = i

									leavingRoulette = false
                                    
									TriggerServerEvent("ROULETTE:PlayerSatDown", i, closestChair)

									local endTime = GetGameTimer() + math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@shared@player@", idleVar)*990)

                                    rouletteStart(true, v)

									Citizen.CreateThread(function() -- Disable pause while playing
										local startCount = false
										local maxWait = 0
										while true do
											Citizen.Wait(0)
											SetPauseMenuActive(false)

											if leavingRoulette == true and startCount == false then
												startCount = true
												maxWait = GetGameTimer()+3000 -- Make it so it enables 3 seconds after hitting the leave button so the pause menu doesn't show up when trying to leave
											end

											if startCount == true and maxWait < GetGameTimer() then
												SetPauseMenuActive(true)
												break
											end
										end
										SetPauseMenuActive(true)
									end)


									--second stage inner loop - runs while player is sat down at the table until leaving/left/dead
									while true do
										Wait(0)
										if GetGameTimer() >= endTime then
											if playerBusy == true then
												while playerBusy == true do
													Wait(0)

													-- local playerPed = PlayerPedId()

													if IsEntityDead(playerPed) or IsEntityPlayingAnim(playerPed, 'misslamar1dead_body', 'dead_idle', 3) then
														TriggerServerEvent("BLACKJACK:PlayerRemove", i) -- TODO
														ClearPedTasks(playerPed)
														leaveRoulette()
														break
													elseif leaveCheckCallback ~= nil then
														if leaveCheckCallback() then
															TriggerServerEvent("BLACKJACK:PlayerRemove", i)
															ClearPedTasks(playerPed)
															leaveRoulette()
															break
														end
													end
												end
											end

											if leavingRoulette == false then
												idleVar = "idle_var_0"..math.random(1,5)

												local scene = NetworkCreateSynchronisedScene(coords, rot, 2, true, true, 1065353216, 0, 1065353216)
												NetworkAddPedToSynchronisedScene(playerPed, scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, -2.0, 13, 16, 1148846080, 0)
												NetworkStartSynchronisedScene(scene)
												endTime = GetGameTimer() + math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@shared@player@", idleVar)*990)
												-- DebugPrint("idling again")
											end
										end
										if leavingRoulette == true then
											if standUpCallback ~= nil then
												standUpCallback()
											end
											local scene = NetworkCreateSynchronisedScene(coords, rot, 2, false, false, 1065353216, 0, 1065353216)
											NetworkAddPedToSynchronisedScene(playerPed, scene, "anim_casino_b@amb@casino@games@shared@player@", "sit_exit_left", 2.0, -2.0, 13, 16, 1148846080, 0)
											NetworkStartSynchronisedScene(scene)
											TriggerServerEvent("ROULETTE:PlayerSatUp", i)
											Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@shared@player@", "sit_exit_left")*800))
											ClearPedTasks(playerPed)
											break
										else
											-- local playerPed = PlayerPedId()
                                            -- If player dies remove
											if IsEntityDead(playerPed) or IsEntityPlayingAnim(playerPed, 'misslamar1dead_body', 'dead_idle', 3) then
												TriggerServerEvent("ROULETTE:NotAtTable", i)
												ClearPedTasks(playerPed)
												leaveRoulette()
												if standUpCallback ~= nil then
													standUpCallback()
												end
												break
											elseif leaveCheckCallback ~= nil then
												if leaveCheckCallback() then
													TriggerServerEvent("ROULETTE:NotAtTable", i)
													ClearPedTasks(playerPed)
													leaveRoulette()
													if standUpCallback ~= nil then
														standUpCallback()
													end
													break
												end
											end
										end

										-- if IsEntityPlayingAnim(PlayerPedId(), "anim_casino_b@amb@casino@games@shared@player@", idleVar, 3) ~= 1 then break end
									end
								end
							end
						end
					end
				end
			end

		end
	end
end

RegisterNetEvent('ROULETTE:playBetAnim')
AddEventHandler('ROULETTE:playBetAnim', function(chairId)
        local sex = 0

        if GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') then
            sex = 1
        end

        local rot = g_rot
        local pos = g_coords

        if chairId == 4 then
            rot = rot + vector3(0.0, 0.0, 90.0)
        elseif chairId == 3 then
            rot = rot + vector3(0.0, 0.0, -180.0)
        elseif chairId == 2 then
            rot = rot + vector3(0.0, 0.0, -90.0)
        elseif chairId == 1 then
            chairId = 1
            rot = rot + vector3(0.0, 0.0, -90.0)
        end

        local L = string.format('anim_casino_b@amb@casino@games@roulette@ped_male@seat_%s@regular@0%sa@play@v01', chairId, chairId)
        if sex == 1 then
            L = string.format('anim_casino_b@amb@casino@games@roulette@ped_female@seat_%s@regular@0%sa@play@v01', chairId, chairId)
        end

        RequestAnimDict(L)
        while not HasAnimDictLoaded(L) do
            Citizen.Wait(1)
        end

        if g_coords ~= nil then
            local currentScene = NetworkCreateSynchronisedScene(g_coords, rot, 2, 1, 0, 1065353216, 0, 1065353216)
            NetworkAddPedToSynchronisedScene(PlayerPedId(),currentScene,L,({'place_bet_zone1', 'place_bet_zone2', 'place_bet_zone3'})[math.random(1, 3)],4.0,-2.0, 13,16,1148846080,0)
            NetworkStartSynchronisedScene(currentScene)

            idleTimer = 8
        end
    end
)


RegisterNetEvent("ROULETTE:RequestBets")
AddEventHandler("ROULETTE:RequestBets", function(index)
	if leavingRoulette == true then leaveRoulette() return end

	Citizen.CreateThread(function()
		scrollerIndex = index
		renderScaleform = true
		renderTime = true
		renderBet = true

		PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
		PopScaleformMovieFunctionVoid()

		BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
		ScaleformMovieMethodAddParamInt(0)
		ScaleformMovieMethodAddParamInt(0)
		ScaleformMovieMethodAddParamInt(0)
		ScaleformMovieMethodAddParamInt(80)
		EndScaleformMovieMethod()

		BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
		ScaleformMovieMethodAddParamInt(0)
		ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0, 194, 0))
		ScaleformMovieMethodAddParamPlayerNameString("Exit")
		EndScaleformMovieMethod()

		BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
		ScaleformMovieMethodAddParamInt(1)
		ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0, 0, 0))
		ScaleformMovieMethodAddParamPlayerNameString("Change Camera")
		EndScaleformMovieMethod()

		BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
		ScaleformMovieMethodAddParamInt(2)
		ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 204, 0))
		ScaleformMovieMethodAddParamPlayerNameString("Max Bet")
		EndScaleformMovieMethod()

		BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
		ScaleformMovieMethodAddParamInt(3)
		ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 208, 0))
		ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 207, 0))
		ScaleformMovieMethodAddParamPlayerNameString("Adjust Bet")
		EndScaleformMovieMethod()

		BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
		EndScaleformMovieMethod()

		if (Config.Tables[scrollerIndex].highStakes == true) and selectedBet < Config.highTableLowLimit then
			selectedBet = Config.highTableLowLimit
		end

		while true do Wait(0)
			local tableLimit = (Config.Tables[scrollerIndex].highStakes == true) and #Config.bettingNums or Config.lowTableLimit
			local tableMinLimit = (Config.Tables[scrollerIndex].highStakes == true) and Config.highTableLowLimit or 1

			--DebugPrint("tableMinLimit: ".. tableMinLimit)

			if IsControlJustPressed(1, 204) then -- TAB / Y
				selectedBet = tableLimit
			elseif IsControlJustPressed(0, 194) then -- BACKSPACE / B
                rouletteStart(false)
				renderScaleform = false
				renderTime = false
				renderBet = false
				renderHand = false
				selectedBet = 1
                leaveRoulette()
				return
            elseif IsControlJustPressed(0, 0) then --V
                print("Cmera mode")
                changeCameraMode()
                -- changeKameraMode()
                PlaySoundFrontend(-1, 'FocusIn', 'HintCamSounds', false)
			end

			if not upPressed then
				if IsControlJustPressed(1, 208) then -- (PG-UP) RIGHT ARROW / DPAD RIGHT
					upPressed = true
					Citizen.CreateThread(function()
						selectedBet = selectedBet + 1
						if selectedBet > tableLimit then selectedBet = tableMinLimit end
						Citizen.Wait(175)
						while IsControlPressed(1, 208) do
							selectedBet = selectedBet + 1
							if selectedBet > tableLimit then selectedBet = tableMinLimit end
							Citizen.Wait(125)
						end

						upPressed = false
					end)
				end
			end

			if not downPressed then
				if IsControlJustPressed(1, 207) then -- (PG-DN) LEFT ARROW / DPAD LEFT
					downPressed = true
					Citizen.CreateThread(function()
						selectedBet = selectedBet - 1
						if selectedBet < tableMinLimit then selectedBet = tableLimit end
						Citizen.Wait(175)
						while IsControlPressed(1, 207) do
							selectedBet = selectedBet - 1
							if selectedBet < tableMinLimit then selectedBet = tableLimit end
							Citizen.Wait(125)
						end

						downPressed = false
					end)
				end
			end

			bet = Config.bettingNums[selectedBet] or 10000

			if #Config.bettingNums < Config.lowTableLimit and Config.Tables[scrollerIndex].highStakes == true then
				bet = bet * 10
			end
		end
	end)
end)

 function createBetObjects(bets)
    for i = 1, #betObjects, 1 do
        if DoesEntityExist(betObjects[i].obj) then
            DeleteObject(betObjects[i].obj)
        end
    end

    if bets == nil or bets == 0 then return end
    betObjects = {}

    local existBetId = {}

    for i = 1, #bets, 1 do
        local t = betData[scrollerIndex][bets[i].betId]

        if existBetId[bets[i].betId] == nil then
            existBetId[bets[i].betId] = 0
        else
            existBetId[bets[i].betId] = existBetId[bets[i].betId] + 1
        end

        if t ~= nil then
            local betModelObject = getBetObjectType(bets[i].betAmount)

            if betModelObject ~= nil then
                RequestModel(betModelObject)
                while not HasModelLoaded(betModelObject) do
                    Citizen.Wait(0)
                end

                local obj = CreateObject(betModelObject, t.objectPos.x, t.objectPos.y, t.objectPos.z + (existBetId[bets[i].betId] * 0.0081), false)
                SetEntityHeading(obj, Config.Tables[scrollerIndex].rot)
                table.insert(
                    betObjects,
                    {
                        obj = obj,
                        betAmount = bets[i].betAmount,
                        playerSrc = bets[i].playerSrc
                    }
                )
            end
        end
    end
end

function hoverNumbers(hoveredNumbers)
    for i = 1, #hoverObjects, 1 do
        if DoesEntityExist(hoverObjects[i]) then
            DeleteObject(hoverObjects[i])
        end
    end

    hoverObjects = {}

    for i = 1, #hoveredNumbers, 1 do
        local t = numbersData[scrollerIndex][hoveredNumbers[i]]
        if t ~= nil then
            RequestModel(GetHashKey(t.hoverObject))
            while not HasModelLoaded(GetHashKey(t.hoverObject)) do
                Citizen.Wait(1)
            end

            local obj = CreateObject(GetHashKey(t.hoverObject), t.hoverPos, false)
            SetEntityHeading(obj, Config.Tables[scrollerIndex].rot)

            table.insert(hoverObjects, obj)
        end
    end
end

function betRenderState(state)
    enabledBetRender = state

    if state then
        Citizen.CreateThread(function()
            while enabledBetRender do
                Citizen.Wait(8)
                if aimingAtBet ~= -1  then --and lastAimedBet ~= aimingAtBet
                    -- DebugPrint('aimed at different bet.')
                    lastAimedBet = aimingAtBet
                    local bettingData = betData[scrollerIndex][aimingAtBet]
                    if bettingData ~= nil then
                        hoverNumbers(bettingData.hoverNumbers)
                    else
                        hoverNumbers({})
                    end
                end

                if aimingAtBet == -1 and lastAimedBet ~= -1 then
                    hoverNumbers({})
                end
            end
        end)

        Citizen.CreateThread(function()
            while enabledBetRender do
                Citizen.Wait(0)

                ShowCursorThisFrame()

                local e = Config.Tables[scrollerIndex]
                if e ~= nil then
                    local cx, cy = GetNuiCursorPosition()
                    local rx, ry = GetActiveScreenResolution()

                    local n = 30 -- this is for the cursor point, how much to tolerate in range, increasing it you will find it easier to click on the bets.

                    local foundBet = false

                    for i = 1, #betData[scrollerIndex], 1 do
                        local bettingData = betData[scrollerIndex][i]
                        local onScreen, screenX, screenY = World3dToScreen2d(bettingData.pos.x, bettingData.pos.y, bettingData.pos.z)
                        local l = math.sqrt(math.pow(screenX * rx - cx, 2) + math.pow(screenY * ry - cy, 2))
                        if l < n then
                            foundBet = true
                            aimingAtBet = i
                            if IsDisabledControlJustPressed(0, 24) then
                                PlaySoundFrontend(-1, 'DLC_VW_BET_DOWN', 'dlc_vw_table_games_frontend_sounds', true)
                                TriggerServerEvent('ROULETTE:placeBet', scrollerIndex, aimingAtBet, bet)
                            end
                        end
                    end

                    if not foundBet then
                        aimingAtBet = -1
                    end
                end
            end
        end)
    end
end

function spinWheel(RouletteTable, tickRate)
    if DoesEntityExist(Table[RouletteTable]) and DoesEntityExist(dealer[RouletteTable]) then

        local animDicts = {
            'anim_casino_b@amb@casino@games@roulette@table',
            'anim_casino_b@amb@casino@games@roulette@dealer_female'
        }
        for i, k in pairs(animDicts) do
            RequestAnimDict(animDicts[i])
            while not HasAnimDictLoaded(animDicts[i]) do Wait(1)end
        end

        TriggerEvent('ROULETTE:playDealerSpeech', RouletteTable, 'MINIGAME_DEALER_CLOSED_BETS')
        TaskPlayAnim(dealer[RouletteTable], animDicts[2], 'no_more_bets', 3.0, 3.0, -1, 0, 0, true, true, true)

        Citizen.Wait(1500)

        if DoesEntityExist(ballObject) then
            DeleteObject(ballObject)
        end


        RequestModel(GetHashKey('vw_prop_roulette_ball'))
        while not HasModelLoaded(GetHashKey('vw_prop_roulette_ball')) do
            Citizen.Wait(1)
        end

        local ballOffset = GetWorldPositionOfEntityBone(Table[RouletteTable], GetEntityBoneIndexByName(Table[RouletteTable], 'Roulette_Wheel'))


        TaskPlayAnim(dealer[RouletteTable], animDicts[2], 'spin_wheel', 3.0, 3.0, -1, 0, 0, true, true, true)
        
        Wait(1500)

        ballObject = CreateObject(GetHashKey('vw_prop_roulette_ball'), ballOffset, false)
        SetEntityHeading(ballObject, Config.Tables[RouletteTable].rot)
        SetEntityCoordsNoOffset(ballObject, ballOffset, false, false, false)
        local h = GetEntityRotation(ballObject)
        SetEntityRotation(ballObject, h.x, h.y, h.z + 90.0, 2, false)

        if DoesEntityExist(Table[RouletteTable]) and DoesEntityExist(dealer[RouletteTable]) then

            PlayEntityAnim(Table[RouletteTable], 'intro_wheel', animDicts[1], 1000.0, false, true, true, 0, 136704)
            PlayEntityAnim(Table[RouletteTable], 'loop_wheel', animDicts[1], 1000.0, false, true, false, 0, 136704)

            Wait(1500)
            PlayEntityAnim(ballObject, 'intro_ball', animDicts[1], 1000.0, false, true, true, 0, 136704)
            PlayEntityAnim(ballObject, 'loop_ball', animDicts[1], 1000.0, false, true, false, 0, 136704)

            PlayEntityAnim(ballObject, string.format('exit_%s_ball', tickRate), animDicts[1], 1000.0, false, true, false, 0, 136704)
            PlayEntityAnim(Table[RouletteTable], string.format('exit_%s_wheel', tickRate), animDicts[1], 1000.0, false, true, false, 0, 136704)

            Citizen.Wait(11e3)

            if DoesEntityExist(Table[RouletteTable]) and DoesEntityExist(dealer[RouletteTable]) then
                TaskPlayAnim(dealer[RouletteTable], animDicts[2], 'clear_chips_zone1', 3.0, 3.0, -1, 0, 0, true, true, true)
                Citizen.Wait(1500)
                TaskPlayAnim(dealer[RouletteTable], animDicts[2], 'clear_chips_zone2', 3.0, 3.0, -1, 0, 0, true, true, true)
                Citizen.Wait(1500)
                TaskPlayAnim(dealer[RouletteTable], animDicts[2], 'clear_chips_zone3', 3.0, 3.0, -1, 0, 0, true, true, true)

                Citizen.Wait(2000)
                if DoesEntityExist(Table[RouletteTable]) and DoesEntityExist(dealer[RouletteTable]) then
                    TaskPlayAnim(dealer[RouletteTable], animDicts[2], 'idle', 3.0, 3.0, -1, 0, 0, true, true, true)
                end

                if DoesEntityExist(ballObject) then
                    DeleteObject(ballObject)
                end
            end
        end
    end
end

function rouletteStart(state, table)
    if state then
        TriggerEvent('ROULETTE:playDealerSpeech', scrollerIndex, 'MINIGAME_DEALER_GREET')
        DisplayRadar(false)
        -- TriggerEvent('ShowPlayerHud', false)

        DebugPrint('creating camera..')
        local rot = vector3(270.0, -90.0,  table.rot + 270.0)
        rouletteCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', table.coords.x, table.coords.y, table.coords.z + 2.0, rot.x, rot.y, rot.z, 80.0, true, 2)
        SetCamActive(rouletteCam, true)
        RenderScriptCams(true, 900, 900, true, false)
        DebugPrint('camera active.')

        tableID = table
        betRenderState(true)

        Citizen.CreateThread(
            function()
                while tableID ~= nil do
                    Citizen.Wait(1)
                    if betObjects then
                        for i = 1, #betObjects, 1 do
                            local bets = betObjects[i]
                            if DoesEntityExist(bets.obj) then
                                local coords = GetEntityCoords(bets.obj)
                                if bets.playerSrc == GetPlayerServerId(PlayerId()) then
                                end
                            end
                        end
                    end
                end
            end
        )

        Citizen.Wait(1500)
    else
        TriggerServerEvent('ROULETTE:NotAtTable', scrollerIndex)

        if DoesCamExist(rouletteCam) then
            DestroyCam(rouletteCam, false)
        end
        RenderScriptCams(false, 900, 900, true, false)
        betRenderState(false)
        leaveRoulette()
        tableID = nil

        DisplayRadar(true)
        -- TriggerEvent('ShowPlayerHud', true)
    end
end


function leaveRoulette()
	leavingRoulette = true
	renderScaleform = false
	renderTime = false
	renderBet = false
	selectedBet = 1
    aimingAtBet = -1
    lastAimedBet = -1
    hoverObjects = {}
    -- betObjects = {}
	SetFollowPedCamViewMode(1)
end

function changeCameraMode()
    if DoesCamExist(rouletteCam) then
        if cameraMode == 1 then
            DoScreenFadeOut(200)
            while not IsScreenFadedOut() do
                Citizen.Wait(1)
            end
            cameraMode = 2
            local camOffset = GetOffsetFromEntityInWorldCoords(Table[scrollerIndex], -1.45, -0.15, 1.45)
            SetCamCoord(rouletteCam, camOffset)
            SetCamRot(rouletteCam, -25.0, 0.0, Config.Tables[scrollerIndex].rot + 270.0, 2)
            SetCamFov(rouletteCam, 40.0)
            ShakeCam(rouletteCam, 'HAND_SHAKE', 0.3)
            DoScreenFadeIn(200)
        elseif cameraMode == 2 then
            DoScreenFadeOut(200)
            while not IsScreenFadedOut() do
                Citizen.Wait(1)
            end
            cameraMode = 3
            local camOffset = GetOffsetFromEntityInWorldCoords(Table[scrollerIndex], 1.45, -0.15, 2.15)
            SetCamCoord(rouletteCam, camOffset)
            SetCamRot(rouletteCam, -58.0, 0.0, Config.Tables[scrollerIndex].rot + 90.0, 2)
            ShakeCam(rouletteCam, 'HAND_SHAKE', 0.3)
            SetCamFov(rouletteCam, 80.0)
            DoScreenFadeIn(200)
        elseif cameraMode == 3 then
            DoScreenFadeOut(200)
            while not IsScreenFadedOut() do
                Citizen.Wait(1)
            end
            cameraMode = 4
            local camOffset = GetWorldPositionOfEntityBone(Table[scrollerIndex], GetEntityBoneIndexByName(Table[scrollerIndex], 'Roulette_Wheel'))
            local rot = vector3(270.0, -90.0, Config.Tables[scrollerIndex].rot + 270.0)
            SetCamCoord(rouletteCam, camOffset + vector3(0.0, 0.0, 0.5))
            SetCamRot(rouletteCam, rot, 2)
            StopCamShaking(rouletteCam, false)
            SetCamFov(rouletteCam, 80.0)
            DoScreenFadeIn(200)
        elseif cameraMode == 4 then
            DoScreenFadeOut(200)
            while not IsScreenFadedOut() do
                Citizen.Wait(1)
            end
            cameraMode = 1
            local rot = vector3(270.0, -90.0, Config.Tables[scrollerIndex].rot + 270.0)
            SetCamCoord(rouletteCam, Config.Tables[scrollerIndex].coords + vector3(0.0, 0.0, 2.0))
            SetCamRot(rouletteCam, rot, 2)
            SetCamFov(rouletteCam, 80.0)
            StopCamShaking(rouletteCam, false)
            DoScreenFadeIn(200)
        end
    end
end

function s2m(s)
    if s <= 0 then
        return "00:00"
    else
        local m = string.format("%02.f", math.floor(s/60))
        return m..":"..string.format("%02.f", math.floor(s - m * 60))
    end
end

function findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < -180 and t + 180 or t
end

function DisplayHelpText(helpText, time)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringWebsite(helpText)
	EndTextCommandDisplayHelp(0, 0, 1, time or -1)
end

function IsSeatOccupied(coords, radius)
	local players = GetActivePlayers()
	local playerId = PlayerId()
	for i = 1, #players do
		if players[i] ~= playerId then
			local ped = GetPlayerPed(players[i])
			if IsEntityAtCoord(ped, coords, radius, radius, radius, 0, 0, 0) then
				return true
			end
		end
	end

	return false
end

function SetSatDownCallback(cb)
	satDownCallback = cb
end

function SetStandUpCallback(cb)
	standUpCallback = cb
end

function SetLeaveCheckCallback(cb)
	leaveCheckCallback = cb
end

function SetCanSitDownCallback(cb)
	canSitDownCallback = cb
end

function getBetObjectType(betAmount)
    if betAmount < 10 then
        return GetHashKey('vw_prop_chip_10dollar_x1')
    elseif betAmount >= 10 and betAmount < 50 then
        return GetHashKey('vw_prop_chip_10dollar_x1')
    elseif betAmount >= 50 and betAmount < 100 then
        return GetHashKey('vw_prop_chip_50dollar_x1')
    elseif betAmount >= 100 and betAmount < 500 then
        return GetHashKey('vw_prop_chip_100dollar_x1')
    elseif betAmount >= 500 and betAmount < 1000 then
        return GetHashKey('vw_prop_chip_500dollar_x1')
    elseif betAmount >= 1000 and betAmount < 5000 then
        return GetHashKey('vw_prop_chip_1kdollar_x1')
    elseif betAmount >= 5000  and betAmount < 10000 then
        return GetHashKey('vw_prop_chip_5kdollar_x1')
    elseif betAmount >= 10000  and betAmount < 50000 then
        return GetHashKey('vw_prop_chip_10kdollar_x1')
    elseif betAmount >= 50000 and betAmount < 100000 then
        return GetHashKey('vw_prop_chip_5kdollar_st')
    elseif betAmount >= 100000 and betAmount <= 500000 then
        return GetHashKey('vw_prop_chip_10kdollar_st')
    else -- this should never happen, but yeah.
        return GetHashKey('vw_prop_plaq_10kdollar_x1')
    end
-- 10  vw_prop_chip_10dollar_x1
-- 50  vw_prop_chip_50dollar_x1
-- 100 vw_prop_chip_100dollar_x1
-- 120 vw_prop_chip_10dollar_st
-- 500 vw_prop_chip_500dollar_x1
-- 600 vw_prop_chip_50dollar_st
-- 1k vw_prop_chip_1kdollar_x1
-- 1.2k vw_prop_chip_100dollar_st

-- 5k vw_prop_chip_5kdollar_x1
-- 6k vw_prop_chip_500dollar_st
-- 10k vw_prop_chip_10kdollar_x1
-- 12k vw_prop_chip_1kdollar_st
-- 60k vw_prop_chip_5kdollar_st
-- 120k vw_prop_chip_10kdollar_st
-- Stacks: vw_prop_vw_chips_pile_01a   vw_prop_vw_chips_pile_02a   vw_prop_vw_chips_pile_03a
end

Citizen.CreateThread(function()

	if IsModelInCdimage(`vw_prop_casino_roulette_01`) and IsModelInCdimage(`s_f_y_casino_01`) and IsModelInCdimage(`vw_prop_chip_10dollar_x1`) then
		Citizen.CreateThread(ProcessTables)
		-- Citizen.CreateThread(CreatePeds)
	else
		ThefeedSetAnimpostfxColor(255, 0, 0, 255)
		Notification("This server is missing objects required for Roulette!", nil, true)
	end
end)

RegisterNetEvent('ROULETTE:startSpin')
AddEventHandler('ROULETTE:startSpin', function(RouletteTable, tickRate)
        if tables[RouletteTable] ~= nil then
            tables[RouletteTable].tickRate = tickRate
            spinWheel(RouletteTable, tickRate)
        end
    end
)

RegisterNetEvent("ROULETTE:playDealerSpeech")
AddEventHandler("ROULETTE:playDealerSpeech", function(tableID, speech)
	if inZone then
		Citizen.CreateThread(function()
			StopCurrentPlayingAmbientSpeech(dealer[tableID])
			PlayAmbientSpeech1(dealer[tableID], speech, "SPEECH_PARAMS_FORCE_NORMAL_CLEAR")
		end)
	end
end)


RegisterNetEvent('ROULETTE:updateTableBets')
AddEventHandler('ROULETTE:updateTableBets',function(RouletteTable, bets)
        if tables[RouletteTable] ~= nil then
            tables[RouletteTable].bets = bets
            createBetObjects(bets)
        end
    end
)

RegisterNetEvent('ROULETTE:updateStatus')
AddEventHandler('ROULETTE:updateStatus', function(RouletteTable, ido, status)
        if tables[RouletteTable] ~= nil then
            tables[RouletteTable].ido = ido
            tables[RouletteTable].status = status
        end
end)

RegisterNetEvent('ROULETTE:createTable')
AddEventHandler('ROULETTE:createTable', function(RouletteTable)
        if tables[RouletteTable] == nil then
            tables[RouletteTable] = {ido = Config.RouletteStart, status = false, tickrate = 0, bets = {}}
        end
end)

RegisterNetEvent('showNotification')
AddEventHandler('showNotification',function(msg)
        ESX.ShowNotification(msg)
        print(msg)
end)

function loadTableData(tableObject, tableID)
    DebugPrint('Creating Table Data..')
    numbersData[tableID] = {}
    betData[tableID] = {}
    local e = 1
    for i = 0, 11, 1 do
        for j = 0, 2, 1 do
            table.insert(
                numbersData[tableID],
                {
                    name = e + 1,
                    hoverPos = GetOffsetFromEntityInWorldCoords(tableObject, (0.081 * i) - 0.057, (0.167 * j) - 0.192, 0.9448),
                    hoverObject = 'vw_prop_vw_marker_02a'
                }
            )
            local offset = nil
            if j == 0 then
                offset = 0.155
            elseif j == 1 then
                offset = 0.171
            elseif j == 2 then
                offset = 0.192
            end

            table.insert(
                betData[tableID],
                {
                    betId = e,
                    name = e + 1,
                    pos = GetOffsetFromEntityInWorldCoords(tableObject, (0.081 * i) - 0.057, (0.167 * j) - 0.192, 0.9448),
                    objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.081 * i - 0.057, 0.167 * j - 0.192, 0.9448),
                    hoverNumbers = {e}
                }
            )

            e = e + 1
        end
    end
    table.insert(
        numbersData[tableID],
        {
            name = 'Zero',
            hoverPos = GetOffsetFromEntityInWorldCoords(tableObject, -0.137, -0.148, 0.9448),
            hoverObject = 'vw_prop_vw_marker_01a'
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = 'Zero',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, -0.137, -0.148, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, -0.137, -0.148, 0.9448),
            hoverNumbers = {#numbersData[tableID]}
        }
    )
    table.insert(
        numbersData[tableID],
        {
            name = 'Double Zero',
            hoverPos = GetOffsetFromEntityInWorldCoords(tableObject, -0.133, 0.107, 0.9448),
            hoverObject = 'vw_prop_vw_marker_01a'
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = 'Double Zero',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, -0.133, 0.107, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, -0.133, 0.107, 0.9448),
            hoverNumbers = {#numbersData[tableID]}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = 'RED',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.3, -0.4, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.3, -0.4, 0.9448),
            hoverNumbers = {1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = 'BLACK',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.5, -0.4, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.5, -0.4, 0.9448),
            hoverNumbers = {0, 2, 4, 6, 8, 9, 11, 13, 15, 18, 20, 22, 24, 26, 27, 29, 31, 33, 35}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = 'EVEN',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.15, -0.4, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.15, -0.4, 0.9448),
            hoverNumbers = {2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = 'ODD',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.65, -0.4, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.65, -0.4, 0.9448),
            hoverNumbers = {1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = '1to18',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, -0.02, -0.4, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, -0.02, -0.4, 0.9448),
            hoverNumbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = '19to36',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.78, -0.4, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.78, -0.4, 0.9448),
            hoverNumbers = {19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = '1st 12',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.05, -0.3, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.05, -0.3, 0.9448),
            hoverNumbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = '2nd 12',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.4, -0.3, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.4, -0.3, 0.9448),
            hoverNumbers = {13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = '3rd 12',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.75, -0.3, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.75, -0.3, 0.9448),
            hoverNumbers = {25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = '2to1',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.91, -0.15, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.91, -0.15, 0.9448),
            hoverNumbers = {1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = '2to1',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.91, 0.0, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.91, 0.0, 0.9448),
            hoverNumbers = {2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35}
        }
    )
    table.insert(
        betData[tableID],
        {
            betId = #betData[tableID],
            name = '2to1',
            pos = GetOffsetFromEntityInWorldCoords(tableObject, 0.91, 0.15, 0.9448),
            objectPos = GetOffsetFromEntityInWorldCoords(tableObject, 0.91, 0.15, 0.9448),
            hoverNumbers = {3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36}
        }
    )

    DebugPrint('Successfully created table data,,')
end