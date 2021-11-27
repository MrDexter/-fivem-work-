--[[ 
    es_extended > server > main.lua line 64 for accounts
    es_extended > server > function.lua > line 167 save data 
 ]]
while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) end
Accounts = {}
--businesses = {morrisonsltd = {name = 'morrisonsltd', label = 'Morrisons Ltd', grade = {name = 'Chief Executive'}}, luxuryautoshop = {name = 'luxuryautoshop', label = 'Luxury Auto Shop', grade = {name = 'Chief Executive'}}, minotaurfinance = {name = 'minotaurfinance', label = 'Minotaur Finance', grade = {name = 'Chief Executive'}}, diamondcasino = {name = 'diamondcasino', label = 'Diamond Casino', grade = {name = 'Chief Executive'}}}
--"luxuryautoshop":{"name":"luxuryautoshop","grade_salary":0,"id":2,"label":"Luxuty Auto Shop","grade_label":"Chief","grade_permissions":"[]","grade":2},
--"morrisonsltd":{"name":"morrisonsltd","grade_salary":50000,"id":1,"label":"Morrisons Ltd","grade_label":"Chief Executive","grade_permissions":"[\"business_mng_promote\",\"business_fnc_safe_withdraw\",\"business_mng_admin\",\"business_mng_invite\",\"business_mng_kick\",\"business_fnc_clothing\",\"business_fnc_safe\",\"business_fnc_safe_deposit\",\"business_fnc_phone\",\"business_mng_demote\"]","grade":5}}
pullTypes = {
    organisation = 'Jobs',
    business = 'Businesses'
}

MySQL.ready(function ()
	local pulledAccounts = MySQL.Sync.fetchAll('SELECT * FROM society', {})
    for k,v in ipairs(pulledAccounts) do
        -- if v.type == 'personal' then
        --     local xPlayer = ESX.GetPlayerFromIdentifier('steam:11000010f170a89')
        --     v.name = xPlayer.getName()
        -- end
        Accounts[v.id] = v
    end
end)

ESX.RegisterServerCallback("qb-banking:server:GetBankData", function(source, cb)
    local src = source
    if not src then return end

    local Player = ESX.GetPlayerFromId(src)

    print(json.encode(Player.getBusinesses()))

    if not Player then return end

    local playerName = Player.getName()
    local PlayerMoney = Player.getAccount('bank').money or 0 
    local accountNum = Player.getAccount('bank').id
    local playerID = Player.getIdentifier()

    local TransactionHistory = {}
    local TransactionRan = false
    local tbl = {}
    tbl[1] = {
        type = "personal",
        amount = PlayerMoney,
        id = accountNum
    }

    local job = Player.getJob()

    if (job.name and job.grade_name) then
        if(SimpleBanking.Config["business_ranks"][string.lower(job.grade_name)] or SimpleBanking.Config["business_ranks_overrides"][string.lower(job.name)] and SimpleBanking.Config["business_ranks_overrides"][string.lower(job.name)][string.lower(job.grade_name)]) then
            
            MySQL.Async.fetchAll('SELECT * FROM society WHERE name= @name', {['@name'] = job.name}, function(result)
            
                local data = result[1]

                if data ~= nil then
                    tbl[#tbl + 1] = {
                        type = "organisation",
                        name = job.label,
                        amount = format_int(data.money) or 0,
                        id = data.id
                    }
                end
            end)
        end
    end

    local gang = {}

    if (gang.name and gang.grade.name) then
        if(SimpleBanking.Config["business_ranks"][string.lower(gang.grade.name)] or SimpleBanking.Config["business_ranks_overrides"][string.lower(gang.name)] and SimpleBanking.Config["business_ranks_overrides"][string.lower(gang.name)][string.lower(gang.grade.name)]) then

            MySQL.Async.fetchAll('SELECT * FROM society WHERE name= @name', {
                ['@name'] = gang.name
            }, function(result)
                local data = result[1]
                if data ~= nil then
                    tbl[#tbl + 1] = {
                        type = "gang",
                        name = gang.label,
                        amount = format_int(data.money) or 0,
                        id = data.id
                    }
                end
            end)

        end
    end

    local businesses = Player.getBusinesses()
    if businesses ~= nil then
        for k,v in pairs(businesses) do
            if isinTable('business_mng_admin', json.decode(v.grade_permissions)) then
                MySQL.Async.fetchAll('SELECT * FROM society WHERE name= @name', {
                    ['@name'] = v.name
                }, function(result)
                    local data = result[1]
                    if data ~= nil then
                        tbl[#tbl + 1] = {
                            type = "business",
                            name = v.label,
                            amount = format_int(data.money) or 0,
                            id = data.id
                        }
                    end
                end)
            end
        end
    end

    local accountIDs = {'1', '3', '4', '5', '7',  '8'}
    MySQL.Async.fetchAll("SELECT * FROM `transaction_history` WHERE `sender` IN(@IDs) AND DATE(date) > (NOW() - INTERVAL "..SimpleBanking.Config["Days_Transaction_History"].." DAY) ORDER BY `id` ASC;", {
        ["@IDs"] = accountIDs,
    }, function(data)
        local complete = {}
        for k,v in pairs(data) do
            if v ~= nil then
                data[k].account_name = ''
                if v.trans_type == 'transfer' then
                    senderTable = isinTable(v.sender, accountIDs)
                    v.sender = tonumber(v.sender)
                    v.receiver = tonumber(v.receiver)
                    currentSender = Accounts[v.sender]
                    currentReceiver = Accounts[v.receiver]
                    if (senderTable and not isinTable(v.id, complete)) then -- Sender Side
                        if currentSender.type == 'personal' then
                            local xPlayer = ESX.GetPlayerFromIdentifier(currentSender.name)
                            data[k].trans_name = xPlayer.getName()
                        else
                            data[k].trans_name = ESX[pullTypes[currentReceiver.type]][currentReceiver.name].label
                            data[k].account_name = " - " .. ESX[pullTypes[currentSender.type]][currentSender.name].label
                        end
                        table.insert(complete, v.id)
                    else -- Receiver
                        if currentReceiver.type == 'personal' then
                            local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
                            data[k].trans_name = xPlayer.getName()
                        else
                            data[k].trans_name = ESX[pullTypes[currentSender.type]][currentSender.name].label
                            data[k].account_name = " - " .. ESX[pullTypes[currentReceiver.type]][currentReceiver.name].label
                        end
                    end
                else
                    local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
                    data[k].trans_name = xPlayer.getName()
                end
            end
        end
        TransactionRan = true
        TransactionHistory = data
    end)

    repeat Wait(0) until TransactionRan
    cb(tbl, TransactionHistory, playerName)
end)

