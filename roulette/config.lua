_DEBUG = true
Config = {}

Config.RouletteStart = 10 -- how many seconds to start the rulett after you sit down

Config.Tables = {
    {
        coords = vector3(1150.718505859375, 262.52783203125, -52.840850830078125),
        rot = -45.0,
		highStakes = false
    },
    {
        coords = vector3(1144.732421875, 268.14117431640625, -52.840850830078125),
        rot = 135.0,
		highStakes = false
    },
    {
        coords = vector3(1133.68115234375, 262.01678466796875, -52.03075408935547),
        rot = -156.0,
		highStakes = true
    },
    {
        coords = vector3(1129.53955078125, 267.06097412109375, -52.03075408935547),
        rot = 26.0,
		highStakes = true
    },
    {
        coords = vector3(1144.6773681641, 250.74932861328, -52.03075408935547),
        rot = 80.0,
		highStakes = true
    },
    {
        coords = vector3(1147.9478759766,247.95536804199, -52.03075408935547),
        rot = -100.0,
		highStakes = true
    }
}

Config.wheel = {
    [1] = '00',
    [2] = '27',
    [3] = '10',
    [4] = '25',
    [5] = '29',
    [6] = '12',
    [7] = '8',
    [8] = '19',
    [9] = '31',
    [10] = '18',
    [11] = '6',
    [12] = '21',
    [13] = '33',
    [14] = '16',
    [15] = '4',
    [16] = '23',
    [17] = '35',
    [18] = '14',
    [19] = '2',
    [20] = '0',
    [21] = '28',
    [22] = '9',
    [23] = '26',
    [24] = '30',
    [25] = '11',
    [26] = '7',
    [27] = '20',
    [28] = '32',
    [29] = '17',
    [30] = '5',
    [31] = '22',
    [32] = '34',
    [33] = '15',
    [34] = '3',
    [35] = '24',
    [36] = '36',
    [37] = '13',
    [38] = '1'
}

function DebugPrint(str)
	if _DEBUG == true and str then
		return print("ROULETTE: "..tostring(str))
	end
end

Roulette_Numbers = {}
Roulette_Numbers.Red = {
    ['1'] = true,
    ['3'] = true,
    ['5'] = true,
    ['7'] = true,
    ['9'] = true,
    ['12'] = true,
    ['14'] = true,
    ['16'] = true,
    ['18'] = true,
    ['19'] = true,
    ['21'] = true,
    ['23'] = true,
    ['25'] = true,
    ['27'] = true,
    ['30'] = true,
    ['32'] = true,
    ['34'] = true,
    ['36'] = true
}
Roulette_Numbers.Black = {
    ['2'] = true,
    ['4'] = true,
    ['6'] = true,
    ['8'] = true,
    ['10'] = true,
    ['11'] = true,
    ['13'] = true,
    ['15'] = true,
    ['17'] = true,
    ['20'] = true,
    ['22'] = true,
    ['24'] = true,
    ['26'] = true,
    ['28'] = true,
    ['29'] = true,
    ['31'] = true,
    ['33'] = true,
    ['35'] = true
}
Roulette_Numbers.Even = {
    ['2'] = true,
    ['4'] = true,
    ['6'] = true,
    ['8'] = true,
    ['10'] = true,
    ['12'] = true,
    ['14'] = true,
    ['16'] = true,
    ['18'] = true,
    ['20'] = true,
    ['22'] = true,
    ['24'] = true,
    ['26'] = true,
    ['28'] = true,
    ['30'] = true,
    ['32'] = true,
    ['34'] = true,
    ['36'] = true
}
Roulette_Numbers.Odd = {
    ['1'] = true,
    ['3'] = true,
    ['5'] = true,
    ['7'] = true,
    ['9'] = true,
    ['11'] = true,
    ['13'] = true,
    ['15'] = true,
    ['17'] = true,
    ['19'] = true,
    ['21'] = true,
    ['23'] = true,
    ['25'] = true,
    ['27'] = true,
    ['29'] = true,
    ['31'] = true,
    ['33'] = true,
    ['35'] = true
}
Roulette_Numbers.to18 = {
    ['1'] = true,
    ['2'] = true,
    ['3'] = true,
    ['4'] = true,
    ['5'] = true,
    ['6'] = true,
    ['7'] = true,
    ['8'] = true,
    ['9'] = true,
    ['10'] = true,
    ['11'] = true,
    ['12'] = true,
    ['13'] = true,
    ['14'] = true,
    ['15'] = true,
    ['16'] = true,
    ['17'] = true,
    ['18'] = true
}
Roulette_Numbers.to36 = {
    ['19'] = true,
    ['20'] = true,
    ['21'] = true,
    ['22'] = true,
    ['23'] = true,
    ['24'] = true,
    ['25'] = true,
    ['26'] = true,
    ['27'] = true,
    ['28'] = true,
    ['29'] = true,
    ['30'] = true,
    ['31'] = true,
    ['32'] = true,
    ['33'] = true,
    ['34'] = true,
    ['35'] = true,
    ['36'] = true
}
Roulette_Numbers.st12 = {
    ['1'] = true,
    ['2'] = true,
    ['3'] = true,
    ['4'] = true,
    ['5'] = true,
    ['6'] = true,
    ['7'] = true,
    ['8'] = true,
    ['9'] = true,
    ['10'] = true,
    ['11'] = true,
    ['12'] = true
}
Roulette_Numbers.sn12 = {
    ['13'] = true,
    ['14'] = true,
    ['15'] = true,
    ['16'] = true,
    ['17'] = true,
    ['18'] = true,
    ['19'] = true,
    ['20'] = true,
    ['21'] = true,
    ['22'] = true,
    ['23'] = true,
    ['24'] = true
}
Roulette_Numbers.rd12 = {
    ['25'] = true,
    ['26'] = true,
    ['27'] = true,
    ['28'] = true,
    ['29'] = true,
    ['30'] = true,
    ['31'] = true,
    ['32'] = true,
    ['33'] = true,
    ['34'] = true,
    ['35'] = true,
    ['36'] = true
}
Roulette_Numbers.to_1 = {
    ['1'] = true,
    ['4'] = true,
    ['7'] = true,
    ['10'] = true,
    ['13'] = true,
    ['16'] = true,
    ['19'] = true,
    ['22'] = true,
    ['25'] = true,
    ['28'] = true,
    ['31'] = true,
    ['34'] = true
}
Roulette_Numbers.to_2 = {
    ['2'] = true,
    ['5'] = true,
    ['8'] = true,
    ['11'] = true,
    ['14'] = true,
    ['17'] = true,
    ['20'] = true,
    ['23'] = true,
    ['26'] = true,
    ['29'] = true,
    ['32'] = true,
    ['35'] = true
}
Roulette_Numbers.to_3 = {
    ['3'] = true,
    ['6'] = true,
    ['9'] = true,
    ['12'] = true,
    ['15'] = true,
    ['18'] = true,
    ['21'] = true,
    ['24'] = true,
    ['27'] = true,
    ['30'] = true,
    ['33'] = true,
    ['36'] = true
}

