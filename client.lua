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
                    ESX.ShowNotification("You need to be in the water to " .. activity.helpText:lower())
                else
                    ESX.ShowHelpNotification(activity.helpText, false)
                    if IsControlJustReleased(0, Config.inputs.Pick_up) and not IsEntityDead(playerPed) and not _G[activity.flag] then
                        TriggerEvent(activity.startEvent)
                       TriggerServerEvent('FactGame:RequestQuestion')
                        --REMOVE THIS AFTER WE KNOW QUESTION LOGIC WORKS
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
            CurrentQuestion = nil
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


-- Request question function
local function requestQuestion(callback)
    RegisterNetEvent('FactGame:ReceiveQuestion')
    AddEventHandler('FactGame:ReceiveQuestion', function(fact, isTrue)  
        if callback then
            callback(fact, isTrue)
        end
    end)
    TriggerServerEvent('FactGame:RequestQuestion')
end

-- Process Pearls event
RegisterNetEvent('ProcessPearls:start')
AddEventHandler('ProcessPearls:start', function()
    requestQuestion(function(question, isTrue)
        print("Question: " .. question)
        CurrentQuestion = question
        
        local config = Config.activityConfigs.pearls.progress
        Progressbar(config[1], config[2], question, config[4], config[5], Config.activityConfigs.pearls.flag)
    end)
end)


RegisterNetEvent('cancelAction')
AddEventHandler('cancelAction', function()
    print("Action is stopped")
    ClearPedTasks(PlayerPedId())
    CurrentQuestion = nil
end)


RegisterNetEvent('FactGame:AnswerResult')
AddEventHandler('FactGame:AnswerResult', function(isCorrect)
    if isCorrect then
        ESX.ShowNotification("Correct!",'success')
    else
        ESX.ShowNotification("Incorrect!", "error")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if CurrentQuestion then
            if IsControlJustReleased(0, Config.inputs.key_true_answer) then
                print("True key pressed")
                TriggerServerEvent('FactGame:CheckAnswer', CurrentQuestion, true)
                CurrentQuestion = nil  -- Clear the question after answering
            elseif IsControlJustReleased(0, Config.inputs.key_false_answer) then
                TriggerServerEvent('FactGame:CheckAnswer', CurrentQuestion, false)
                CurrentQuestion = nil  -- Clear the question after answering
            end
        end
    end
end)

-- Ensure the script can handle resource crashes
--TODO CHECK FOR WATER AND VECHILES IS BROKEN
-- READ https://forum.cfx.re/t/help-add-markers-to-map-blips/108199/3
-- TODO ADD LOGIC FOR PROGRESS BAR SO YOU HAVE X AMOUNT TIME FOR ANSWERIGN QUESTION
--FIX WHY DOS NOT TELL YOU IF YOU HAVE ENOUGHT CLAMS TO PROCESS before progress bar starts