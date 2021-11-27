local job_counts = {}
local currentCallers = {}


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- [[ OBJECT FUNCTIONS ]] --

function getGangFromId(id)
	id = tonumber(id)
	return RPUK_GANGS[id]
end

function tableLength(table)
	local count = 0
	for _ in pairs(table) do count = count + 1 end
	return count
  end

function isinTable(string, Table)
	if Table ~= nil then
		if string ~= nil then
				for k, v in pairs (Table) do
					if v == string then
						return true -- found the permission
					end
				end
				return false -- fallthrough the loo
		else
			return false -- No string
		end
	else
		return false -- No table
	end
end

-- [[ STANDARD FUNCTIONS ]] --

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

ESX.RegisterServerCallback('rpuk_gangs:hasPermission', function(source, cb, permission_string)
	local xPlayer = ESX.GetPlayerFromId(source)
	local gang_id, gang_rank = xPlayer.getGang()
	local xGang = getGangFromId(gang_id)
	if xGang and xPlayer then
		local result = xGang.hasPermission(gang_rank, permission_string)
		cb(result)
	else
		cb(false)
	end
end)


RegisterNetEvent('rpuk_gangs:openStorage')
AddEventHandler("rpuk_gangs:openStorage", function(gang_id)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xGang = getGangFromId(tonumber(gang_id))
	TriggerClientEvent("rpuk_inventory:openSecondaryInventory", source, xGang.formatForSecondInventory())
end)

ESX.RegisterServerCallback('rpuk_gangs:putItem', function(playerId, cb, type, name, amount, data, itemData)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local gang_id = data.id
	local xGang = getGangFromId(tonumber(gang_id))
	local cbResult = false
	local gm_id, gm_rank = xPlayer.getGang()

	if not currentCallers[playerId] then
		currentCallers[playerId] = true

		if xGang.hasPermission(gm_rank, "gang_fnc_safe_deposit") then
			if type == "item_standard" then
				local item = xPlayer.getInventoryItem(name)

				if item.count >= amount then
					local success, message = xGang.addItem(name, amount)

					if success then
						xPlayer.showNotification(message, 2500, 'inform', 'longnotif')
						xPlayer.removeInventoryItem(name, amount)
						cbResult = true
					else
						xPlayer.showNotification(message, 2500, 'error', 'longnotif')
					end
				else
					xPlayer.showNotification('Not enough of selected item in inventory', 2500, 'error', 'longnotif')
				end
			elseif type == "item_weapon" then
				if xPlayer.hasWeapon(name) then
					local success, message = xGang.addWeapon(name, 1, xPlayer.getWeapon(name).components)

					if success then
						xPlayer.showNotification(message, 2500, 'inform', 'longnotif')
						xPlayer.removeWeapon(name)
						cbResult = true
					else
						xPlayer.showNotification(message, 2500, 'error', 'longnotif')
					end
				else
					xPlayer.showNotification('You do not have this weapon on you', 2500, 'inform', 'longnotif')
				end
			elseif type == "item_ammo" then
				local ammo = xPlayer.getAmmo()[name]

				if ammo.count >= amount then
					local success, message = xGang.addAmmo(name, amount)

					if success then
						xPlayer.showNotification(message, 2500, 'inform', 'longnotif')
						xPlayer.removeWeaponAmmo(name, amount)
						cbResult = true
					else
						xPlayer.showNotification(message, 2500, 'error', 'longnotif')
					end
				else
					xPlayer.showNotification('You dont have enough of ammo type', 2500, 'error', 'longnotif')
				end
			elseif type == "item_account" then
				local money = xPlayer.getAccount(name).money

				if money >= amount then
					local success, message = xGang.addAccountMoney(name, amount)

					if success then
						xPlayer.showNotification(message, 2500, 'inform', 'longnotif')
						xPlayer.removeAccountMoney(name, amount, ('%s [%s]'):format('House Storage', GetCurrentResourceName()))
						cbResult = true
					else
						xPlayer.showNotification(message, 2500, 'error', 'longnotif')
					end
				else
					xPlayer.showNotification('You do not have enough dirty money', 2500, 'error', 'longnotif')
				end
			end
		else
			xPlayer.showNotification('You do not have permission to deposit into the storage', 2500, 'error', 'longnotif')
		end
	end

	if cbResult then
		xPlayer.triggerEvent("rpuk_inventory:refreshSecondaryInventory", xGang.formatForSecondInventory())
	end

	currentCallers[playerId] = nil
	cb(cbResult)
end)

