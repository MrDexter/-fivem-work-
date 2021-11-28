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

    MySQL.Async.fetchAll("SELECT * FROM society WHERE type <> 'personal'", {}, function(result)
        local Job = Player.getJob()
        -- local gang = Player.getGang()
        local playerBusinesses = Player.getBusinesses()

        for k,v in ipairs(result) do
            if v.type == 'organisation' then
                if (SimpleBanking.Config["business_ranks_overrides"][string.lower(Job.name)] and SimpleBanking.Config["business_ranks_overrides"][string.lower(Job.name)][string.lower(Job.grade_name)]) then
                    current = Job
                end
            elseif v.type == 'business' then
                if isinTable('business_mng_admin', json.decode(playerBusinesses[v.name].grade_permissions)) then
                    current = playerBusinesses[v.name]
                end
            else
                return
            end
            if current then
                tbl[#tbl + 1] = {
                    type = v.type,
                    name = current.label,
                    amount = format_int(v.money) or 0,
                    id = v.id
                }
                table.insert(accountIDs, tostring(v.id))
            end
        end
    end)


    -- local accountIDs = {'1', '3', '4', '5', '7', '8'}
    MySQL.Async.fetchAll("SELECT * FROM `transaction_history` WHERE (`sender` IN(@IDs) OR `receiver` IN(@IDs)) AND DATE(date) > (NOW() - INTERVAL "..SimpleBanking.Config["Days_Transaction_History"].." DAY) ORDER BY `id` ASC;", {
        ["@IDs"] = accountIDs,
    }, function(data)
        local complete = {}
        for k,v in pairs(data) do
            if v ~= nil then
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

function RefreshTransactions()
    TriggerClientEvent("qb-banking:client:UpdateTransactions")
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
        RefreshTransactions()
    end)
end)

function getOfflinePlayerName(identifier)
    name = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
    
    return (name[1].firstname .. ' ' .. name[1].lastname)
end




RegisterNetEvent('banking:OpenAccount')
AddEventHandler('banking:OpenAccount', function(type, secondaryOption)
    source = source
    xPlayer = ESX.GetPlayerFromId(source)
    playerBusinesses = xPlayer.getBusinesses()
    if type == 'shared' then
        print("shared")
    elseif type == 'business' then
        gradePermissions = json.decode(playerBusinesses[secondaryOption].grade_permissions)
        if isinTable('business_mng_admin', gradePermissions) then
            MySQL.Async.execute("INSERT INTO society (name, money, type) VALUES (@name, @money, @type)", {
                ['@name'] = secondaryOption,
                ['@money'] = 0,
                ['@type'] = type
            })
        end
    end
end)

ESX.RegisterServerCallback('banking:businessAccounts', function(source, cb)
    local businessAccounts = {}
    local pulledAccounts = MySQL.Sync.fetchAll("SELECT name FROM society where type = 'business'")
    for k,v in pairs(pulledAccounts) do
        table.insert(businessAccounts, v.name)
    end
    cb(businessAccounts)
end)