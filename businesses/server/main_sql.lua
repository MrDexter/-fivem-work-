TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('gangs:create', function(source, cb, name)
	local xPlayer = ESX.GetPlayerFromId(source)
	local cb_result, message = nil, nil
	name = tostring(name)

	if xPlayer then

		local found = false

		for k, v in pairs(gangs) do
			if name == v.name then -- used to double check gang name/pre existance					
				found, message = true, "Business creation failed. This name already exists!"
				break
			end
		end

		if found then
			cb_result = false
		else
			MySQL.Async.fetchAll('SELECT * FROM businesses WHERE name=@name', {
				['@name'] = name,
			}, function(nameCheckResult)
				if nameCheckResult[1] then
					cb_result, message = false, "Business creation failed. This name already exists!"
				else
					-- local default_members = {[xPlayer.identifier] = {rank = 1, name = xPlayer.getName()}}
					local shortName = name:gsub("%s+", "") 
					shortName = shortName:lower()
					MySQL.Async.insert('INSERT INTO `businesses` (`name`, `label`) VALUES (@name, @label)', {
						['@name']  = shortName,
						['@label'] = name
					}, function(ID)
						if ID then
							MySQL.Async.insert('INSERT INTO `business_grades` (business_name, grade, label, salary, members) VALUES (@business_name, @grade, @label, @salary, @members)',
							{
								['@business_name']   = shortName,
								['@grade']   = 2,
								['@label']   = "Chief",
								['@salary']   = 0,
								['members']   = json.encode({xPlayer.identifier})
							}, function(ID)
								if ID then
									-- gangs[gangID] = createGang({id = gangID, name = name, members = default_members, ranks = Config.default_ranks, storage = json.encode('{}'), claim_blueprint = 0, claim_drugs = 0, claim_tips = 0})
									-- local xGang = getGangFromId(gangID)
									cb_result, message = true, "Business creation was successful! The name was accepted and the gang was created. Manage it properly and stay within the community rules."
									-- xPlayer.setGang(gangID, 1) -- usable but please don't use xGang.addMember(charid) as it verifies they are able to join a gang and puts them at lowest rank
								else
									cb_result, message = false, "Business creation failed. Something went wrong, please contact staff"
								end
							end)
							-- gangs[gangID] = createGang({id = gangID, name = name, members = default_members, ranks = Config.default_ranks, storage = json.encode('{}'), claim_blueprint = 0, claim_drugs = 0, claim_tips = 0})
							-- local xGang = getGangFromId(gangID)
							cb_result, message = true, "Business creation was successful! Manage it properly and stay within the community rules."
							-- xPlayer.setGang(gangID, 1) -- usable but please don't use xGang.addMember(charid) as it verifies they are able to join a gang and puts them at lowest rank
						else
							cb_result, message = false, "Business creation failed. Something went wrong, please contact staff"
						end
					end)
				end
			end)
		end
	end
	while cb_result == nil do
		Citizen.Wait(1000)
	end
	cb(cb_result, message)
end)

RegisterNetEvent('BUSINESS:updateBusinesses')
AddEventHandler('BUSINESS:updateBusinesses', function(target_id, new_rank, business_name) 
	MySQL.Async.fetchAll('SELECT businesses FROM users where identifier = @identifier', {['@identifier'] = target_id}, function(plyBusinesses)
		plyBusinesses[1].businesses = json.decode(plyBusinesses[1].businesses)
		plyBusinesses[1].businesses[business_name] = new_rank	
		data = json.encode(plyBusinesses[1].businesses)
		MySQL.Async.execute('UPDATE users SET businesses=@data WHERE identifier = @identifier',
		{
			['@data'] = data, 
			['@identifier'] = target_id
		}, function()
		end)
	end)
end)

