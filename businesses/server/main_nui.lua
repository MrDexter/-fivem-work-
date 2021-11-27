--[[ Function List

	local xPlayer = ESX.GetPlayerFromId(source)
	local gang_id, gang_rank = xPlayer.getGang() 

	local xGang = getGangFromId(gang_id)
	local result = xGang.changeMemberRank(identifier, new_rank)
	local result = xGang.addMember(identifier)
	local result = xGang.removeMember(identifier)
	local result = xGang.changeName(new_gang_name)
	local result = xGang.changeRankLabel(rank_id, new_rank_label)
	local result = xGang.toggleRankPermission(rank_id, permission_string)
]]

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Businesses = {}
businessesTable = {}

--[[ MySQL.ready(function()
	Wait(5000)
	MySQL.Async.fetchAll('SELECT * FROM businesses', {}, function(pulledBusinesses)
		for k,v in ipairs(pulledBusinesses) do
			Businesses[v.name] = v
			Businesses[v.name].grades = {}
			Businesses[v.name].members = {}
		end

		MySQL.Async.fetchAll('SELECT * FROM business_grades', {}, function(Grades)
			MySQL.Async.fetchAll('SELECT identifier, businesses FROM users WHERE businesses <> "{}"', {}, function(userBusinesses)
				for k,v in ipairs(Grades) do
					if Businesses[v.business_name] then
						Businesses[v.business_name].grades[tostring(v.grade)] = v
						Businesses[v.business_name].grades[tostring(v.grade)].permissions = json.decode(Businesses[v.business_name].grades[tostring(v.grade)].permissions)
						for j, b in ipairs(userBusinesses) do
							tabledBusinesses = json.decode(b.businesses)
							if tabledBusinesses[v.business_name] then
								xPlayer = ESX.GetPlayerFromIdentifier(b.identifier)
								name = xPlayer.getName()
								rank = tabledBusinesses[v.business_name]
								Businesses[v.business_name].members[tostring(b.identifier)] = {name = name, rank = rank}
							end
						end
					else
						print(('Ignoring grades for "%s" due to missing job'):format(v.job_name))
					end
				end
			
			for k2,v2 in pairs(Businesses) do
				if ESX.Table.SizeOf(v2.grades) == 0 then
					Businesses[v2.name] = nil
					print(('Ignoring business "%s" due to no grades found'):format(v2.name))
				end
			end


			end)
		end)
	end)
end) ]]


playerBusinesses = {}

ESX.RegisterServerCallback('gangs:leave', function(source, cb)	
	local xPlayer = ESX.GetPlayerFromId(source)	
	local gang_id, gang_rank = xPlayer.getGang()
	local xGang = getGangFromId(gang_id)

	local cb_result, cb_msg = nil, nil

	if xGang then
		cb_result = xGang.removeMember(xPlayer.identifier)
		cb_msg = "You have left the gang."
	else
		cb_result, cb_msg = false, "Something went wrong."
	end

	while cb_result == nil do
		Citizen.Wait(1000)
	end

	cb(cb_result, cb_msg)
end)

-- pass leader info back to nui	
ESX.RegisterServerCallback('gangs:rec_lead', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)	

	plyBusinesses = xPlayer.getBusinesses()
	for name, k in pairs(plyBusinesses) do
		table.insert(playerBusinesses, name)
	end
	cb({plyBusinesses = playerBusinesses, plyBusinessTable = plyBusinesses})

	local xPlayers = ESX.GetPlayers()
	for i= 1, #xPlayers do
		local xTarget = ESX.GetPlayerFromId(xPlayers[i])
		if xTarget then
			local businesses = xTarget.getBusinesses()
			if businesses ~= nil then
				for name, table in pairs(businesses) do
					table.insert(plyBusinesses[name].members, {
							[xTarget.identifier] = {
								name = xTarget.getName()
							}
					})
				end
					-- plyBusinesses[name].members[xTarget.identifier] = {name = xTarget.getName()}
			else
				no_businesses[xTarget.identifier] = {name = xTarget.getName()}
			end
		end
	end					
end)

ESX.RegisterServerCallback('gangs:kick', function(source, cb, target_id)	
	local xPlayer = ESX.GetPlayerFromId(source)	
	local gang_id, gang_rank = xPlayer.getGang()
	local xGang = getGangFromId(gang_id)

	local cb_result, cb_msg = nil, nil

	if doesGangMemberHavePermission(xPlayer.identifier, "gang_mng_kick", gang_id) then
		if xGang then
			cb_result = xGang.removeMember(target_id)
			if cb_result then
				cb_msg = "Employee Fired!"
			else
				cb_msg = "Unable to fire employee!"
			end
		else
			cb_result, cb_msg = false, "Something went wrong."
		end
	else
		cb_result, cb_msg = false, "You do not have permission to fire!"
	end
	
	local cb_members = xGang.getMembers()
	while cb_result == nil do
		Citizen.Wait(1000)
	end

	cb(cb_result, cb_msg, cb_members)
end)

