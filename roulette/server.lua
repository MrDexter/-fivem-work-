local activeTables = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1000)

            for tableID, v in pairs(activeTables) do
                if v.status == false then
                    if v.ido > 0 then
                        activeTables[tableID].ido = v.ido - 1
                        TriggerClientEvent('ROULETTE:updateStatus', -1, tableID, v.ido, v.status)
                    end

                    if v.ido < 1 then
                        local randomSpinNumber = math.random(1, 38) -- Wheel number
                        local WinningBetIndex = Config.wheel[randomSpinNumber]

                        DebugPrint(string.format('Rulett randomSpinNumber: %s, which is number: %s', randomSpinNumber, WinningBetIndex))

                        activeTables[tableID].status = true
                        activeTables[tableID].WinningBetIndex = WinningBetIndex
                        TriggerClientEvent('ROULETTE:updateStatus', -1, tableID, v.ido, v.status)

                        Citizen.CreateThread(
                            function()
                                DebugPrint('time remaining 0, starting the spin events.')
                                TriggerClientEvent('ROULETTE:startSpin', -1, tableID, randomSpinNumber)
                                Citizen.Wait(15500)

                                if #v.bets > 0 then
                                    CheckWinners(v.bets, tableID)
                                    activeTables[tableID].status = false
                                    activeTables[tableID].ido = Config.RouletteStart
                                    activeTables[tableID].WinningBetIndex = nil
                                    activeTables[tableID].bets = {}
                                    TriggerClientEvent('ROULETTE:updateTableBets', -1, tableID, activeTables[tableID].bets)
                                else
                                    if countTablePlayers(tableID) < 1 then
                                        activeTables[tableID] = nil -- deleting the table from srv
                                        TriggerClientEvent('ROULETTE:updateStatus', -1, tableID, nil, nil)
                                        DebugPrint(string.format('Table: %s empty, table reset & stopped', tableID))
                                    else
                                        activeTables[tableID].status = false
                                        activeTables[tableID].ido = Config.RouletteStart
                                        activeTables[tableID].WinningBetIndex = nil
                                        activeTables[tableID].bets = {} -- reset the bets on the table, very importante
                                        TriggerClientEvent('client:rulett:updateTableBets', -1, tableID, activeTables[tableID].bets)
                                    end
                                end
                            end
                        )
                    end
                end
            end
        end
    end
)

function CheckWinners(bets, tableID)
    local playersWon = {}
    local playersLoss = {}
    WinningBetIndex = activeTables[tableID].WinningBetIndex

    for i = 1, #bets, 1 do
        local betData = bets[i]
        local targetSrc = betData.playerSrc
        if GetPlayerName(targetSrc) ~= nil then playerExist = true else playerExist = false end
        if playerExist then
            betData.betId = tostring(betData.betId)
            if (WinningBetIndex == '0' and betData.betId == '37') or (WinningBetIndex == '00' and betData.betId == '38') then -- Zeroes
                giveChips(targetSrc, math.floor(betData.betAmount*36)) -- Odds: 35 to 1
                playersWon[targetSrc] = true
                if playersLoss[targetSrc] then
                    playersWon[targetSrc] = nil
                end
            elseif
                (betData.betId == '39' and Roulette_Numbers.Red[WinningBetIndex]) or -- Colours, Odd, Even & Number Sets
                (betData.betId == '40' and Roulette_Numbers.Black[WinningBetIndex]) or
                (betData.betId == '41' and Roulette_Numbers.Even[WinningBetIndex]) or
                (betData.betId == '42' and Roulette_Numbers.Odd[WinningBetIndex]) or
                (betData.betId == '43' and Roulette_Numbers.to18[WinningBetIndex]) or
                (betData.betId == '44' and Roulette_Numbers.to36[WinningBetIndex])
             then
                giveChips(targetSrc, math.floor(betData.betAmount*2)) -- Odds: 1 to 1
                playersWon[targetSrc] = true
                if playersLoss[targetSrc] then
                    playersWon[targetSrc] = nil
                end
            elseif betData.betId <= '36' and WinningBetIndex == betData.betId then -- Single numbers
                giveChips(targetSrc, math.floor(betData.betAmount*36)) -- Odds: 35 to 1
                playersWon[targetSrc] = true
                if playersLoss[targetSrc] then
                    playersWon[targetSrc] = nil
                end
            elseif
                (betData.betId == '45' and Roulette_Numbers.st12[WinningBetIndex]) or -- Number sets
                (betData.betId == '46' and Roulette_Numbers.sn12[WinningBetIndex]) or
                (betData.betId == '47' and Roulette_Numbers.rd12[WinningBetIndex]) or
                (betData.betId == '48' and Roulette_Numbers.to_1[WinningBetIndex]) or
                (betData.betId == '49' and Roulette_Numbers.to_2[WinningBetIndex]) or
                (betData.betId == '50' and Roulette_Numbers.to_3[WinningBetIndex])
             then
                giveChips(targetSrc, math.floor(betData.betAmount*3)) -- Odds: 2 to 1 
                playersWon[targetSrc] = true

                if playersLoss[targetSrc] then
                    playersWon[targetSrc] = nil
                end
            else -- LOSS
                if playersWon[targetSrc] == nil then
                    playersLoss[targetSrc] = true
                else
                    playersLoss[targetSrc] = nil
                end
            end
        end
    end

    for targetSrc, _ in pairs(playersLoss) do
        local chairId = getTableChair(targetSrc, tableID)
        if chairId ~= nil then
            TriggerClientEvent('client:rulett:playWinAnim', targetSrc, chairId)
        end
    end

    for targetSrc, _ in pairs(playersWon) do
        local chairId = getTableChair(targetSrc, tableID)
        if chairId ~= nil then
            TriggerClientEvent('client:rulett:playLossAnim', targetSrc, chairId)
        end
    end