--[[ RegisterNetEvent('BUSINESS:updatePermissions')
AddEventHandler('BUSINESS:updatePermissions', function(data, business_name, grade) 
	MySQL.Async.execute('UPDATE business_grades SET permissions = @data WHERE business_name = @business_name AND grade = @grade', 
	{
		['@data'] = json.encode(data), 
		['@business_name'] = business_name, 
		['@grade'] = grade
	}, function()
	end)
end)

RegisterNetEvent('BUSINESS:updateSalary')
AddEventHandler('BUSINESS:updateSalary', function(data, business_name, grade) 
	MySQL.Async.execute('UPDATE business_grades SET salary = @data WHERE business_name = @business_name AND grade = @grade', 
	{
		['@data'] = data, 
		['@business_name'] = business_name, 
		['@grade'] = grade
	}, function()
	end)
end) ]]

RegisterNetEvent('BUSINESS:updateRank')
AddEventHandler('BUSINESS:updateRank', function(data, business_name, grade) 
	local gradeNumber = tonumber(grade)
	local dataGrade = tonumber(data.grade)
	MySQL.Async.execute('UPDATE business_grades SET label = @label, salary = @salary, permissions = @permissions WHERE business_name = @business_name AND grade = @grade', 
	{
		['@label'] = data.label, 
		['@salary'] = data.salary, 
		['@permissions'] = json.encode(data.permissions), 
		['@business_name'] = business_name, 
		['@grade'] = grade
	}, function()
	end)
	if dataGrade ~= gradeNumber then 
		if dataGrade < gradeNumber then-- making lower
			increments = -1
			change = 1
		else-- making higher
			increments = 1
			change = -1

		end

		for i=gradeNumber,dataGrade, increments do
			if i ~= gradeNumber then
				query = 'UPDATE business_grades SET grade = grade +@change WHERE business_name = @business_name AND grade = @grade AND label <> @label'
			else
				query = 'UPDATE business_grades SET grade = @newgrade WHERE business_name = @business_name AND grade = @grade AND label = @label'
			end
			MySQL.Async.execute(query,
			{
				['@business_name'] = business_name, 
				['@grade'] = tostring(i),
				['@newgrade'] = data.grade, 
				['@label'] = data.label,
				['@change'] = change
			}, function()
			end)
		end
	end
end)
-- MySQL.ready(function()
-- 	local SQL_GANGS = MySQL.Sync.fetchAll('SELECT * FROM businesses')
-- 	for k, v in pairs(SQL_GANGS) do
-- 		gangs[v.id] = createGang({id = v.id, name = v.gang_name, members = json.decode(v.gang_members), ranks = json.decode(v.gang_ranks), storage = v.gang_safe, claim_blueprint = v.claim_blueprint, claim_drugs = v.claim_drugs, claim_tips = v.claim_tips})
-- 	end
-- end)

-- function syncGangs(gang_id)
-- 	if gang_id then
-- 		local xGang = getGangFromId(gang_id)
-- 		if xGang then
-- 			MySQL.Async.execute('UPDATE businesses SET name=@gang_name, gang_members=@gang_members, gang_ranks=@gang_ranks, gang_safe=@gang_safe WHERE id=@gang_id', {
-- 				['@gang_id'] = xGang.id,
-- 				['@gang_name'] = xGang.name,
-- 				['@gang_members'] = json.encode(xGang.members),
-- 				['@gang_ranks'] = json.encode(xGang.ranks),
-- 			})
-- 			print("Gang SQL Sync Complete for Gang ID: " .. xGang.id .. " | " .. xGang.name)
-- 		end
-- 	else
-- 		for k, v in pairs(gangs) do
-- 			local xGang = getGangFromId(k)
-- 			if xGang then
-- 				MySQL.Async.execute('UPDATE gangs SET gang_name=@gang_name, gang_members=@gang_members, gang_ranks=@gang_ranks, gang_safe=@gang_safe  WHERE id=@gang_id', {
-- 					['@gang_id'] = xGang.id,
-- 					['@gang_name'] = xGang.name,
-- 					['@gang_members'] = json.encode(xGang.members),
-- 					['@gang_ranks'] = json.encode(xGang.ranks),
-- 					['@gang_safe'] = json.encode(xGang.ranks),
-- 				})
-- 				print("Gang SQL Sync Complete for Gang ID: " .. xGang.id .. " | " .. xGang.name)
-- 			end
-- 		end
-- 	end
-- end