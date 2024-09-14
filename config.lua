Config = {}

-- Waypoint NPC (Middle Man)
Config.WaypointNpcModel = 's_m_m_highsec_01'
Config.WaypointLocations = {
    { coords = vector3(-817.1472, -705.3156, 126.3867), heading = 157.5160 },
    { coords = vector3(-101.1561, 997.9279, 239.2796), heading = 122.4672 },
    { coords = vector3(81.3099, 274.5243, 110.2102), heading = 156.4052 },
    { coords = vector3(-69.3267, 63.4659, 71.8882), heading = 143.2031 },
    { coords = vector3(17.7753, -13.1935, 70.1162), heading = 359.4085 },
    -- Add more locations here
}
Config.WaypointToPlugCost = 2000
Config.WaypointToGunNpcCost = 5000

-- Shop NPC (Plug)
Config.ShopNpcModel = 's_m_y_dealer_01'
Config.ShopLocations = {
    { coords = vector3(-1118.3594, -1439.7817, 5.1075), heading = 304.2598 },
    { coords = vector3(-225.0153, 6450.6479, 31.4500), heading = 308.8816 },
    { coords = vector3(-230.4982, 488.2544, 128.7681), heading = 8.1877 },
    { coords = vector3(-355.7674, 469.9154, 112.4876), heading = 309.5681 },
    { coords = vector3(-558.6229, 209.3587, 78.5519), heading = 327.9945 },
    -- Add more locations here
}
Config.PlugJailLocation = { coords = vector3(461.4039, -993.9234, 23.9148), heading = 273.8840 }
Config.PurchaseThreshold = 5
Config.SnitchChance = 20 -- Chance to alert cops (in percentage)
Config.JailChance = 30 -- Chance to jail the NPC (in percentage)

-- Items sold by Plug NPC
Config.PlugItems = {
    { name = 'cokekilo', label = 'buy_kilo_coke', price = 20000 },
    { name = 'weedkilo', label = 'buy_kilo_weed', price = 1200 },
    { name = 'heroinkilo', label = 'buy_kilo_heroin', price = 40000 },
    { name = 'methkilo', label = 'buy_kilo_meth', price = 55000 },
    -- Add more items here
}

-- Gun NPC
Config.GunNpcModel = 's_m_y_ammucity_01'
Config.GunNpcLocations = {
    { coords = vector3(-597.3143, 225.8833, 74.1960), heading = 174.5645 },
    { coords = vector3(1667.9663, 3744.2365, 35.0038), heading = 290.6526 },
    { coords = vector3(-534.4888, -166.3661, 38.3247), heading = 348.7963 },
    { coords = vector3(-455.7013, -18.9947, 46.1040), heading = 349.5627 },
    { coords = vector3(-360.1872, 21.2164, 47.8590), heading = 5.4943 },
    { coords = vector3(-302.8107, 85.2243, 72.6621), heading = 90.5379 },
    -- Add more locations here
}
Config.GunJailLocation = { coords = vector3(460.6814, -992.9800, 24.9148), heading = 355.8023 }

-- Items sold by Gun NPC
Config.GunItems = {
    { name = 'weapon_pistol', label = 'buy_pistol', price = 10000 },
    { name = 'weapon_smg', label = 'buy_smg', price = 25000 },
    { name = 'weapon_shotgun', label = 'buy_shotgun', price = 35000 },
    { name = 'weapon_rifle', label = 'buy_rifle', price = 50000 },
    -- Add more items here
}

-- Cop NPC for bail
Config.CopNpcModel = 's_m_y_cop_01'
Config.CopNpcLocation = { coords = vector3(459.7331, -989.1182, 23.9148), heading = 266.6240 }
Config.BailAmount = 250000

-- Misc
Config.LocationChangeInterval = 3600000 -- 1 hour in milliseconds
