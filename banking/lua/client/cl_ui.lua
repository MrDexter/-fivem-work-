bMenuOpen = false 
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local isLoggedIn = false
PlayerJob = {}
PlayerGang = {}
PlayerName = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	PlayerJob = playerData.job
    PlayerGang = "Not gang"
	isLoggedIn = true
    SendNUIMessage({type = "refresh_accounts"})
end)

-- RegisterNetEvent('QBCore:Client:OnPlayerUnload')
-- AddEventHandler('QBCore:Client:OnPlayerUnload', function()
-- 	isLoggedIn = false
-- 	PlayerJob = {}
--     SendNUIMessage({type = "refresh_accounts"})
-- end)

-- RegisterNetEvent('QBCore:Client:OnJobUpdate')
-- AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
-- 	PlayerJob = JobInfo
--     SendNUIMessage({type = "refresh_accounts"})
-- end)

-- RegisterNetEvent('QBCore:Client:OnGangUpdate')
-- AddEventHandler('QBCore:Client:OnGangUpdate', function(GangInfo)
--     PlayerGang = GangInfo
--     SendNUIMessage({type = "refresh_accounts"})
-- end)

RegisterCommand('openaccount', function()
    TriggerEvent('openAccount')
end)


RegisterNetEvent('openAccount')
AddEventHandler('openAccount', function()
    bMenuOpen = not bMenuOpen
    if not bMenuOpen then
        SetNuiFocus(false, false)
    else
        playerBusinesses = {}
        ply = PlayerPedId()
        plyCoords = GetEntityCoords(ply)
        Player = ESX.GetPlayerData()
        closePlayers = ESX.Game.GetPlayersInArea(plyCoords, 5.0)
        ESX.TriggerServerCallback("banking:openAccountCB", function(businessAccounts, nearbyPlayers)
            for k,v in pairs(Player.businesses) do
                if not isinTable(v.name, businessAccounts) then -- Account doesn't already exist
                    if isinTable('business_mng_admin', json.decode(v.grade_permissions)) then -- Permission to manage bank account
                        table.insert(playerBusinesses, {
                            name = v.label,
                            id = v.name
                        })
                    end
                end
            end
            
            SetNuiFocus(true, true)
            SendNUIMessage(({type = 'openNewAccount', players = nearbyPlayers, businesses = playerBusinesses}))
        end, closePlayers)
    end
end)

function ToggleUI()
    bMenuOpen = not bMenuOpen

    if (not bMenuOpen) then
        SetNuiFocus(false, false)
    else
        ESX.TriggerServerCallback("qb-banking:server:GetBankData", function(data, transactions, name)
            local PlayerBanks = json.encode(data)


            SetNuiFocus(true, true)
            SendNUIMessage({type = 'OpenUI', accounts = PlayerBanks, transactions = json.encode(transactions), name = name})
        end)
    end
end

RegisterNUICallback("CloseATM", function()
    ToggleUI()
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
end)

RegisterNUICallback("DepositCash", function(data, cb)
    if (not data or not data.account or not data.amount) then
        return
    end

    if (tonumber(data.amount) <= 0) then
        return
    end

    TriggerServerEvent("qb-banking:server:Deposit", data.account, data.amount, (data.note ~= nil and data.note or ""))
end)

RegisterNUICallback("WithdrawCash", function(data, cb)
    if (not data or not data.account or not data.amount) then
        return
    end

    if(tonumber(data.amount) <= 0) then
        return
    end

    TriggerServerEvent("qb-banking:server:Withdraw", data.account, data.amount, (data.note ~= nil and data.note or ""))
end)

RegisterNUICallback("TransferCash", function(data, cb)
    if (not data or not data.account or not data.amount or not data.target) then
        return
    end

    if(tonumber(data.amount) <= 0) then
        return
    end

    if(tonumber(data.target) <= 0) then
        return
    end

    TriggerServerEvent("qb-banking:server:Transfer", data.target, data.account, data.amount, (data.note ~= nil and data.note or ""))
end)


RegisterNUICallback("OpenAccount", function(data, cb)
    if (not data or not data.type or not data.secondaryOption) then
        return
    end

    TriggerServerEvent("banking:OpenAccount", data.type, data.secondaryOption)
    ToggleUI()
end)

RegisterNUICallback("manageAccess", function(data, cb)
    ESX.TriggerServerCallback("banking:manageAccess", function(currentSharers, PlayersTable)
        SendNUIMessage({type = "manage_access", currentPlayers = currentSharers, Players = PlayersTable, account_id = data.account_id})
    end, data.account_id, data.type)
end)

RegisterNUICallback("ChangeAccess", function(data, cb)
    print(json.encode(data))
    ESX.TriggerServerCallback('banking:ChangeAccess', function()
         
    end, data)
    cb(true)
end)

--// Net Events \\--
RegisterNetEvent("qb-banking:client:Notify")
AddEventHandler("qb-banking:client:Notify", function(type, msg)
    if (bMenuOpen) then
        SendNUIMessage({type = 'notification', msg_type = type, message = msg})
    end
end)

RegisterNetEvent("qb-banking:client:UpdateTransactions")
AddEventHandler("qb-banking:client:UpdateTransactions", function()
    if (bMenuOpen) then
        ESX.TriggerServerCallback("qb-banking:server:GetBankData", function(data, transactions, name)
            SendNUIMessage({type = "refresh_balances", accounts = json.encode(data)})
            SendNUIMessage({type = 'update_transactions', transactions = json.encode(transactions)})
        end)
    end
end)
