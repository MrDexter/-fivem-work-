ESX = nil

local currentjobs, currentbins, currentadd, currentworkers, bins = {}, {}, {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('esx_garbagecrew:bagdumped')
AddEventHandler('esx_garbagecrew:bagdumped', function(location, truckplate)
    local _source = source
    local updated = false
    if currentjobs[location] ~= nil then
        if currentjobs[location].trucknumber == truckplate then
            if  currentjobs[location].workers[_source] ~= nil then
                currentjobs[location].workers[_source] =  currentjobs[location].workers[_source] + 1
                currentjobs[location].bagsdropped = currentjobs[location].bagsdropped + 1
                updated = true
            end
            if not updated then
                if currentjobs[location].workers[_source] == nil then
                    currentjobs[location].workers[_source] = 1
                end
                currentjobs[location].bagsdropped = currentjobs[location].bagsdropped + 1
            end
            if currentjobs[location].binsremaining >= 2  then
                TriggerEvent('esx_garbagecrew:paycrew', currentjobs[location].pos)
            end
        end 
    end
end)

RegisterServerEvent('esx_garbagecrew:setworkers')
AddEventHandler('esx_garbagecrew:setworkers', function(location, trucknumber, truckid)
   local  _source = source
   if currentjobs[location] == nil then
    currentjobs[location] = {}
   end
   currentjobs[location] =  {name = 'bagcollection', jobboss = _source, pos = location, bagsdropped = 0, binsremaining = 0, trucknumber = trucknumber, truckid = truckid, workers = {}}
   TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs, currentbins)
end)


RegisterServerEvent('esx_garbagecrew:unknownlocation')
AddEventHandler('esx_garbagecrew:unknownlocation', function(location)
    if currentjobs[location] ~= nil then
        if #currentjobs[location].workers > 0 then
            TriggerEvent('esx_garbagecrew:paycrew',  currentjobs[location].pos)
        end
        currentjobs[location] = nil
        TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs, currentbins)
   end
end)

RegisterServerEvent('esx_garbagecrew:bagremoval')
AddEventHandler('esx_garbagecrew:bagremoval', function(location, bin)
    if currentjobs[location] ~= nil  then
        if  currentbins[bin] ~= nil then
            if currentbins[bin] == 1 then
                currentbins[bin] =  currentbins[bin] - 1
                currentjobs[location].binsremaining = currentjobs[location].binsremaining + 1
            else
                currentbins[bin] =  currentbins[bin] - 1
            end                
        else
            local bags = math.random(1, 3)
            currentbins[bin] = bags - 1
            if bags == 1 then
                currentjobs[location].binsremaining = currentjobs[location].binsremaining + 1
            end
        end
        TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs, currentbins)
    end
end)

RegisterServerEvent('esx_garbagecrew:movetruckcount')
AddEventHandler('esx_garbagecrew:movetruckcount', function()
    Config.TruckPlateNumb = Config.TruckPlateNumb + 1
    if Config.TruckPlateNumb == 1000 then
        Config.TruckPlateNumb = 1
    end
    TriggerClientEvent('esx_garbagecrew:movetruckcount', -1, Config.TruckPlateNumb)
end)

RegisterServerEvent('esx_garbagecrew:setconfig')
AddEventHandler('esx_garbagecrew:setconfig', function()
    TriggerClientEvent('esx_garbagecrew:movetruckcount', -1, Config.TruckPlateNumb)
    TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs, currentbins)
end)

RegisterServerEvent('esx_garbagecrew:resetbins')
AddEventHandler('esx_garbagecrew:resetbins', function(bins)
    for i, v in pairs(bins) do
        currentbins[v] = nil
     end
    TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs, currentbins)
end)

AddEventHandler('playerDropped', function()
    local removenumber = nil
    _source = source
     for i, v in pairs(currentjobs) do
        if v.jobboss == _source then
            TriggerEvent('esx_garbagecrew:paycrew', v.pos)
            removenumber = i
        end
        if v.workers[_source] ~= nil then
            v.workers[_source] = nil
        end
     end

     if removenumber ~= nil then
        currentjobs[removenumber] = nil
        TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs)
     end
end)

AddEventHandler('esx_garbagecrew:paycrew', function(number)
    print('request recieved to payout for stop: ' .. tostring(number))
    currentcrew = currentjobs[number].workers
    payamount = (Config.StopPay + (currentjobs[number].bagsdropped) * Config.BagPay)
    for i, v in pairs(currentcrew) do
        local xPlayer = ESX.GetPlayerFromId(i)
        if xPlayer ~= nil then
            local amount = math.ceil(payamount * v)
            xPlayer.addMoney(tonumber(amount))
            TriggerClientEvent('esx:showNotification',i, 'Received '..tostring(amount)..' from this stop!')
        end
    end
    local currentboss = currentjobs[number].jobboss
    currentjobs[number] = nil
    TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs)
    TriggerClientEvent('esx_garbagecrew:selectnextjob', currentboss )
end)
