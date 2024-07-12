local PickUpClams = false

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(5)

        if IsControlJustReleased(0, 38) then
            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)
            local clamLocation = vector3(-3114.4387, 8.2212, -2.417)
            local distance = #(pos - clamLocation)

            if PickUpClams then
                PickUpClams = false
                ESX.ShowNotification("Stopped picking clams")
                ClearPedTasks(playerPed)
            else
                if distance < 40.0 and IsEntityInWater(playerPed) then
                    ESX.ShowNotification("You are picking up clams - Press E again to stop")
                    TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_ATM", 0, true)
                    PickUpClams = true
                else
                    ESX.ShowNotification("You are not near clams or not in water!")
                end
            end
        end

        if PickUpClams then
            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)
            local clamLocation = vector3(-2500.0000, -2000.0000, 0.0000)
            local distance = #(pos - clamLocation)
            
            if distance > 40.0 or IsEntityDead(playerPed) then 
                PickUpClams = false
                ESX.ShowNotification("Stopped picking clams")
                ClearPedTasks(playerPed)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local waitTime = math.random(Config.clamtimer.a, Config.clamtimer.b)
        Citizen.Wait(waitTime)
        
        if PickUpClams then
            disableMovement = true
            disableMouse = true
            disableCombat = true
            FreezePlayer = true
            
            ESX.ShowNotification("You are picking up clams!")

            Citizen.Wait(5000)  -- Wait for 5 seconds (adjust as needed)
            
            disableMovement = false
            disableMouse = false
            disableCombat = false
            FreezePlayer = false
        end
    end
end)

RegisterNetEvent('PickUpClams:stop')
AddEventHandler('PickUpClams:stop', function()
    PickUpClams = false
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('PickUpClams:start')
AddEventHandler('PickUpClams:start', function()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    local clamLocation = vector3(-2500.0000, -2000.0000, 0.0000)
    local distance = #(pos - clamLocation)
    
    if IsPedInAnyVehicle(playerPed, true) then 
        ESX.ShowAdvancedNotification("You cannot pick up clams while inside a vehicle!")
    else
        if distance < 40.0 and IsEntityInWater(playerPed) then
            ESX.ShowNotification("You are picking up clams - Press E again to stop")
            TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_ATM", 0, true)
            PickUpClams = true
        end
    end
end)
