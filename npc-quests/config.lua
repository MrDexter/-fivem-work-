Config = {}

Config.RoofRunning = {
    ["requireditems"] = {
       [1] = {item = "weapon_wrench", amount = 1},
       [2] = {item = "security_card_01", amount = 1},
    },

    ['settings'] = {
        Police = 0,
        ProgressBarTime = 5000,
        Cooldown = 3600,
        Minitime = 1000,
        npc = true,
        ['npc'] = {
            text = "Roof Running Job",
            icon = 'fas fa-sign-in-alt',
            event = 'npc-quests:serverStart',
            ped = "a_m_m_eastsa_01",
            coords = vector4(-658.23, -1707.72, 23.84, 181.96),
        },
        ['target'] = {
            label = "Steal Components",
            icon = 'fa-solid fa-truck',
            event = 'npc-quests:cl:start',
        },
    },

    spawnedProps = {},
}

Config.AlarmAfter = 1 -- Failed attempts before alarm goes off
Config.maxFails = 1 -- Fails before job is abandoned
Config.MinUnits = 2
Config.MaxUnits = 2
Config.JobLength = 30 -- Minutes before job gets terminated

Config.Area = {
    vector3(-1221.96, -1067.69, 14.35),
    vector3(-575.50, -142.08, 51.99),
    vector3(-1282.18, -765.94, 28.77),
    vector3(-162.37, 315.10, 103.93),
    vector3(-1283.42, -849.34, 23.48),
    vector3(450.19, -1092.18, 43.06),
    vector3(-687.94, -152.82, 53.62),
}

Config.props = {
    [`prop_aircon_m_06`] = {
        'hvacblower',
        'hvaccompressor',
    },
    [`sum_prop_ac_aircon_02a`]= {
        'hvacblower',
        'hvaccompressor',
    },
    [`prop_aircon_m_04`]= {
        'hvacblower',
        'hvaccompressor',
    },
    [`prop_roofvent_06a`]= {
        'gturbinehead',
    },
}