ESX.RegisterServerCallback('rpuk_gangs:getItem', function(playerId, cb, itemType, name, amount, data, itemData)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local gang_id = data.id
	local xGang = getGangFromId(tonumber(gang_id))
	local cbResult = false
	local gm_id, gm_rank = xPlayer.getGang()

	if not currentCallers[playerId] then
		currentCallers[playerId] = true

		if xGang.hasPermission(gm_rank, "gang_fnc_safe_withdraw") then
			if itemType == "item_standard" then
				if xPlayer.canCarryItem(name, amount) then
					local success, message = xGang.removeItem(name, amount)

					if success then
						xPlayer.showNotification(message, 2500, 'inform', 'longnotif')
						xPlayer.addInventoryItem(name, amount)
						cbResult = true
					else
						xPlayer.showNotification(message, 2500, 'error', 'longnotif')
					end
				else
					xPlayer.showNotification('You do not have enough inventory space', 2500, 'error', 'longnotif')
				end
			elseif itemType == "item_ammo" then
				local ammo = xPlayer.getAmmo()[name]

				if ammo.count+ammo.count > Config.ammoTypes[name].max then
					amount = Config.ammoTypes[name].max - ammo.count
				end

				if amount > 0 then
					local success, message = xGang.removeAmmo(name, amount)

					if success then
						xPlayer.showNotification(message, 2500, 'inform', 'longnotif')
						xPlayer.addWeaponAmmo(name, amount)
						cbResult = true
					else
						xPlayer.showNotification(message, 2500, 'error', 'longnotif')
					end
				else
					xPlayer.showNotification('You are already full on this ammo type', 2500, 'error', 'longnotif')
				end
			elseif itemType == "item_weapon" then
				if xPlayer.hasWeapon(name) then
					xPlayer.showNotification('You already have the same weapon', 2500, 'inform', 'longnotif')
				else
					local success, message = xGang.removeWeapon(name, amount, itemData.item.data.components)

					if success then
						xPlayer.showNotification(message, 2500, 'inform', 'longnotif')
						xPlayer.addWeapon(name)
						cbResult = true

						if itemData.item.data.components then
							for k,v in pairs(itemData.item.data.components) do
								xPlayer.addWeaponComponent(name, v)
							end
						end
					else
						xPlayer.showNotification(message, 2500, 'error', 'longnotif')
					end
				end

			elseif itemType == "item_account" then
				local success, message = xGang.removeAccountMoney(name, amount)

				if success then
					xPlayer.showNotification(message, 2500, 'inform', 'longnotif')
					xPlayer.addAccountMoney(name, amount, ('%s [%s]'):format('House Storage', GetCurrentResourceName()))
					cbResult = true
				else
					xPlayer.showNotification(message, 2500, 'error', 'longnotif')
				end
			end
		else
			xPlayer.showNotification('You do not have permission to withdraw from the storage', 2500, 'error', 'longnotif')
		end
	end

	if cbResult then
		xPlayer.triggerEvent("rpuk_inventory:refreshSecondaryInventory", xGang.formatForSecondInventory())
	end

	currentCallers[playerId] = nil
	cb(cbResult)
end)

RegisterNetEvent('rpuk_jobs:count')
AddEventHandler("rpuk_jobs:count", function(data)
	job_counts = data
end)