end


RegisterNetEvent("ROULETTE:PlayerSatDown")
AddEventHandler('ROULETTE:PlayerSatDown', function(tableID, chairId)
	DebugPrint("PLAYERSATDOWN: PLAYER ".. source .. " SAT DOWN AT TABLE " .. tableID)
	if activeTables[tableID] == nil then
		activeTables[tableID] = {
			status = false,
			ido = Config.RouletteStart,
			bets = {},
			chairsUsed = {}
		}
	end

		activeTables[tableID].chairsUsed[chairId] = source

    TriggerClientEvent('ROULETTE:playDealerSpeech', -1, tableID, "MINIGAME_DEALER_GREET")
    -- createClientTable(tableID)
    TriggerClientEvent('ROULETTE:createTable', -1, tableID)
	TriggerClientEvent("ROULETTE:RequestBets", source, tableID)

	-- DebugPrint("PLAYERSATDOWN: NUMBER OF PLAYERS AT TABLE ".. i .. " IS " .. #players[i])
end)

RegisterNetEvent('ROULETTE:NotAtTable')
AddEventHandler('ROULETTE:NotAtTable', function(tableID)
    local source = source
    if activeTables[tableID] ~= nil then
        for k, v in pairs(activeTables[tableID].chairsUsed) do
            if v == source then
                activeTables[tableID].chairsUsed[k] = nil
            end
        end
    end
end)


RegisterNetEvent('ROULETTE:placeBet')
AddEventHandler('ROULETTE:placeBet', function(tableID, betId, betAmount)
        local source = source
        if activeTables[tableID] ~= nil then
            if activeTables[tableID].status then
                return TriggerClientEvent('esx:showNotification', source, "The game started, you can not bet at the moment.")
            end

            local chipsAmount = checkChips(source)
            if chipsAmount >= betAmount then
                takeChips(source, betAmount)
                TriggerClientEvent('esx:showNotification', source, string.format("Placed a bet of %s chips", betAmount))

                DebugPrint(string.format('BET: %s ON %s BY PLAYER %s', betAmount, betId, GetPlayerName(source)))

                local exist = false
                for i = 1, #activeTables[tableID].bets, 1 do
                    local d = activeTables[tableID].bets[i]
                    if d.betId == betId and d.playerSrc == source then
                        exist = true
                        activeTables[tableID].bets[i].betAmount = activeTables[tableID].bets[i].betAmount + betAmount
                    end
                end

                if not exist then
                    table.insert(
                        activeTables[tableID].bets,
                        {
                            betId = betId,
                            playerSrc = source,
                            betAmount = betAmount
                        }
                    )
                end
                local chairId = getTableChair(source, tableID)
				print(chairId)
                if chairId ~= nil then
                    TriggerClientEvent('ROULETTE:playBetAnim', source, chairId)
                end
                Wait(1000)
                TriggerClientEvent('ROULETTE:updateTableBets', -1, tableID, activeTables[tableID].bets)
            else
                TriggerClientEvent('esx:showNotification', source, "You do not have enough chips to place bet.")
            end
        else -- the table not existing on the serverside? error
            TriggerClientEvent('esx:showNotification', source, "Error, Table not registed. Please try another or Notify a Staff / Dev")
        end
    end
)

function countTablePlayers(TableID)
    local count = 0
    if activeTables[TableID] ~= nil then
        for chairId, _ in pairs(activeTables[TableID].chairsUsed) do
            count = count + 1
        end

        return count
    else
        return count
    end
end

function getTableChair(source, tableID)
	for k, v in pairs(activeTables[tableID].chairsUsed) do
		if v == source then
			return k
		end
	end
end

function checkChips(source)
	local tokenCount = 0
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer ~= nil then
		local tokenItem = xPlayer.getInventoryItem('casino_chip')
		tokenCount = tokenItem.count
	end

	return tokenCount or 0
end

function takeChips(source, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local tokenItem = xPlayer.getInventoryItem('casino_chip')
	local tokenCount = tokenItem.count

	amount = math.tointeger(amount)

	if xPlayer ~= nil and tokenCount >= amount then
		DebugPrint("TAKECHIPS: TAKE FROM PLAYER "..source.." �"..amount)
		xPlayer.removeInventoryItem('casino_chip', amount)
	else
		DebugPrint("TAKECHIPS: PLAYER " .. source .. " ABSENT OR HASN'T ENOUGH CHIPS TO TAKE � " .. amount .." FROM")
	end
end

function giveChips(source, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	amount = math.tointeger(amount)

	if xPlayer ~= nil and amount > 0 then
		xPlayer.addInventoryItem('casino_chip', amount)
		TriggerClientEvent('esx:showNotification', source, "Additional: Chips: x".. amount)
		DebugPrint("GIVECHIPS: �".. amount .. " TO PLAYER " .. source)
	elseif amount < 0 then
		DebugPrint("GIVECHIPS: PLAYER " .. source .. " CANNOT BE GIVEN �"..amount.." - NEGATIVE AMOUNT!")
	elseif amount == 0 then
		DebugPrint("GIVECHIPS: PLAYER " .. source .. " CANNOT BE GIVEN �"..amount.." - ZERO AMOUNT!")
	else
		DebugPrint("GIVECHIPS: PLAYER " .. source .. " ABSENT! CAN'T GIVE THEM �"..amount.." CHIPS!")
	end
end

-- RegisterNetEvent('ROULETTE:createClientTable')
-- AddEventHandler('ROULETTE:createClientTable', 
function createClientTable(RouletteTable)
    TriggerClientEvent('ROULETTE:createTable', -1, RouletteTable)
end