ESX.RegisterServerCallback('gangs:invite', function(source, cb, target_id)	
	local xPlayer = ESX.GetPlayerFromId(source)	
	local gang_id, gang_rank = xPlayer.getGang()
	local xGang = getGangFromId(gang_id)

	local cb_result, cb_msg = nil, nil
	print(doesGangMemberHavePermission(xPlayer.identifier, "gang_mng_invite", gang_id))
	if doesGangMemberHavePermission(xPlayer.identifier, "gang_mng_invite", gang_id) then
		if xGang then
			local xTarget = ESX.GetPlayerFromCharId(tonumber(target_id))
			if xTarget then
				TriggerClientEvent('gangs:registerNewInvite', xTarget.source, gang_id, xGang.getName())
				cb_result, cb_msg = true, "Employee invited!"
			else
				cb_result, cb_msg = false, "Unable to invite employee!"
			end
		else
			cb_result, cb_msg = false, "Something went wrong."
		end
	else
		cb_result, cb_msg = false, "You do not have permission to invite!"
	end

	local no_gangs = {}
	local xPlayers = ESX.GetPlayers()
	for i= 1, #xPlayers do
		local xTarget = ESX.GetPlayerFromId(xPlayers[i])
		if xTarget then
			local gang_id, gang_rank = xTarget.getGang()
			if gang_id == 0 then
				no_gangs[xTarget.identifier] = {name = xTarget.firstname .. " " .. xTarget.lastname}
			end
		end
	end
	
	while cb_result == nil do
		Citizen.Wait(1000)
	end

	cb(cb_result, cb_msg, no_gangs)
end)

ESX.RegisterServerCallback('gangs:accept_invite', function(source, cb, gang_id)	
	local xPlayer = ESX.GetPlayerFromId(source)	
	local xGang = getGangFromId(gang_id)
	
	local cb_result, cb_msg = nil, "Something went wrong! Unable to accept the invite."
	if xGang then
		cb_result = xGang.addMember(xPlayer.identifier)
		cb_msg = "Gang invite accepted."
	else
		cb_result = false
	end
	
	while cb_result == nil do
		Citizen.Wait(1000)
	end

	cb(cb_result, cb_msg)
end)

ESX.RegisterServerCallback('gangs:alter_rank', function(source, cb, business_name, target_id, new_rank)	-- DONE
	local xPlayer = ESX.GetPlayerFromId(source)	
	old_rank = Businesses[business_name].members[target_id].rank
	source_rank = Businesses[business_name].members[xPlayer.getIdentifier()].rank

	local cb_result, cb_msg = nil, nil
	if source_rank > old_rank then
			if old_rank < new_rank then
				if isinTable("business_mng_promote", Businesses[business_name].grades[tostring(source_rank)].permissions) then
					cb_result, cb_msg = true, "Employee Promoted"
				else
					cb_result, cb_msg = false, "You don't have permission to promote members."
				end
			elseif old_rank > new_rank then
				if isinTable("business_mng_demote", Businesses[business_name].grades[tostring(source_rank)].permissions) then
					cb_result, cb_msg = true, 'Employee Demoted'
				else
					cb_result, cb_msg = false, "You don't have permission to demote employees."
				end				
			else
				cb_result, cb_msg = false, "You can't promote/demote to the same rank."
				-- same rank
			end
			if cb_result == true then
				Businesses[business_name].members[target_id].rank = new_rank
				local data = Businesses[business_name].members[target_id]
				TriggerEvent('BUSINESS:updateBusinesses', target_id, new_rank, business_name)
			end

	else
		cb_result, cb_msg = false, "You need to be above members rank to promote/demote them."
	end

	while cb_result == nil do
		Citizen.Wait(1000)
	end
	local cb_members = Businesses[business_name].members
	
	cb(cb_result, cb_msg, cb_members)
end)

ESX.RegisterServerCallback('gangs:update_rank', function(source, cb, business_name, rank_id, updatedRank) -- DONE
	rank_id = rank_id
	local xPlayer = ESX.GetPlayerFromId(source)	
	local cb_result, cb_msg = nil, nil
	source_rank = tostring(Businesses[business_name].members[xPlayer.getIdentifier()].rank)
	if isinTable("business_mng_admin", Businesses[business_name].grades[source_rank].permissions) then
		Businesses[business_name].grades[rank_id].label = updatedRank.label
		Businesses[business_name].grades[rank_id].salary = tonumber(updatedRank.salary)
		Businesses[business_name].grades[rank_id].permissions = updatedRank.permissions
		if updatedRank.grade ~= nil then
			Businesses[business_name].grades[rank_id].grade = tonumber(updatedRank.grade)
		end
		cb_result, cb_msg = true, "Rank changed!"
		local data = Businesses[business_name].grades[rank_id]
		data.gradesNumber = tableLength(Businesses[business_name].grades)
		TriggerEvent('BUSINESS:updateRank', data, business_name, rank_id)
		if updatedRank.grade ~= nil then
			if updatedRank.grade < rank_id then-- making lower
				increments = -1
				change = 1
			else-- making higher
				increments = 1
				change = -1
			end
			changedRank = Businesses[business_name].grades[rank_id] 
			for i=rank_id,updatedRank.grade, increments do
				local id = math.floor(i)
				if id ~= tonumber(rank_id) then
					Businesses[business_name].grades[tostring(id+change)] = Businesses[business_name].grades[tostring(id)]
					Businesses[business_name].grades[tostring(id+change)].grade = (id+change)
				end
			end
			Businesses[business_name].grades[tostring(updatedRank.grade)] = changedRank
			Businesses[business_name].grades[tostring(updatedRank.grade)].grade = tonumber(updatedRank.grade)
		end
	else
		cb_result, cb_msg = false, "You do not have permission to edit ranks!"
	end
	
	while cb_result == nil do
		Citizen.Wait(1000)
	end
	local cb_ranks = Businesses[business_name].grades
	cb(cb_result, cb_msg, cb_ranks)
end)

