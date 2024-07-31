-- Define global flags and state variables
local PickUpClams = false
local ProcessClams = false
local questionTimer = 0
local questionDuration = Config.pearlprocesstimer.timer -- Duration for the question
local questionAnswered = false
local punishmentTimer = 0
local currentQuestion = nil
local currentCorrectAnswer = nil
local actionInProgress = false  -- Flag to track if an action is in progress
local isPunished = false  -- Flag to track if the player is under punishment

-- Main Thread Handling Input and State for All Activities
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100) -- Polling interval

        -- Only proceed if no action or timer is active
        if not actionInProgress and not isPunished then
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
                            actionInProgress = true  -- Set flag to true when an action starts
                        end
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
    actionInProgress = true  -- Set flag to true when an action starts
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
            actionInProgress = false  -- Reset the action flag
            ClearPedTasks(PlayerPedId())
        end,
        onCancel = function()
            _G[flagName] = false  -- Reset the flag
            actionInProgress = false  -- Reset the action flag
            TriggerEvent('cancelAction')
        end,
    })
end

-- Event handlers for actions
RegisterNetEvent('PickUpClams:start')
AddEventHandler('PickUpClams:start', function()
    local config = Config.activityConfigs.clams.progress
    Progressbar(config[1], config[2], config[3], config[4], config[5], Config.activityConfigs.clams.flag)
end)

RegisterNetEvent('cancelAction')
AddEventHandler('cancelAction', function()
    print("Action is stopped")
    ClearPedTasks(PlayerPedId())
    actionInProgress = false  -- Reset the action flag
end)

RegisterNetEvent('ProcessPearls:start')
AddEventHandler('ProcessPearls:start', function()
    if not isPunished then
        TriggerServerEvent('FactGame:RequestQuestion')
    else
        ESX.ShowNotification("You must wait until your punishment timer expires before processing pearls.", "error")
    end
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
        ESX.ShowNotification("Correct!", 'success')
        questionAnswered = true
    else
        ESX.ShowNotification("Incorrect!", "error")
        questionAnswered = true
        punishmentTimer = GetGameTimer() + math.random(Config.pearlprocesstimer.a, Config.pearlprocesstimer.b)
        isPunished = true  -- Set punishment flag to true
    end
end)

-- Thread to handle question responses, timeouts, and punishment
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Check if there's a current question
        if currentQuestion then
            -- Handle user input for answering the question
            if IsControlJustReleased(0, Config.inputs.key_true_answer) then
                TriggerServerEvent('FactGame:CheckAnswer', currentQuestion, true)
                TriggerEvent('cancelAction')
            elseif IsControlJustReleased(0, Config.inputs.key_false_answer) then
                TriggerServerEvent('FactGame:CheckAnswer', currentQuestion, false)
                TriggerEvent('cancelAction')
            end

            -- Handle question timeout
            if GetGameTimer() > questionTimer and not questionAnswered then
                ESX.ShowNotification("Time is up! Your brain was too slow.", "error")
                currentQuestion = nil  -- Clear the question after time expires
                TriggerEvent('cancelAction')
                TriggerServerEvent('FactGame:GivePearlsWrongAnswer')
            end
        end

        -- Handle punishment timer
        if isPunished and GetGameTimer() > punishmentTimer then
            isPunished = false  -- Reset the punishment flag
            ESX.ShowNotification("You can now process pearls again.", "success")
        end
    end
end)