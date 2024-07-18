PickUpClams = false

-- Main Thread Handling Input and State
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)
        local clamLocation = Config.locations.clam_pool
        local distance = #(pos - clamLocation)

        if IsControlJustReleased(0, 38) then
            if distance <= 40.0 and not IsEntityDead(playerPed) and IsEntityInWater(playerPed) then
                ESX.ShowFloatingHelpNotification("Press E to pick up some clams",pos) 
                if PickUpClams == true then
                    TriggerEvent('PickUpClams:stop')
                    ESX.ShowNotification("Stopped digging up clams")
                else

                    TriggerServerEvent('PickUpClams')
                end
            end
        end
    end
end)



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


local modelHash = Config.objects.pearl_bench -- The ` return the jenkins hash of a string. see more at: https://cookbook.fivem.net/2019/06/23/lua-support-for-compile-time-jenkins-hashes/

if not HasModelLoaded(modelHash) then
    -- If the model isnt loaded we request the loading of the model and wait that the model is loaded
    RequestModel(modelHash)

    while not HasModelLoaded(modelHash) do
        Citizen.Wait(1)
    end
end





--TO DO WHY Stop clam stuff when canceled
-- TO DO Only run for player who have fork equipt  and are in area 
--To do list player who are in clam area.