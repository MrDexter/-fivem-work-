local guiEnabled, hold = false, false
local pendingGangInvites = {}
local isBlurry = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('rpuk_weather:isBlurry')
AddEventHandler('rpuk_weather:isBlurry', function(_isBlurry) isBlurry = _isBlurry end)

function DisplayNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

RegisterNetEvent('gangs:registerNewInvite')
AddEventHandler('gangs:registerNewInvite', function(gangId, gangName)
	for k, v in pairs(pendingGangInvites) do
		if v.gang_id == gangId then
			return
		end
	end
	TriggerEvent('mythic_notify:client:SendAlert', { length = 5000, type = 'inform', text = "You were invited to " .. gangName})
	table.insert(pendingGangInvites, {gang_id = gangId, gang_name = gangName})
end)

function openMenus(bool)
	if hold then
		return
	end
	hold = true
	SetNuiFocus(bool, bool)

	if bool and not isBlurry then
		SetTimecycleModifier('hud_def_blur')
	elseif not bool and not isBlurry then
		SetTimecycleModifier('default')
	end
	guiEnabled = bool
	ESX.TriggerServerCallback('gangs:rec_lead', function(data)
		SendNUIMessage({
			type = "create_menu",
			pending_invites = pendingGangInvites,
			player_Businesses = data.plyBusinesses,
			business_Table = data.plyBusinessTable,
			default_perms = Config.permission_strings,
			enable = bool
		})
	end)
	-- SendNUIMessage({
	-- 	type = "leave_menu",
	-- 	enable = bool
	-- })
	hold = false
end

RegisterNUICallback('escape', function(data, cb)
    openMenus(false)
    cb('ok')
end)

RegisterNUICallback('leave', function(data, cb)
	hold = true
	ESX.TriggerServerCallback('gangs:leave', function(cb_result, cb_message)
		cb({
			result = cb_result,
			message = cb_message
		})
	end, data.name)
	hold = false
end)

RegisterNUICallback('kick', function(data, cb)
	hold = true
	ESX.TriggerServerCallback('gangs:kick', function(cb_result, cb_message, cb_members)
		cb({
			result = cb_result,
			message = cb_message,
			gang_members = json.encode(cb_members),
		})
	end, data.selectedMember)
	hold = false
end)

RegisterNUICallback('accept_invite', function(data, cb)
	hold = true
	ESX.TriggerServerCallback('gangs:accept_invite', function(cb_result, cb_message)
		cb({
			result = cb_result,
			message = cb_message,
		})
	end, data.selectedPendingInvite)
	hold = false
end)

RegisterNUICallback('invite', function(data, cb)
	hold = true
	ESX.TriggerServerCallback('gangs:invite', function(cb_result, cb_message, cb_nogang)

		cb({
			result = cb_result,
			message = cb_message,
			no_gangs = json.encode(cb_nogang),
		})
	end, data.selectedInvite)
	hold = false
end)

RegisterNUICallback('alter_rank', function(data, cb)
	hold = true
	ESX.TriggerServerCallback('gangs:alter_rank', function(cb_result, cb_message, cb_members)
		cb({
			result = cb_result,
			message = cb_message,
			gang_members = json.encode(cb_members),
		})
	end, data.business_id, data.charID, data.selectedRank)
	hold = false
end)

RegisterNUICallback('update_rank', function(data, cb)
	hold = true
	ESX.TriggerServerCallback('gangs:update_rank', function(cb_result, cb_message, cb_ranks)
		cb({
			result = cb_result,
			message = cb_message,
			gang_ranks = json.encode(cb_ranks),
		})
	end, data.business_id, data.selectedRankProp, data.updatedRank)
	hold = false
end)

RegisterNUICallback('alter_rank_permission', function(data, cb)
	hold = true
	ESX.TriggerServerCallback('gangs:rank_permission', function(cb_result, cb_message, cb_ranks)
		cb({
			result = cb_result,
			message = cb_message,
			gang_ranks = json.encode(cb_ranks),
		})
	end, data.business_id, data.selectedRankProp, data.selectedRankPerm)
	hold = false
end)

RegisterNUICallback('create_gang_rank', function(data, cb)
	hold = true
	print(data.new_name)
	ESX.TriggerServerCallback('gangs:create_rank', function(cb_result, cb_message, cb_ranks)
		cb({
			result = cb_result,
			message = cb_message,
			gang_ranks = json.encode(cb_ranks),
		})
	end, data.new_name)
	hold = false
end)

RegisterNUICallback('delete_rank', function(data, cb)
	hold = true
	ESX.TriggerServerCallback('gangs:delete_rank', function(cb_result, cb_message, cb_ranks)
		cb({
			result = cb_result,
			message = cb_message,
			gang_ranks = json.encode(cb_ranks),
		})
	end, data.selectedRankProp)
	hold = false
end)

RegisterNUICallback('create', function(data, cb)
	hold = true
	local allowed, message = nil, nil
	for k, v in pairs(Config.offensive_strings) do
		if string.match(v, string.lower(data.name)) then
			allowed, message = false, "You name contains a blacklisted phrase. Ensure you read our community rules."
			break
		end
	end

	if allowed == false then
		cb({
			result = allowed,
			message = message
		})
	else
		ESX.TriggerServerCallback('gangs:create', function(cb_result, cb_message)
			cb({
				result = cb_result,
				message = cb_message
			})
		end, data.name)
	end
	hold = false
end)

RegisterKeyMapping('gangmenu', 'Gang/Group Menu', 'keyboard', 'F6')

RegisterCommand("gangmenu", function(source, args)
	openMenus(true)
end)

--openMenus(false)