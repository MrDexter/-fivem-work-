TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local notified = false
local lastNotified = 0

local banks = {
	{name="Bank", id=108, x=150.266, y=-1040.203, z=29.374},
	{name="Bank", id=108, x=-1212.980, y=-330.841, z=37.787},
	{name="Bank", id=108, x=-2962.582, y=482.627, z=15.703},
	{name="Bank", id=108, x=-112.202, y=6469.295, z=31.626},
	{name="Bank", id=108, x=314.187, y=-278.621, z=54.170},
	{name="Bank", id=108, x=-351.534, y=-49.529, z=49.042}, 
	{name="Bank", id=106, x=241.610, y=225.120, z=106.286},
	{name="Bank", id=108, x=1175.064, y=2706.643, z=38.094}
}	

local atms = {'prop_atm_01', 'prop_atm_02', 'prop_fleeca_atm', 'prop_atm_03'}

RegisterNetEvent("qb-banking:client:ExtNotify")
AddEventHandler("qb-banking:client:ExtNotify", function(msg)
	if (not msg or msg == "") then return end

	ESX.showNotification(msg)
end)

--[[ Show Things ]]--
Citizen.CreateThread(function()
	for k,v in ipairs(banks) do
	  local blip = AddBlipForCoord(v.x, v.y, v.z)
	  SetBlipSprite(blip, v.id)
	  SetBlipDisplay(blip, 4)
	  SetBlipScale  (blip, 0.7)
	  SetBlipColour (blip, 2)
	  SetBlipAsShortRange(blip, true)
	  BeginTextCommandSetBlipName("STRING")
	  AddTextComponentString(tostring(v.name))
	  EndTextCommandSetBlipName(blip)
	end
end)


RegisterNetEvent('qb-banking:client:bank:openUI')
AddEventHandler('qb-banking:client:bank:openUI', function() -- this one bank from target models
	if not bMenuOpen then
		-- TriggerEvent('dp:playEmote', "atm")
		ToggleUI()
	end
end)
RegisterNetEvent('qb-banking:client:atm:openUI')
AddEventHandler('qb-banking:client:atm:openUI', function() -- this opens ATM
	if not bMenuOpen then
		TriggerEvent('dp:playEmote', "atm")
		ToggleUI()
	end
end)

exports['qtarget']:AddTargetModel(atms, {
	options = {
		{
			event = "qb-banking:client:atm:openUI",
			icon = "fas fa-box-circle-check",
			label = "Access ATM",
			num = 1
		},
	},
	distance = 2
})

RegisterCommand('atm', function()
	TriggerEvent('qb-banking:client:atm:openUI')
end)
RegisterCommand('bank', function()
	TriggerEvent('qb-banking:client:bank:openUI')
end)