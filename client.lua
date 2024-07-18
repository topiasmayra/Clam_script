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
                if PickUpClams == true then
                    TriggerEvent('PickUpClams:stop')
                    ESX.ShowNotification("Stopped digging up clams")
                    
                else
                    print(PickUpClams)
                    TriggerServerEvent('PickUpClams')
                end
            else
                ESX.ShowNotification("You are too far from the clam location")
            end
        end
    end
end)

-- Thread Handling Clam Pickup Process
function DigUpClams()
    local waitTime = math.random(Config.clamtimer.a, Config.clamtimer.b)

    ESX.Progressbar("Digging up clams", waitTime, {
        FreezePlayer  = true,
        label = "Digging up clams",
        useWhileDead = false,
        canCancel = true,
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true),
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        
        onFinish = function()
            TriggerServerEvent('Giveclams')
    
        end})

    end 




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
            PickUpClams = true
            ESX.ShowNotification("You are picking up clams - Press E again to stop")
            DigUpClams()

            
        else
            ESX.ShowNotification("You need to be in the water to pick up clams.")
        end
    end
end)
--TO DO WHY Stop clam stuff when cancled