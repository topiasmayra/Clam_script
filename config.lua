Config = {}

-- Define the price range for pearls
Config.PearlPrice = {
    min = 600,   -- Minimum price per pearl in currency
    max = 3000   -- Maximum price per pearl in currency
}

-- Define the clam timer range
Config.clamtimer = {
    a = 5000, -- Minimum time (in milliseconds)
    b = 15000 -- Maximum time (in milliseconds)
}

-- Percentage of clams returned when opened at a different location (30%)
Config.ClamReturnPercentage = 30

-- Define  locations for clams pools and pearl process palace
Config.locations = {
    Clam_processing_place = vector3(1319.8193, 4312.1816, 38.1064),
    clam_pool = vector3(-3114.4387, 8.2212, -2.4179) 
}

Config.objects={
    pearl_bench = 'prop_tool_bench02_ld'
}

-- Define Buttons that this resource is using 
