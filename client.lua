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
            PickUpClams = false
            ClearPedTasks(PlayerPedId())
        end,
        onCancel = function()
            print("I was canCancel")
            PickUpClams = false
            TriggerEvent('PickUpClams:stop')
        end,
    })
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
            ESX.ShowNotification("You are picking up clams - Press Backspace again to stop")
            DigUpClams()
        else
            ESX.ShowNotification("You need to be in the water to pick up clams.")
        end
    end
end)  


-- Pearl part

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)
        local pearlLocation = Config.locations.Clam_processing_place
        local distance = #(pos - pearlLocation)
        
        if distance <= 5 then
            ESX.ShowHelpNotification("Press E to start processing the pearls")
        end
        if IsControlJustReleased(0, 38) then
            Processpearls()
        end  
    end
end)


function Processpearls()
    local waitTime = math.random(Config.pearlprocesstimer.a, Config.pearlprocesstimer.b)
    local playerPed = PlayerPedId()
    
    if processclams == false then
        ESX.Progressbar("Oppening clams", waitTime, {
            processclams = true,
            FreezePlayer  = true,
            label = "Oppening clams",
            useWhileDead = false,
            canCancel = true,
            TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_BUM_WASH", 0, true),
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            onFinish = function()
                TriggerServerEvent('Pearlprocess')
                ClearPedTasks(PlayerPedId())
            end,
            onCancel = function()
                ClearPedTasks(PlayerPedId())
            end,
        })
    else
        processclams = false 
    end
end


-- TODOD  check if code needs run every tick 
-- TODO test fact game for pearl process
--To do list player who are in clam area.
--TODO MAKE SURE TASKSCNEARIO IS CALCLED IF SOMETHING HAPPENS TO SCRIPT. 