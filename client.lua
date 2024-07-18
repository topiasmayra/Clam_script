PickUpClams = false

-- Main Thread Handling Input and State
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustReleased(0, 38) then
            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)
            local clamLocation = Config.locations.clam_pool
            local distance = #(pos - clamLocation)

            if distance <= 40.0 and not IsEntityDead(playerPed) then
                if PickUpClams then
                    TriggerEvent('PickUpClams:stop')
                    ESX.ShowNotification("Stopped digging up clams")
                else
                    TriggerEvent('PickUpClams:start')
                end
            else
                ESX.ShowNotification("You are too far from the clam location")
            end
        end
    end
end)

-- Thread Handling Clam Pickup Process
Citizen.CreateThread(function()
    while true do
        if PickUpClams then
            local waitTime = math.random(Config.clamtimer.a, Config.clamtimer.b)

            ESX.Progressbar("Digging up clams", waitTime, {
                duration = waitTime,
                label = "Digging up clams",
                useWhileDead = false,
                canCancel = true,
                controlDisables = {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                },
                animation = {
                    task = "WORLD_HUMAN_GARDENER_PLANT",
                },
                prop = {
                    model = "prop_tool_shovel",
                    bone = 57005,
                    coords = { x = 0.1, y = 0.0, z = 0.0 },
                    rotation = { x = 0.0, y = 0.0, z = 180.0 },
                },
            })

            Citizen.Wait(waitTime)
            
            TriggerServerEvent('PickUpClams')
            print("print Wait time")
        end

        Citizen.Wait(500) -- Prevent tight loop
        print ("What is this?")
    end
end)

-- Events for Starting and Stopping Clam Pickup
RegisterNetEvent('PickUpClams:stop')
AddEventHandler('PickUpClams:stop', function()
   print("pick up clams stop is called")
    PickUpClams = false
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('PickUpClams:start')
AddEventHandler('PickUpClams:start', function()
    local playerPed = PlayerPedId()
    
    if IsPedInAnyVehicle(playerPed, true) then
        ESX.ShowAdvancedNotification("You cannot pick up clams while inside a vehicle!")
    else
        if IsEntityInWater(playerPed) then
            ESX.ShowNotification("You are picking up clams - Press E again to stop")

        else
            ESX.ShowNotification("You need to be in the water to pick up clams.")
        end
    end
end)
--TO DO WHY DOS NOT STO PICK UP CLAMS DUPLICATED ACTIONS