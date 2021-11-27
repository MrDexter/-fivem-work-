Config = {}
Config.TruckPlateNumb = 0  -- This starts the custom plate for trucks at 0
Config.MaxStops	= 3 -- Total number of stops a person is allowed to do before having to return to depot.
Config.MaxBins = 3 -- Total amount of bins needed to complate a zone
Config.MaxBags = 3 -- Total number of bags a person can get out of a bin
Config.MinBags = 1 -- Min number of bags that a bin can contain.
Config.BagPay = 25 -- The amount paid to each person per bag
Config.StopPay = 200 -- Total pay for the stop before bagpay.
Config.JobName = 'garbage'  -- use this to set the jobname that you want to be able to do garbagecrew 


Config.Trucks = {
  'trash',
  'trash2',
}

Config.DumpstersAvaialbe = {
  1614656839,
  666561306,
  -1426008804,
  218085040,
  -58485588,
  -206690185,
  1511880420,
  682791951,
  -387405094,
  364445978,
  1605769687,
  -1831107703,
  -515278816,
  -1790177567,
}

Config.VehicleSpawn = {pos = vector3(-328.50,-1520.99, 27.53),}

Config.Zones = {
	[1] = {type = 'Zone', size = 5.0 , name = 'endmission', pos = vector3(-335.26,-1529.56, 26.58)},
	[2] = {type = 'Zone', size = 3.0 , name = 'timeclock', pos = vector3(-320.46,-1532.4, 27.58)},
}

Config.Count = 7
Config.Locations = {
  [1] = {name = 'Sandy Shores', pos = vector3(1825, 3750, 34.0), size = 250.0},
  [2] = {name = 'Legion', pos = vector3(195.2, -933.8, 29.7), size = 250.0},
  [3] = {name = 'Vespucci Beach', pos = vector3(-1147.4, -1443.6, 14.0), size = 250.0},
  [4] = {name = 'Burton', pos = vector3(-485.6, -49.3, 39.0), size = 250.0},
  [5] = {name = 'Strawberry', pos = vector3(-181.8, -1308.7, 31.7), size = 250.0},
  [6] = {name = "Rancho", pos = vector3(451.1, -1512.5, 28.2), size = 250.0},
  [7] = {name = "West Vinewood", pos = vector3(451.1, -1512.5, 28.2), size = 250.0}
}
  -- [2] = {name = 'LS International', pos = , size = },
  -- [5] = {name = 'Downtown', pos = , size = },