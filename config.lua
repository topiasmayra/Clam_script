Config = {}

Config.inputs = {
    key_true_answer = 44, -- 1
    key_false_answer = 45,-- 2
    Pick_up = 38 -- E
}



-- Define the clam timer range
Config.clamtimer = {
    a = 5000, -- Minimum time (in milliseconds)
    b = 15000 -- Maximum time (in milliseconds)
}

Config.pearlprocesstimer = {
    timer = 2000,
    a = 3000,    
    b = 90000

}


Config.amount = {
    a = 1,
    b = 5,
    c = 2,
    pearl_process_tax = 2
}


-- Define  locations for clams pools and pearl process palace
Config.locations = {
    ClamProcessingPlace = vector3(1343.2782, 4390.6299, 44.3437),
    ClamPool = vector3(-3114.4387, 8.2212, -2.4179),
    PearlBlackMarket  = vector3(1511.6173, 3782.2073, 32.9000),
    PearlBlackMarketHeading = 131.2619
}

local keyNames = {
    [38] = "E",
    [44] = "Q",
    [45] = "R",
    -- Add more key mappings as needed
}
Config.activityConfigs = {
    clams = {
        location = Config.locations.ClamPool,
        distance = 40.0,
        startEvent = 'PickUpClams:start',
        helpText = "Press "  .. keyNames[Config.inputs.Pick_up] .. " to pick up some clams",
        water = "to pick up some clams",
        inWater = true,
        flag = 'PickUpClams',
        progress = {Config.clamtimer.a, Config.clamtimer.b, "Digging up clams", "WORLD_HUMAN_GARDENER_PLANT", 'Giveclams'}
    },
    pearls = {
        location = Config.locations.ClamProcessingPlace,
        distance = 0.5,
        startEvent = 'ProcessPearls:start',
        helpText = "Press " ..keyNames[Config.inputs.Pick_up] .. " to start processing the pearls",
        inWater = false,
        flag = 'ProcessPearls',
    },
    pearlSelling = {
        location = Config.locations.PearlBlackMarket,
        distance = 1.0,
        startEvent = 'SellPearls:start',
        helpText = "Press " .. keyNames[Config.inputs.Pick_up] .. " to sell pearls",
        flag = 'SellPearls',
        shopkeeper = 'a_f_m_fatcult_01',
        price = {
            min = 500,
            max = 3000
        }
    }
}

--Facts about Seals 
Config.sealfacts = {
    {
        fact = "Seals are mammals.",
        isTrue = true
    },
    {
        fact = "All seals live in freshwater habitats.",
        isTrue = false
    },
    {
        fact = "Seals can hold their breath for up to two hours.",
        isTrue = true
    },
    {
        fact = "Seals primarily eat plants.",
        isTrue = false
    },
    {
        fact = "There are more than 30 species of seals.",
        isTrue = true
    },
    {
        fact = "Seals have fur.",
        isTrue = true
    },
    {
        fact = "Seals are cold-blooded animals.",
        isTrue = false
    },
    {
        fact = "Seals can sleep underwater.",
        isTrue = true
    },
    {
        fact = "All seals have external ears.",
        isTrue = false
    },
    {
        fact = "Seals communicate through vocalizations and body language.",
        isTrue = true
    },
    {
        fact = "Seals are also known as pinnipeds.",
        isTrue = true
    },
    {
        fact = "Some seals can live up to 40 years.",
        isTrue = true
    },
    {
        fact = "Seals are closely related to dolphins.",
        isTrue = false
    },
    {
        fact = "Seals can swim at speeds up to 25 miles per hour.",
        isTrue = true
    },
    {
        fact = "Seals are found in all oceans of the world.",
        isTrue = true
    },
    {
        fact = "Seals can only live in cold climates.",
        isTrue = false
    },
    {
        fact = "Seals have a layer of blubber to keep them warm.",
        isTrue = true
    },
    {
        fact = "Seals give birth on land or ice.",
        isTrue = true
    },
    {
        fact = "Seals are capable of echolocation.",
        isTrue = false
    },
    {
        fact = "Seals' whiskers are sensitive to vibrations in the water.",
        isTrue = true
    },
    {
        fact = "Seals use tools to hunt for food.",
        isTrue = false
    },
    {
        fact = "Seals can dive to depths of over 1,500 meters.",
        isTrue = true
    },
    {
        fact = "Seals are nocturnal hunters.",
        isTrue = true
    },
    {
        fact = "All seal species are endangered.",
        isTrue = false
    },
    {
        fact = "Seals have been known to eat penguins.",
        isTrue = true
    },
    {
        fact = "Seals are social animals that live in groups called pods.",
        isTrue = false
    },
    {
        fact = "Seals molt their fur once a year.",
        isTrue = true
    },
    {
        fact = "Seals' eyesight is better underwater than on land.",
        isTrue = true
    },
    {
        fact = "Seals are herbivores.",
        isTrue = false
    },
    {
        fact = "The largest species of seal is the elephant seal.",
        isTrue = true
    },
    {
        fact = "Seals cannot hear underwater.",
        isTrue = false
    },
    {
        fact = "Seals can stay underwater for up to 30 minutes.",
        isTrue = true
    },
    {
        fact = "Seals use their tails for swimming.",
        isTrue = false
    },
    {
        fact = "Seals are capable of rapid bursts of speed to catch prey.",
        isTrue = true
    },
    {
        fact = "Seals live solitary lives except during mating season.",
        isTrue = false
    },
    {
        fact = "The average lifespan of a seal in the wild is about 20-30 years.",
        isTrue = true
    },
    {
        fact = "Seals' primary predators are sharks and orcas.",
        isTrue = true
    },
    {
        fact = "Seals are found in both the Arctic and Antarctic regions.",
        isTrue = true
    },
    {
        fact = "Seals are born with the ability to swim.",
        isTrue = false
    },
    {
        fact = "Seals' fur provides camouflage from predators.",
        isTrue = true
    },
    {
        fact = "Seals can migrate thousands of miles annually.",
        isTrue = true
    },
    {
        fact = "Seals have been domesticated by humans.",
        isTrue = false
    },
    {
        fact = "Seals' teeth are adapted for catching and eating fish.",
        isTrue = true
    },
    {
        fact = "Seals communicate using a variety of sounds, including barks and grunts.",
        isTrue = true
    },
    {
        fact = "Seals have a highly developed sense of smell.",
        isTrue = false
    },
    {
        fact = "Seal pups are nursed by their mothers for several months.",
        isTrue = true
    },
    {
        fact = "Seals can live in both saltwater and freshwater environments.",
        isTrue = true
    },
    {
        fact = "Seals are known for their playful behavior.",
        isTrue = true
    },
    {
        fact = "Seals are immune to many marine toxins.",
        isTrue = false
    },
    {
        fact = "Seals' flippers are used for both swimming and walking on land.",
        isTrue = true
    }
}