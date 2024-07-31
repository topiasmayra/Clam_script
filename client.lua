local PickUpClams = false
local ProcessClams = false
local questionTimer = 0
local questionDuration = Config.pearlprocesstimer.a  -- 20 seconds in milliseconds
local questionAnswered = false
-- Main Thread Handling Input and State for All Activities
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50) -- Polling interval

        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)
        for _, activity in pairs(Config.activityConfigs) do
            local distance = #(pos - activity.location)

            if distance <= activity.distance then
                if  activity.inWater and not IsEntityInWater(playerPed) then
                    ESX.ShowNotification("You need to be in the water to " .. activity.helpText:lower())
                else
                    ESX.ShowHelpNotification(activity.helpText, false)
                    if IsControlJustReleased(0, Config.inputs.Pick_up) and not IsEntityDead(playerPed) and not _G[activity.flag] then
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
            _G[flagName] = false  -- Reset the flag
            TriggerEvent('cancelAction')
        end,
    })
end
function DisableAllActions()
    actions_to_disable = {
        Config.inputs.key_true_answer
        key_false_answer',
        'Pick_up'
    }
    for _, action in ipairs(actions_to_disable) do
        local control = Config.inputs[action]
        if control then
            DisableControlAction(0, control, true)




RegisterNetEvent('PickUpClams:start')
AddEventHandler('PickUpClams:start', function()
    local config = Config.activityConfigs.clams.progress
    Progressbar(config[1], config[2], config[3], config[4], config[5], Config.activityConfigs.clams.flag)
end)

RegisterNetEvent('cancelAction')
AddEventHandler('cancelAction', function()
    print("Action is stopped")
    ClearPedTasks(PlayerPedId())
end)


RegisterNetEvent('ProcessPearls:start')
AddEventHandler('ProcessPearls:start', function()

TriggerServerEvent('FactGame:RequestQuestion')
end)




RegisterNetEvent('FactGame:ReceiveQuestion')
AddEventHandler('FactGame:ReceiveQuestion', function(fact, isTrue)
    currentQuestion = fact
    currentCorrectAnswer = isTrue
    questionTimer = GetGameTimer() + questionDuration
    questionAnswered = false
    ESX.ShowNotification("Question: " .. fact, "info", questionDuration)
end)


RegisterNetEvent('FactGame:AnswerResult')
AddEventHandler('FactGame:AnswerResult', function(isCorrect)
    if isCorrect then
        ESX.ShowNotification("Correct!",'success')
        questionAnswered = true
        TriggerServerEvent('Pearlprocess')
    else
        ESX.ShowNotification("Incorrect!", "error")
        questionAnswered = true


    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Check if there's a current question
        if currentQuestion then
            -- Handle user input
            if IsControlJustReleased(0, Config.inputs.key_true_answer) then
                TriggerServerEvent('FactGame:CheckAnswer', currentQuestion, true)
                TriggerEvent('cancelAction')
                
            elseif IsControlJustReleased(0, Config.inputs.key_false_answer) then
                TriggerServerEvent('FactGame:CheckAnswer', currentQuestion, false)
                TriggerEvent('cancelAction')
            end

            -- Check if the time has expired
            if GetGameTimer() > questionTimer and not questionAnswered  then
                ESX.ShowNotification("Time is up! Your brain was too slow.", "error")
                currentQuestion = nil  -- Clear the question after time expires
                TriggerEvent('cancelAction')
            end
        end
    end
end)


-- Ensure the script can handle resource crashes
--TODO CHECK FOR WATER AND VECHILES IS BROKEN
--TODO OPTIMIZE CODE 
--TODO MAKE RESCOURSE SLEEP UNTIL TIMERS HAVE EXPIRED AND 

--------------------

--PEARLS PROSESSING

--------------------

-- TODO Disable compat and moment for questin asnwer part 
-- FIX WHY DOS NOT TELL YOU IF YOU HAVE ENOUGHT CLAMS TO PROCESS before progress bar starts
-- TODO MAKE PUNISHMENT TIMER IF YOU GET QUESTION WRONG THAT IS RANDOM  sleep wait make 2 of it if answer correct
-- CHECK SERVER SIDE NOTES FOR LUCK PART 




------------------------
-- READ https://forum.cfx.re/t/help-add-markers-to-map-blips/108199/3

