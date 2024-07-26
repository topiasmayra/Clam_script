local PickUpClams = false
local processclams = false

-- Main Thread Handling Input and State
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50)
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)
        local clamLocation = Config.locations.clam_pool
        local distance = #(pos - clamLocation)

        if IsControlJustReleased(0, 38)  and not IsEntityDead(playerPed) and IsEntityInWater(playerPed) then
            if distance <= 40.0 and PickUpClams == false then 
                ESX.ShowHelpNotification("Press E to pick up some clams", false)
                    TriggerServerEvent('PickUpClams') 
            else
            ESX.ShowNotification("You are not nearby a clam area")
            end        
        end   
        end
end)


function Progressbar(minTime, maxTime, progressBarText, animation, serverEvent,flag)
    local waitTime = math.random(minTime, maxTime)
    flag = true  -- Dynamically set the flag using the global table
    print(waitTime .. " seconds")
    ESX.Progressbar(progressBarText, waitTime, {
        FreezePlayer = true,
        label = progressBarText,
        useWhileDead = false,
        canCancel = true,
        TaskStartScenarioInPlace(PlayerPedId(), animation, 0, true),
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        onFinish = function()
            TriggerServerEvent(serverEvent)
            flag = false  -- Reset the flag
            print(flag)
            ClearPedTasks(PlayerPedId())
        end,
        onCancel = function()
            print("I was canCancel")
            _G[flag] = false  -- Reset the flag
            TriggerEvent('cancelAction')
        end,
    })
end


function DigUpClams()
    Progressbar(Config.clamtimer.a, Config.clamtimer.b, "Digging up clams", "WORLD_HUMAN_GARDENER_PLANT", 'Giveclams',"PickUpClams")
end

RegisterNetEvent('cancelAction')
AddEventHandler('cancelAction', function()
    print("Action is stopped")
    ClearPedTasks(PlayerPedId())
end)




function Processpearls()
    print('hello')
    Progressbar(Config.pearlprocesstimer.a, Config.pearlprocesstimer.b, "Openning Clmas", "WORLD_HUMAN_VEHICLE_MECHANIC", 'Pearlprocess',"PickUpClams")
end


-- Pearl part

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)
        local pearlLocation = Config.locations.Clam_processing_place
        local distance = #(pos - pearlLocation)
        local processarea = false
        if distance <= 5 then
            processarea = true
            ESX.ShowHelpNotification("Press E to start processing the pearls")
            Wait(50)
        end
            if IsControlJustReleased(0, 38) and processarea == true then
            Processpearls()  
        else 
        processarea = false
        end
    end
end)

-- TODOD  check if code needs run every tick 
-- TODO test fact game for pearl process
--To do list player who are in clam area.
--TODO MAKE SURE TASKSCNEARIO IS CALCLED IF SOMETHING HAPPENS TO SCRIPT. 
--TODO MAKE SURE SCIRPT CAN HANDLE RESCOURSE CRASH