--[[ ESX.RegisterServerCallback('gangs:rank_permission', function(source, cb, name, rank_id, permission_string) -- DONE
	rank_id = tostring(rank_id)
	local xPlayer = ESX.GetPlayerFromId(source)
	print(rank_id)
	permission_string = tostring(permission_string)
	source_rank = Businesses[name].members[xPlayer.getIdentifier()].rank
	source_rank = tostring(source_rank)
	local cb_result, cb_msg = nil, nil
	if Config.permission_strings[permission_string] then
		if isinTable("business_mng_admin", Businesses[name].grades[source_rank].permissions) then
			for k,v in pairs(Businesses[name].grades[rank_id].permissions) do
				if v == permission_string then
					table.remove(Businesses[name].grades[rank_id].permissions, k)
					cb_result = true
				end
			end
			if cb_result ~= true then
					table.insert(Businesses[name].grades[rank_id].permissions, permission_string)
					cb_result = true
			end
			local data = Businesses[name].grades[rank_id].permissions
			TriggerEvent('BUSINESS:updatePermissions', data, name, rank_id )
			if cb_result then
				cb_msg = "Rank permissions changed!"
			else
				cb_msg = "Unable to change rank permission!"
			end
		else
			cb_result, cb_msg = false, "You do not have permission to change permissions!"
		end
	else
		cb_result, cb_msg = false, "Invalid permission, please notify a developer!"
	end
	while cb_result == nil do
		Citizen.Wait(1000)
	end
	local cb_ranks = Businesses[name].grades -- Update business table with changes 
	cb(cb_result, cb_msg, cb_ranks)
end) ]]

ESX.RegisterServerCallback('gangs:create_rank', function(source, cb, new_label)	
	new_label = tostring(new_label)
	local xPlayer = ESX.GetPlayerFromId(source)	
	local gang_id, gang_rank = xPlayer.getGang()
	local xGang = getGangFromId(gang_id)

	local cb_result, cb_msg = nil, nil

	if doesGangMemberHavePermission(xPlayer.identifier, "gang_mng_admin", gang_id) then
		if xGang then
			cb_result = xGang.createRank(new_label)
			if cb_result then
				cb_msg = "New gang rank created!"
			else
				cb_msg = "Unable to create new gang rank!"
			end
		else
			cb_result, cb_msg = false, "Something went wrong."
		end
	else
		cb_result, cb_msg = false, "You do not have permission to create ranks!"
	end
	
	while cb_result == nil do
		Citizen.Wait(1000)
	end
	local cb_ranks = xGang.getRanks() 
	cb(cb_result, cb_msg, cb_ranks)
end)

ESX.RegisterServerCallback('gangs:delete_rank', function(source, cb, rank_id)	
	rank_id = rank_id + 1 -- js indexing
	rank_id = tonumber(rank_id)
	
	local xPlayer = ESX.GetPlayerFromId(source)	
	local gang_id, gang_rank = xPlayer.getGang()
	local xGang = getGangFromId(gang_id)

	local cb_result, cb_msg = nil, nil

	if doesGangMemberHavePermission(xPlayer.identifier, "gang_mng_admin", gang_id) then
		if xGang then
			if rank_id > 4 then
				local xGangMembers = xGang.getMembers()
				for k, v in pairs(xGangMembers) do
					if tonumber(v.rank) >= tonumber(rank_id) then
					--	xGang.removeMember(k)
					end
					local xTarget = ESX.GetPlayerFromCharId(k)
					if xTarget then
					--	xGang.addMember(xTarget.identifier)
					end
				end

				cb_result = xGang.deleteRank(rank_id)

				if cb_result then
					cb_msg = "Gang rank deleted!"
				else
					cb_msg = "Unable to delete the gang rank!"
				end
			else
				cb_result, cb_msg = false, "You are unable to delete a default rank."
			end
		else
			cb_result, cb_msg = false, "Something went wrong."
		end
	else
		cb_result, cb_msg = false, "You do not have permission to delete ranks!"
	end
	
	while cb_result == nil do
		Citizen.Wait(1000)
	end
	local cb_ranks = xGang.getRanks()
	cb(cb_result, cb_msg, cb_ranks)
end)
