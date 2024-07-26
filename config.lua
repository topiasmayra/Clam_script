Config = {}

-- Define the price range for pearls
Config.PearlPrice = {
    min = 600,   -- Minimum price per pearl in currency
    max = 300   -- Maximum price per pearl in currency
}

-- Define the clam timer range
Config.clamtimer = {
    a = 5000, -- Minimum time (in milliseconds)
    b = 15000 -- Maximum time (in milliseconds)
}

Config.pearlprocesstimer = {
    a = 3000, -- Minimum time (in milliseconds)
    b = 12000 -- Maximum time (in milliseconds)
}


Config.amount = {
    a = 1,
    b = 5
}

-- Percentage of clams returned when opened at a different location (30%)
Config.ClamReturnPercentage = 30

-- Define  locations for clams pools and pearl process palace
Config.locations = {
    Clam_processing_place = vector3(1343.2782, 4390.6299, 44.3437),
    clam_pool = vector3(-3114.4387, 8.2212, -2.4179) 
}

Config.activityConfigs = {
    clams = {
        location = Config.locations.clam_pool,
        distance = 40.0,
        startEvent = 'PickUpClams:start',
        helpText = "Press E to pick up some clams",
        water = "to pick up some clams",
        inWater = true,
        flag = 'PickUpClams',
        progress = {Config.clamtimer.a, Config.clamtimer.b, "Digging up clams", "WORLD_HUMAN_GARDENER_PLANT", 'Giveclams'}
    },
    pearls = {
        location = Config.locations.Clam_processing_place,
        distance = 5.0,
        startEvent = 'ProcessPearls:start',
        helpText = "Press E to start processing the pearls",
        inWater = false,
        flag = 'ProcessClams',
        progress = {Config.pearlprocesstimer.a, Config.pearlprocesstimer.b, "Opening Clams", "WORLD_HUMAN_VEHICLE_MECHANIC", 'Pearlprocess'}
    }
}