function RefreshTransactions(source)
    local src = source
    if not src then return end

    local Player = ESX.GetPlayerFromId(src)
    PlayerName = Player.getName()

    if not Player then return end

    local accountIDs = {'1', '3', '4', '5', '7',  '8'}
    MySQL.Async.fetchAll("SELECT * FROM `transaction_history` WHERE `sender` IN(@IDs) AND DATE(date) > (NOW() - INTERVAL "..SimpleBanking.Config["Days_Transaction_History"].." DAY) ORDER BY `id` ASC;", {
        ["@IDs"] = accountIDs,
    }, function(data)
        MySQL.Async.fetchAll("SELECT * FROM `transaction_history` WHERE `receiver` IN(@IDs) AND DATE(date) > (NOW() - INTERVAL "..SimpleBanking.Config["Days_Transaction_History"].." DAY) ORDER BY `id` ASC;", {
            ["@IDs"] = accountIDs,
        }, function(data2)
            for i=1, #data2, 1 do
                table.insert(data, data2[i])
            end
            local complete = {}
            for k,v in pairs(data) do
                if v ~= nil then
                    if v.trans_type == 'transfer' then
                        local senderInTable = isinTable(v.sender, accountIDs)
                        local receiverInTable = isinTable(v.receiver, accountIDs)
                        v.sender = tonumber(v.sender)
                        v.receiver = tonumber(v.receiver)
                        if (senderInTable and receiverInTable and not isinTable(v.id, complete)) or (senderInTable and not receiverInTable)  then -- Sender Side
                            if Accounts[v.receiver].type == 'organisation' then
                                data[k].trans_name = ESX.Jobs[Accounts[v.receiver].name].label
                            elseif Accounts[v.receiver].type == 'business' then
                                data[k].trans_name = businesses[Accounts[v.receiver].name].label
                            elseif Accounts[v.receiver].type == 'personal' then
                                local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
                                data[k].trans_name = xPlayer.getName()
                            else
                                data[k].trans_name = ''
                            end
                            table.insert(complete, v.id)
                            v.amount = v.amount*-1
                        else -- Receiver Side
                            if Accounts[v.sender].type == 'organisation' then
                                data[k].trans_name = ESX.Jobs[Accounts[v.sender].name].label
                            elseif Accounts[v.sender].type == 'business' then
                                data[k].trans_name = businesses[Accounts[v.sender].name].label
                            elseif Accounts[v.sender].type == 'personal' then
                                local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
                                data[k].trans_name = xPlayer.getName()
                            else
                                data[k].trans_name = ''
                            end
                        end
                    else
                        local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
                        data[k].trans_name = xPlayer.getName()
                    end
                end
            end
            TransactionRan = true
            TransactionHistory = data
        end)
    end)

end

RegisterNetEvent("qb-banking:server:AddToMoneyLog")
AddEventHandler("qb-banking:server:AddToMoneyLog", function(source, sAccount, iAmount, sType, sender, receiver, sMessage, cb)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local CitizenId = Player.getIdentifier()

    local iTransactionID = math.random(1000, 100000)

    MySQL.Async.execute("INSERT INTO `transaction_history` (`identifier`, `trans_id`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`) VALUES(@id, @tranid, @account, @amount, @type, @sender, @receiver, @message)", {
        ['id'] = CitizenId,
        ['tranid'] = iTransactionID,
        ['account'] = sAccount,
        ['amount'] = iAmount,
        ['type'] = sType,
        ['sender'] = sender,
        ['receiver'] = receiver,
        ['message'] = sMessage
    }, function()
        RefreshTransactions(src)
    end)
end)


function isinTable(string, Table)
	if Table ~= nil then
		if string ~= nil then
				for k, v in pairs (Table) do
					if v == string then
                        -- print('found')
						return true -- found
					end
				end
                -- print('Not found')
				return false -- fallthrough the loo
		else
            -- print('no string')
			return false -- No string
		end
	else
        -- print('no table')
		return false -- No table
	end
end