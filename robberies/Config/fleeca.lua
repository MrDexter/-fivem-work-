Config = {}

Config.vaultdoor = 2121050683--"v_ilev_gb_vauldr"
Config.door = -1591004109 --"v_ilev_gb_vaubar"
Config.office = -131754413 --"v_ilev_gb_teldr"
Config.Code = "1234"
Config.Banks = {
    [1] = {-- Alta
        doors = {
            startloc = {x = 310.93, y = -284.44, z = 54.16, h = -90.00, animcoords = {x = 311.05, y = -284.00, z = 53.16, h = 248.60}},
            secondloc = {x = 312.93, y = -284.45, z = 54.16, h = 160.91, animcoords = {x = 313.41, y = -284.42, z = 53.16, h = 160.91}},
        },
        prop = {
            first = {coords = vector3(311.5481, -284.5114, 54.285), rot = vector3(20.0, 270.0, 180)},
            second = {coords = vector3(313.2, -285.4, 54.5), particles = vector3(313.2, -284.4, 54.45)}
        },
        trolleys = {
            [1] = {coords = vector3(311.1, -288.1, 53.1), h = -60.0},
            [2] = {coords = vector3(314.1, -289.2, 53.1), h = 40.0},
            [3] = {coords = vector3(312.6, -289.1, 53.1), h = -20.0},
        },
    },
    [2] = { -- Legion
        doors = {
            startloc = {x = 146.61, y = -1046.02, z = 29.37, h = 244.20, animcoords = {x = 146.75, y = -1045.60, z = 28.37, h = 244.20}},
            secondloc = {x = 148.76, y = -1045.89, z = 29.37, h = 158.54, animcoords = {x = 149.10, y = -1046.08, z = 28.37, h = 158.54}}
        },
        prop = {
            first = {coords = vector3(147.22, -1046.148, 29.487), rot = vector3(20.0, 270.0, 180)}, -- ID CARD 
            second = {coords = vector3(148.9, -1047.05, 29.7), particles = vector3(148.9, -1046.1, 29.70)} -- Thermite
        },
        trolleys = {
            [1] = {coords = vector3(146.7, -1049.8, 28.3), h = -60.0},
            [2] = {coords = vector3(149.8, -1050.9, 28.3), h = 15.0},
            [3] = {coords = vector3(148.2, -1050.7, 28.3), h = -20.0},
        },
    },
    [3] = { -- Rockford Hills
        doors = {
            startloc = {x = -1211.07, y = -336.68, z = 37.78, h = 296.76, animcoords = {x = -1211.25, y = -336.37, z = 36.78, h = 296.76}}, 
            secondloc = {x = -1209.66, y = -335.15, z = 37.78, h = 213.67, animcoords = {x = -1209.40, y = -335.05, z = 36.78, h = 213.67}}
        },
        prop = {
            first = {coords = vector3(-1210.50, -336.37, 37.901), rot = vector3(20.0, 270.0, 180)},
            second = {coords = vector3(-1208.7, -335.8, 38.1), particles = vector3(-1208.7, -334.7, 38.1)}
        },
        trolleys = {
            [1] = {coords = vector3(-1208.1, -339.1, 36.8), h = -20.0},
            [2] = {coords = vector3(-1205.3, -337.7, 36.8), h = 75.0},
            [3] = {coords = vector3(-1206.4, -338.7, 36.8), h = 27.50},
        },
    },
    [4] = { -- Ocean Highway
        hash = -63539571, -- exception
        doors = {
            startloc = {x = -2956.68, y = 481.34, z = 15.70, h = 353.97, animcoords = {x = -2956.68, y = 481.34, z = 14.70, h = 353.97}},
            secondloc = {x = -2957.26, y = 483.53, z = 15.70, h = 267.73, animcoords = {x = -2957.26, y = 483.53, z = 14.70, h = 267.73}}
        },
        prop = {
            first = {coords = vector3(-2956.59, 482.05, 15.815), rot = vector3(20.0, 270.0, 180)},
            second = {coords = vector3(-2956.2, 483.9, 16.0), particles = vector3(-2956.2, 484.9, 16.0)}
        },
        trolleys = {
            [1] = {coords = vector3(-2953.0, 482.7, 14.7), h = 40.0},
            [2] = {coords = vector3(-2952.8, 486.0, 14.7), h = 140.0},
            [3] = {coords = vector3(-2952.6, 484.4, 14.7), h = 87.5},
        },
    },
    [5] = { --  Burton
        doors = {
            startloc = {x = -354.15, y = -55.11, z = 49.04, h = 251.05, animcoords = {x = -354.15, y = -55.11, z = 48.04, h = 251.05}},
            secondloc = {x = -351.97, y = -55.18, z = 49.04, h = 159.79, animcoords = {x = -351.97, y = -55.18, z = 48.04, h = 159.79}}
        },
        prop = {
            first = {coords = vector3(-353.50, -55.37, 49.157), rot = vector3(90.0, 180.0, 20.0)},
            second = {coords = vector3(-352.15, -55.77, 49.157), rot = vector3(90.0, 180.0, 110.0)}
        },
        trolleys = {
            [1] = {coords = vector3(-353.34, -59.48, 48.01), h = 180},
            [2] = {coords = vector3(-351.57, -60.09, 48.01), h = 180},
            [3] = {coords = vector3(-350.57, -54.45, 48.01), h = 180},
        },
    },
    [6] = { -- Route 68
        doors = { 
            startloc = {x = 1176.40, y = 2712.75, z = 38.09, h = 84.83, animcoords = {x = 1176.40, y = 2712.75, z = 37.09, h = 84.83}},
            secondloc = {x = 1174.24, y = 2712.47, z = 38.09, h = 359.05, animcoords = {x = 1174.33, y = 2712.09, z = 37.09, h = 359.05}}
        },
        prop = {
            first = {coords = vector3(1175.70, 2712.82, 38.207), rot = vector3(90.0, 180.0, 180.0)},
            second = {coords = vector3(1174.267, 2712.736, 38.207), rot = vector3(90.0, 180.0, -90.0)}
        },
        trolley1 = {x = 1174.24, y = 2716.69, z = 37.07, h = -180},
        trolley2 = {x = 1172.27, y = 2716.67, z = 37.07, h = -180},
        trolley3 = {x = 1173.23, y = 2711.02, z = 37.07, h = 0},
        objects = {
            vector3(1174.24, 2716.69, 37.07),
            vector3(1172.27, 2716.67, 37.07),
            vector3(1173.23, 2711.02, 37.07)
        },
        loot1 = false,
        loot2 = false,
        loot3 = false,
        onaction = false,
        lastrobbed = 0
    }
}