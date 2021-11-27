ConfigVengelico = {}

ConfigVengelico.resetTime = 1 -- Reset time in minutes. Reset is done x minutes after last case smashed

ConfigVengelico.models = { -- Before then After
   [1] =  {37228785, -1469834270},
   [2] =  {-1846370968, 1097883532},
   [3] =  {1768229041, 2103335194},
   [4] =  {-1880169779, -677416883}
}

ConfigVengelico.weapons = { -- Possible Weapons to smash cases 
    'WEAPON_ASSAULTRIFLE',
    'WEAPON_CARBINERIFLE',
    'WEAPON_ADVANCEDRIFLE',
    'WEAPON_BULLPUPRIFLE',
    'weapon_pumpshotgun',
    'weapon_dbshotgun',
    'weapon_smg',
}

ConfigVengelico.items = {
    [1] = {'diamond_necklace','diamond_ring','diamond_watch'}, -- High tier
    [2] = {'gold_ring','gold_watch','gold_necklace'}, -- Mid tier
    [3] = {'silver_ring','silver_watch','silver_necklace'} -- Low tier
}