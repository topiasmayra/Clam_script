local PickUpClams = false

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(5) 
    
        if IsControlJustReleased(0, 38) then
            PickUpClams = false
            ESX.ShowNotification("Stopped Picking clams")
            ClearPedTasks(PlayerPedId())
        end

        if PickUpClams then
            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)
            local PearlPos = vector3(-2500.0000, -2000.0000, 0.0000)
            
            -- Calculate distance between player position and target position
            local distance = #(pos - PearlPos)
            
            -- Check conditions to stop picking clams
            if distance > 1.0 or IsPedInAnyVehicle(playerPed()) or IsEntityDead(playerPed()) then 
                PickUpClams = false
                ESX.ShowNotification("Stopped Picking clams")
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local waitTime = math.random(Config.clamtimer.a, Config.clamtimer.b)
        Wait(waitTime)
        
        if PickUpClams then
            -- Disable movement, mouse, combat, and freeze the player
            disableMovement = true
            disableMouse = true
            disableCombat = true
            FreezePlayer = true
            
            ESX.ShowNotification("You are picking up clams!")

            -- Simulate clam picking process (replace with your logic)
            Citizen.Wait(5000)  -- Example: Wait for 5 seconds (adjust as needed)
            
            -- Restore player controls
            disableMovement = false
            disableMouse = false
            disableCombat = false
            FreezePlayer = false
        end
    end
end)

RegisterNetEvent('PickUpClams:stop')
AddEventHandler('fPickUpClams:stop', function()
	fishing = false
	ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('PickUpClams:start')
AddEventHandler('PickUpClams:start', function ()
    local player_id = PlayerPedId()
    local pos = GetEntityCoords(playerPed())
    local clams = Config.ClamLocations.clam_pick_up
    if IsPedInAnyVehicle(player_id()) then 
        ESX.ShowAdvancedNotification("You Can not pick up clams while inside a vechile!")
    else
        if #(pos - clams) < 40 and IsEntityInWater(player_id())  then
            ESX.ShowNotification("You are picking up clams - Press E again to stop ")
            TaskStartScenarioInPlace(player_id(), "PROP_HUMAN_ATM", 0 , true)
            PickUpClams = true
        else 
            ESX.ShowNotification("You are not near clams or not in water!")
            ClearPedTasks(player_id())
        end
    end
end)