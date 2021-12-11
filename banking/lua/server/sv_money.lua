TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('qb-banking:server:Deposit')
AddEventHandler('qb-banking:server:Deposit', function(account, amount, note, fSteamID)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    if not Player or Player == -1 then
        return
    end
    amount = tonumber(amount)
    local deposit = math.floor(amount)

    if not deposit or deposit <= 0 then
        TriggerClientEvent("qb-banking:client:Notify", src, "error", "Invalid amount!") 
        return
    end

    if deposit > Player.getMoney() then
        TriggerClientEvent("qb-banking:client:Notify", src, "error", "You can't afford this!") 
        return
    end

    local account = MySQL.Sync.fetchAll('SELECT * FROM society WHERE id= @id', {['@id'] = account})
    account = account[1]
        if account.type == 'personal' then
            Player.removeMoney(deposit)
            Player.addAccountMoney('bank', deposit)
        else
            MySQL.Async.execute("UPDATE society SET money = money + @amount WHERE id = @id", {
                ['@amount'] = deposit, 
                ['@id'] = account.id
            })
            Player.removeMoney(deposit)
        end
        RefreshTransactions()
        TriggerEvent("qb-banking:server:AddToMoneyLog", src, account.id, account.type, amount, "deposit", "Deposit", (note or ""))
end)


RegisterServerEvent('qb-banking:server:Withdraw')
AddEventHandler('qb-banking:server:Withdraw', function(account, amount, note, fSteamID)
    local src = source
    if not src then return end
    local Player = ESX.GetPlayerFromId(src)

    if not Player or Player == -1 then
        return
    end

    if not amount or tonumber(amount) <= 0 then
        TriggerClientEvent("qb-banking:client:Notify", src, "error", "Invalid amount!") 
        return
    end

    amount = tonumber(amount)

    local account = MySQL.Sync.fetchAll('SELECT * FROM society WHERE id= @id', {['@id'] = account})
    account = account[1]
    if account.money > amount then
        local withdraw = math.floor(amount)
        if account.type == 'personal' then
            Player.addMoney(withdraw)
            Player.removeAccountMoney('bank', withdraw)
        else
            MySQL.Async.execute("UPDATE society SET money = money - @amount WHERE id = @id", {
                ['@amount'] = withdraw, 
                ['@id'] = account.id
            })
            Player.addMoney(withdraw)
        end
        TriggerEvent("qb-banking:server:AddToMoneyLog", src, account.id, account.type, -amount, "withdraw", "Withdrawal", (note or ""))
        RefreshTransactions()
    else
        TriggerClientEvent("qb-banking:client:Notify", src, "error", "You can't afford this!") 
    end
end)

pullTypes = {
    organisation = 'Jobs',
    business = 'Businesses'
}

RegisterServerEvent('qb-banking:server:Transfer')
AddEventHandler('qb-banking:server:Transfer', function(target, account, amount, note, fSteamID) -- Target = target bank id - account = leaving bank id
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    target = target ~= nil and tonumber(target) or nil
    if not target or target <= 0  then 
        return
    end

    target = tonumber(target)
    amount = tonumber(amount)
    
    if (not amount or amount <= 0) then
        return
    end
--[[ 
        if checkPermission then
            if (not SimpleBanking.Config["business_ranks"][string.lower(senderInfo.grade.name)] and not SimpleBanking.Config["business_ranks_overrides"][string.lower(senderInfo.name)]) then
                return
            end

            local low = string.lower(senderInfo.name)
            local grade = string.lower(senderInfo.grade.name)

            if (SimpleBanking.Config["business_ranks_overrides"][low] and not SimpleBanking.Config["business_ranks_overrides"][low][grade]) then
                return
            end
        end ]]

        local sender = MySQL.Sync.fetchAll('SELECT * FROM society WHERE id= @id', {['@id'] = account})
        local receiver = MySQL.Sync.fetchAll('SELECT * FROM society WHERE id= @id', {['@id'] = target})
        local sender = sender[1]
        local receiver = receiver[1]
        if sender and receiver then
            if sender.money > amount then
                MySQL.Async.transaction({
                    "UPDATE society SET money = money - @amount WHERE id = @fromid",
                    "UPDATE society SET money = money + @amount WHERE id = @toid"
                }, {
                    ['@amount'] = amount, 
                    ['@fromid'] = sender.id,
                    ['@toid'] = receiver.id
                }, function(success)
                    if success then
                        if sender.type == 'personal' then
                            Player.removeAccountMoney('bank', amount)
                            sender.label = Player.getName()
                        else
                            sender.label = ESX[pullTypes[sender.type]][sender.name].label
                        end
                        if receiver.type == 'personal' then
                            receiverData = ESX.GetPlayerFromIdentifier(receiver.name)
                            receiverData.addAccountMoney('bank', amount)
                            receiver.label = receiverData.getName()
                        else
                            receiver.label = ESX[pullTypes[receiver.type]][receiver.name].label
                        end            

                        --                                             User   account      type       money             Transaction Name
                        TriggerEvent("qb-banking:server:AddToMoneyLog", src, sender.id, sender.type, -amount, "transfer", receiver.label, (note or ""))
                        TriggerEvent("qb-banking:server:AddToMoneyLog", src, receiver.id, receiver.type, amount, "transfer", sender.label, (note or ""))
                    end
                end)
            else      
                TriggerClientEvent("qb-banking:client:Notify", src, "error", "You can't afford this!") 
            end
        end
end)