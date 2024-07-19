PickUpClams = false

-- Main Thread Handling Input and State
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)
        local clamLocation = Config.locations.clam_pool
        local distance = #(pos - clamLocation)

        if IsControlJustReleased(0, 38)  and not IsEntityDead(playerPed) and IsEntityInWater(playerPed) then
            if distance <= 40.0  then
                ESX.ShowHelpNotification("Press E to pick up some clams", false)
                    TriggerServerEvent('PickUpClams')
                end
            end
        end
end)



function DigUpClams()
    local waitTime = math.random(Config.clamtimer.a, Config.clamtimer.b)
    PickUpClams = true
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
        end,
        onCancel = function()
            print("I was canCancel")
            TriggerEvent('PickUpClams:stop')
        end,
    })
end


RegisterNetEvent('PickUpClams:stop')
AddEventHandler('PickUpClams:stop', function()
    print("pick up clams stop is called")
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
            ESX.ShowNotification("You are picking up clams - Press Backspace again to stop")
            DigUpClams()
        else
            ESX.ShowNotification("You need to be in the water to pick up clams.")
        end
    end
end)  

--To do list player who are in clam area.