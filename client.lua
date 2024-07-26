local PickUpClams = false
local ProcessClams = false

-- Main Thread Handling Input and State for All Activities
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50) -- Polling interval

        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)
        for _, activity in pairs(Config.activityConfigs) do
            local distance = #(pos - activity.location)

            if distance <= activity.distance then
                if activity.inWater and not IsEntityInWater(playerPed) then
                    --ESX.ShowNotification("You need to be in the water to " .. activity.helpText:lower())
                else
                    ESX.ShowHelpNotification(activity.helpText, false)
                    if IsControlJustReleased(0, 38) and not IsEntityDead(playerPed) and not _G[activity.flag] then
                        TriggerEvent(activity.startEvent)
                    end
                end
            end
        end
    end
end)

-- Generic Progressbar Function
function Progressbar(minTime, maxTime, progressBarText, animation, serverEvent, flagName)
    local waitTime = math.random(minTime, maxTime)
    _G[flagName] = true  -- Dynamically set the flag using the global table
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
            _G[flagName] = false  -- Reset the flag
            ClearPedTasks(PlayerPedId())
        end,
        onCancel = function()
            print("Action was cancelled")
            _G[flagName] = false  -- Reset the flag
            TriggerEvent('cancelAction')
        end,
    })
end

RegisterNetEvent('PickUpClams:start')
AddEventHandler('PickUpClams:start', function()
    local config = Config.activityConfigs.clams.progress
    Progressbar(config[1], config[2], config[3], config[4], config[5], Config.activityConfigs.clams.flag)
end)

RegisterNetEvent('ProcessPearls:start')
AddEventHandler('ProcessPearls:start', function()
    local config = Config.activityConfigs.pearls.progress
    Progressbar(config[1], config[2], config[3], config[4], config[5], Config.activityConfigs.pearls.flag)
end)

RegisterNetEvent('cancelAction')
AddEventHandler('cancelAction', function()
    print("Action is stopped")
    ClearPedTasks(PlayerPedId())
end)

-- Ensure the tasks are handled properly if something happens to the script
-- Ensure the script can handle resource crashes
--TODO CHECK FOR WATER AND VECHILES IS BROKEN