Config.lowTableLimit = 27
Config.highTableLowLimit = 17
Config.bettingNums = {
	10,
	20,
	30,
	40,
	50,
	60,
	70,
	80,
	90,
	100, -- 10 High-limit Tables minimum bet limit
	150,
	200,
	250,
	300,
	350,
	400,
	450,
	500,
	1000,
	1500,
	2000,
	2500,
	3000,
	3500,
	4000,
	4500,
	5000, -- 27 rpuk-low-table limit, betting numbers added after this will be high stakes only
	6000,
	7000,
	8000,
	9000,
	10000,
	15000,
	20000,
	25000,
	30000,
	35000,
	40000,
	45000,
	50000, 
	55000,
	60000,
	65000,
	70000,
	75000,
	80000,
	85000,
	90000,
	95000,
	100000,
	150000,
	200000,
	250000,
	300000,
	350000,
	400000,
	450000,
	500000,
}

MaleDealerVoices = {
	"S_M_Y_Casino_01_ASIAN_01",
	"S_M_Y_Casino_01_ASIAN_02",
	"S_M_Y_Casino_01_LATINA_01",
	"S_M_Y_Casino_01_LATINA_02"
}

function SetDealerVoice(ped, index)
	
	SetPedVoiceGroup(ped, MaleDealerVoices[index])
	
end

