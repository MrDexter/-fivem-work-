--[[ 
    es_extended > server > main.lua line 64 for accounts
    es_extended > server > function.lua > line 167 save data 
    es_extended > server > common.lua > line 84 Adding .bankaccoun to ESX table
 ]]
ESX = nil

while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) end
Accounts = {}
--businesses = {morrisonsltd = {name = 'morrisonsltd', label = 'Morrisons Ltd', grade = {name = 'Chief Executive'}}, luxuryautoshop = {name = 'luxuryautoshop', label = 'Luxury Auto Shop', grade = {name = 'Chief Executive'}}, minotaurfinance = {name = 'minotaurfinance', label = 'Minotaur Finance', grade = {name = 'Chief Executive'}}, diamondcasino = {name = 'diamondcasino', label = 'Diamond Casino', grade = {name = 'Chief Executive'}}}

pullTypes = {
    organisation = 'Jobs',
    business = 'Businesses'
}

MySQL.ready(function ()
	local pulledAccounts = MySQL.Sync.fetchAll('SELECT * FROM society', {})
    for k,v in ipairs(pulledAccounts) do
        Accounts[v.id] = v
    end
end)

ESX.RegisterServerCallback("qb-banking:server:GetBankData", function(source, cb)
    local accountIDs = {}   
    local src = source
    if not src then return end

    local Player = ESX.GetPlayerFromId(src)

    if not Player then return end

    local playerName = Player.getName()
    local PlayerMoney = Player.getAccount('bank').money or 0 
    local accountNum = Player.getAccount('bank').id
    table.insert(accountIDs, tostring(accountNum))

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
                    table.insert(accountIDs, tostring(data.id))
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
                    table.insert(accountIDs, tostring(data.id))
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
                        table.insert(accountIDs, tostring(data.id))
                    end
                end)
            end
        end
    end
    -- local accountIDs = {'1', '3', '4', '5', '7', '8'}
    MySQL.Async.fetchAll("SELECT * FROM `transaction_history` WHERE (`sender` IN(@IDs) OR `receiver` IN(@IDs)) AND DATE(date) > (NOW() - INTERVAL "..SimpleBanking.Config["Days_Transaction_History"].." DAY) ORDER BY `id` ASC;", {
        ["@IDs"] = accountIDs,
    }, function(data)
        local complete = {}
        for k,v in pairs(data) do
            if v ~= nil then
                data[k].account_name = ''
                if v.trans_type == 'transfer' then
                    senderTable = isinTable(v.sender, accountIDs)
                    receiverTable = isinTable(v.receiver, accountIDs)
                    v.sender = tonumber(v.sender)
                    v.receiver = tonumber(v.receiver)
                    currentSender = Accounts[v.sender]
                    currentReceiver = Accounts[v.receiver]
                    if (senderTable and not isinTable(v.id, complete)) then -- Sender Side
                        if currentReceiver.type == 'personal' then
                            local xPlayer = ESX.GetPlayerFromIdentifier(currentReceiver.name)
                            if xPlayer ~= nil then
                                data[k].trans_name = xPlayer.getName()
                            else
                                name = getOfflinePlayerName(currentReceiver.name)
                                data[k].trans_name = name
                            end
                        else
                            data[k].trans_name = ESX[pullTypes[currentReceiver.type]][currentReceiver.name].label
                        end
                        if currentSender.type ~= 'personal' then
                            data[k].account_name = " - " .. ESX[pullTypes[currentSender.type]][currentSender.name].label
                        end
                        table.insert(complete, v.id+1)
                    elseif receiverTable then -- Receiver
                        if currentSender.type == 'personal' then
                            local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
                            if xPlayer ~= nil then
                                data[k].trans_name = xPlayer.getName()
                            else
                                name = getOfflinePlayerName(currentReceiver.name)
                                data[k].trans_name = name
                            end
                        else
                            data[k].trans_name = ESX[pullTypes[currentSender.type]][currentSender.name].label
                        end
                        if currentReceiver.type ~= 'personal' then
                            data[k].account_name = " - " .. ESX[pullTypes[currentReceiver.type]][currentReceiver.name].label
                        end
                        v.id = v.id - 1
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
    if not Player then return end
    PlayerName = Player.getName()
    local accountIDs = {}
    local accountNum = Player.getAccount('bank').id -- Maybe implement accounts into ESX core, getAccount('morrisonsltd') / getAccounts for example
    table.insert(accountIDs, tostring(accountNum))
    local job = Player.getJob()
    if (job.name and job.grade_name) then
        if(SimpleBanking.Config["business_ranks"][string.lower(job.grade_name)] or SimpleBanking.Config["business_ranks_overrides"][string.lower(job.name)] and SimpleBanking.Config["business_ranks_overrides"][string.lower(job.name)][string.lower(job.grade_name)]) then
            local accountNum = ESX.Jobs[job.name].bankaccount
            print(json.encode(ESX.Jobs))
            table.insert(accountIDs, tostring(accountNum))
        end
    end
    local businesses = Player.getBusinesses()
    for k,v in pairs(businesses) do
        if isinTable('business_mng_admin', json.decode(v.grade_permissions)) then
            local accountNum = ESX.Businesses[v.name].bankaccount
            table.insert(accountIDs, tostring(accountNum))
        end
    end
    
    -- local accountIDs = {'1', '3', '4', '5', '7',  '8'}
    MySQL.Async.fetchAll("SELECT * FROM `transaction_history` WHERE (`sender` IN(@IDs) OR `receiver` IN(@IDs)) AND DATE(date) > (NOW() - INTERVAL "..SimpleBanking.Config["Days_Transaction_History"].." DAY) ORDER BY `id` ASC;", {
        ["@IDs"] = accountIDs,
    }, function(result)
        local complete = {}
        for k,v in pairs(result) do
            if v ~= nil then
                result[k].account_name = ''
                if v.trans_type == 'transfer' then
                    v.sender = tonumber(v.sender)
                    v.receiver = tonumber(v.receiver)
                    currentSender = Accounts[v.sender]
                    currentReceiver = Accounts[v.receiver]
                    if not isinTable(v.id, complete) then -- Sender Side
                        if currentReceiver.type == 'personal' then
                            local xPlayer = ESX.GetPlayerFromIdentifier(currentReceiver.name)
                            if xPlayer ~= nil then
                                result[k].trans_name = xPlayer.getName()
                            else
                                name = getOfflinePlayerName(currentReceiver.name)
                                result[k].trans_name = name
                            end
                        else
                            result[k].trans_name = ESX[pullTypes[currentReceiver.type]][currentReceiver.name].label
                        end
                        if currentSender.type ~= 'personal' then
                            result[k].account_name = " - " .. ESX[pullTypes[currentSender.type]][currentSender.name].label
                        end
                        table.insert(complete, v.id+1)
                    else -- Receiver
                        if currentSender.type == 'personal' then
                            local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
                            if xPlayer ~= nil then
                                result[k].trans_name = xPlayer.getName()
                            else
                                name = getOfflinePlayerName(currentReceiver.name)
                                result[k].trans_name = name
                            end
                        else
                            result[k].trans_name = ESX[pullTypes[currentSender.type]][currentSender.name].label
                        end
                        if currentReceiver.type ~= 'personal' then
                            result[k].account_name = " - " .. ESX[pullTypes[currentReceiver.type]][currentReceiver.name].label
                        end
                        v.id = v.id - 1
                    end
                else
                    local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
                    result[k].trans_name = xPlayer.getName()
                end
            end
        end
        TriggerClientEvent("qb-banking:client:UpdateTransactions", src, result)
    end)
end

RegisterNetEvent("qb-banking:server:AddToMoneyLog")
AddEventHandler("qb-banking:server:AddToMoneyLog", function(source, sAccount, iAmount, sType, sender, receiver, sMessage, cb)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local CitizenId = Player.getIdentifier()

        MySQL.Async.execute("INSERT INTO `transaction_history` (`identifier`, `account`, `amount`, `trans_type`, `sender`, `receiver`, `message`) VALUES(@id, @account, @amount, @type, @sender, @receiver, @message)", {
        ['id'] = CitizenId,
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

function getOfflinePlayerName(identifier)
    name = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
    
    return (name[1].firstname .. ' ' .. name[1].lastname)
end