function SetDealerOutfit(ped, outfit)
	local outfit = (outfit % 13) or math.random(0, 13)

	SetPedDefaultComponentVariation(ped)

	if outfit == 0 then --OK MALE WHITE #1
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 3, 0, 0)
		SetPedComponentVariation(ped, 1, 1, 0, 0)
		SetPedComponentVariation(ped, 2, 3, 0, 0)
		SetPedComponentVariation(ped, 3, 1, 0, 0)
		SetPedComponentVariation(ped, 4, 0, 0, 0)
		SetPedComponentVariation(ped, 6, 1, 0, 0)
		SetPedComponentVariation(ped, 7, 2, 0, 0)
		SetPedComponentVariation(ped, 8, 3, 0, 0)
		SetPedComponentVariation(ped, 10, 1, 0, 0)
		SetPedComponentVariation(ped, 11, 1, 1, 0)
		return
	elseif outfit == 1 then --OK MALE ASIAN #1
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 2, 2, 0)
		SetPedComponentVariation(ped, 1, 1, 0, 0)
		SetPedComponentVariation(ped, 2, 4, 0, 0)
		SetPedComponentVariation(ped, 3, 1, 3, 0)
		SetPedComponentVariation(ped, 4, 0, 0, 0)
		SetPedComponentVariation(ped, 6, 1, 0, 0)
		SetPedComponentVariation(ped, 7, 2, 0, 0)
		SetPedComponentVariation(ped, 8, 3, 0, 0)
		SetPedComponentVariation(ped, 10, 1, 0, 0)
		SetPedComponentVariation(ped, 11, 1, 1, 0)
		return
	elseif outfit == 2 then --OK MALE ASIAN #2
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 2, 1, 0)
		SetPedComponentVariation(ped, 1, 1, 0, 0)
		SetPedComponentVariation(ped, 2, 2, 0, 0)
		SetPedComponentVariation(ped, 3, 1, 3, 0)
		SetPedComponentVariation(ped, 4, 0, 0, 0)
		SetPedComponentVariation(ped, 6, 0, 0, 0)
		SetPedComponentVariation(ped, 7, 0, 0, 0)
		SetPedComponentVariation(ped, 8, 3, 0, 0)
		SetPedComponentVariation(ped, 10, 1, 0, 0)
		SetPedComponentVariation(ped, 11, 1, 1, 0)
		return
	elseif outfit == 3 then --OK MALE ASIAN #3
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 2, 0, 0)
		SetPedComponentVariation(ped, 1, 1, 0, 0)
		SetPedComponentVariation(ped, 2, 3, 0, 0)
		SetPedComponentVariation(ped, 3, 1, 3, 0)
		SetPedComponentVariation(ped, 4, 1, 0, 0)
		SetPedComponentVariation(ped, 6, 1, 0, 0)
		SetPedComponentVariation(ped, 7, 2, 0, 0)
		SetPedComponentVariation(ped, 8, 3, 0, 0)
		SetPedComponentVariation(ped, 10, 1, 0, 0)
		SetPedComponentVariation(ped, 11, 1, 1, 0)
		return
	elseif outfit == 4 then --OK MALE WHITE #2 (Head 4)
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 4, 2, 0)
		SetPedComponentVariation(ped, 1, 1, 0, 0)
		SetPedComponentVariation(ped, 2, 3, 0, 0)
		SetPedComponentVariation(ped, 3, 1, 0, 0)
		SetPedComponentVariation(ped, 4, 0, 0, 0)
		SetPedComponentVariation(ped, 6, 1, 0, 0)
		SetPedComponentVariation(ped, 7, 2, 0, 0)
		SetPedComponentVariation(ped, 8, 3, 0, 0)
		SetPedComponentVariation(ped, 10, 1, 0, 0)
		SetPedComponentVariation(ped, 11, 1, 1, 0)
		return
	elseif outfit == 5 then --OK MALE WHITE #3
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 4, 0, 0)
		SetPedComponentVariation(ped, 1, 1, 0, 0)
		SetPedComponentVariation(ped, 2, 0, 0, 0)
		SetPedComponentVariation(ped, 3, 1, 0, 0)
		SetPedComponentVariation(ped, 4, 0, 0, 0)
		SetPedComponentVariation(ped, 6, 1, 0, 0)
		SetPedComponentVariation(ped, 7, 2, 0, 0)
		SetPedComponentVariation(ped, 8, 3, 0, 0)
		SetPedComponentVariation(ped, 10, 1, 0, 0)
		SetPedComponentVariation(ped, 11, 1, 1, 0)
		return
	elseif outfit == 6 then -- OK MALE WHITE #4
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 4, 1, 0)
		SetPedComponentVariation(ped, 1, 1, 0, 0)
		SetPedComponentVariation(ped, 2, 4, 0, 0)
		SetPedComponentVariation(ped, 3, 1, 0, 0)
		SetPedComponentVariation(ped, 4, 0, 0, 0)
		SetPedComponentVariation(ped, 6, 1, 0, 0)
		SetPedComponentVariation(ped, 7, 2, 0, 0)
		SetPedComponentVariation(ped, 8, 3, 0, 0)
		SetPedComponentVariation(ped, 10, 1, 0, 0)
		SetPedComponentVariation(ped, 11, 1, 1, 0)
		return
	elseif outfit == 7 then --OK FEMALE ASIAN #1
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 1, 1, 0)
		SetPedComponentVariation(ped, 1, 0, 0, 0)
		SetPedComponentVariation(ped, 2, 1, 0, 0)
		SetPedComponentVariation(ped, 3, 0, 3, 0)
		SetPedComponentVariation(ped, 4, 0, 0, 0)
		SetPedComponentVariation(ped, 6, 0, 0, 0)
		SetPedComponentVariation(ped, 7, 0, 0, 0)
		SetPedComponentVariation(ped, 8, 0, 0, 0)
		SetPedComponentVariation(ped, 10, 0, 0, 0)
		SetPedComponentVariation(ped, 11, 0, 1, 0)
		return
	elseif outfit == 8 then -- OK ASIAN FEMALE #3
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 2, 0, 0)
		SetPedComponentVariation(ped, 1, 0, 0, 0)
		SetPedComponentVariation(ped, 2, 2, 0, 0)
		SetPedComponentVariation(ped, 3, 0, 3, 0)
		SetPedComponentVariation(ped, 4, 0, 0, 0)
		SetPedComponentVariation(ped, 6, 0, 0, 0)
		SetPedComponentVariation(ped, 7, 0, 0, 0)
		SetPedComponentVariation(ped, 8, 0, 0, 0)
		SetPedComponentVariation(ped, 10, 0, 0, 0)
		SetPedComponentVariation(ped, 11, 0, 1, 0)
		return
	elseif outfit == 9 then --OK LATINA FEMALE #2
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 3, 1, 0)
		SetPedComponentVariation(ped, 1, 0, 0, 0)
		SetPedComponentVariation(ped, 2, 3, 1, 0)
		SetPedComponentVariation(ped, 3, 1, 1, 0)
		SetPedComponentVariation(ped, 4, 1, 0, 0)
		SetPedComponentVariation(ped, 6, 1, 0, 0)
		SetPedComponentVariation(ped, 7, 2, 0, 0)
		SetPedComponentVariation(ped, 8, 1, 0, 0)
		SetPedComponentVariation(ped, 10, 0, 0, 0)
		SetPedComponentVariation(ped, 11, 0, 1, 0)
		return
	elseif outfit == 10 then --OK LATINA FEMALE #3
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 4, 0, 0)
		SetPedComponentVariation(ped, 1, 0, 0, 0)
		SetPedComponentVariation(ped, 2, 4, 0, 0)
		SetPedComponentVariation(ped, 3, 1, 1, 0)
		SetPedComponentVariation(ped, 4, 1, 0, 0)
		SetPedComponentVariation(ped, 6, 1, 0, 0)
		SetPedComponentVariation(ped, 7, 1, 0, 0)
		SetPedComponentVariation(ped, 8, 1, 0, 0)
		SetPedComponentVariation(ped, 10, 0, 0, 0)
		SetPedComponentVariation(ped, 11, 0, 1, 0)
		SetPedPropIndex(ped, 1, 0, 0, false)
		return
	elseif outfit == 11 then -- OK ASIAN FEMALE #2
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 1, 1, 0)
		SetPedComponentVariation(ped, 1, 0, 0, 0)
		SetPedComponentVariation(ped, 2, 1, 1, 0)
		SetPedComponentVariation(ped, 3, 1, 3, 0)
		SetPedComponentVariation(ped, 4, 0, 0, 0)
		SetPedComponentVariation(ped, 6, 0, 0, 0)
		SetPedComponentVariation(ped, 7, 2, 0, 0)
		SetPedComponentVariation(ped, 8, 1, 0, 0)
		SetPedComponentVariation(ped, 10, 0, 0, 0)
		SetPedComponentVariation(ped, 11, 0, 1, 0)
		return
	elseif outfit == 12 then --OK ASIAN FEMALE #4
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 2, 1, 0)
		SetPedComponentVariation(ped, 1, 0, 0, 0)
		SetPedComponentVariation(ped, 2, 2, 1, 0)
		SetPedComponentVariation(ped, 3, 3, 3, 0)
		SetPedComponentVariation(ped, 4, 1, 0, 0)
		SetPedComponentVariation(ped, 6, 1, 0, 0)
		SetPedComponentVariation(ped, 7, 2, 0, 0)
		SetPedComponentVariation(ped, 8, 3, 0, 0)
		SetPedComponentVariation(ped, 10, 0, 0, 0)
		SetPedComponentVariation(ped, 11, 0, 1, 0)
		return
	elseif outfit == 13 then --OK LATINA FEMALE #1
		SetPedDefaultComponentVariation(ped)
		SetPedComponentVariation(ped, 0, 3, 0, 0)
		SetPedComponentVariation(ped, 1, 0, 0, 0)
		SetPedComponentVariation(ped, 2, 3, 0, 0)
		SetPedComponentVariation(ped, 3, 0, 1, 0)
		SetPedComponentVariation(ped, 4, 1, 0, 0)
		SetPedComponentVariation(ped, 6, 1, 0, 0)
		SetPedComponentVariation(ped, 7, 1, 0, 0)
		SetPedComponentVariation(ped, 8, 0, 0, 0)
		SetPedComponentVariation(ped, 10, 0, 0, 0)
		SetPedComponentVariation(ped, 11, 0, 1, 0)
		SetPedPropIndex(ped, 1, 0, 0, false)
		return
	end
end