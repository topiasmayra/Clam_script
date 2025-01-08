-- Function to initialize variables
local function initializeVariables()
    playerPed = PlayerPedId()
    playerPos = GetEntityCoords(playerPed)
    debounceInterval = 300 -- milliseconds
    lastInputTime = 0
    lastNotificationTime = 0

    -- Flags and timers
    flags = {
        PickUpClams = false,
        ProcessClams = false,
        actionInProgress = false,
        isPunished = false
    }

    timers = {
        questionTimer = 0,
        questionDuration = Config.pearlprocesstimer.timer,
        punishmentTimer = 0
    }

    currentQuestion = nil
    currentCorrectAnswer = nil
    questionAnswered = false
    firstQuestion = true

    cachedConfig = {
        pearlSellingLocation = Config.activityConfigs.pearlSelling.location,
        clamProgressConfig = Config.activityConfigs.clams.progress,
        pearlModelHash = GetHashKey('a_f_m_fatcult_01'),
        activityConfigs = Config.activityConfigs
    }
end

-- Initialize variables on script start
initializeVariables()

-- Make sure that Ped has been spawned before proceeding
AddEventHandler('playerSpawned', function()
    playerPed = PlayerPedId()
    print("Player spawned. Local playerPed: " .. tostring(playerPed))
end)

-- Handle resource reset
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        initializeVariables()
        print("Resource restarted: " .. resourceName .. ", variables reinitialized.")
    end
end)

--Handle resource stops and clear up state  

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Clean up tasks or reset state if necessary
        ClearPedTasks(PlayerPedId())
        flags.actionInProgress = false
        print("Resource stopped: " .. resourceName .. ", state cleaned up.")
    end
end)

local playerPos = GetEntityCoords(playerPed)
local debounceInterval = 300 -- milliseconds
local lastInputTime = 0
local lastNotificationTime = 0

-- Flags and timers
local flags = {
    PickUpClams = false,
    ProcessClams = false,
    actionInProgress = false,
    isPunished = false
}

local timers = {
    questionTimer = 0,
    questionDuration = Config.pearlprocesstimer.timer,
    punishmentTimer = 0
}

-- Optimized function to check if player is near an activity
local function isPlayerNearActivity(activity)

    local location = activity.location
    local distanceSquared = (playerPos.x - location.x) ^ 2 + (playerPos.y - location.y) ^ 2 + (playerPos.z - location.z) ^ 2
    local distanceThresholdSquared = activity.distance ^ 2
    return distanceSquared <= distanceThresholdSquared
end

-- Notification cooldown
local notificationCooldown = 5000 -- milliseconds
local lastNotificationTime = 0 -- Initialize lastNotificationTime

-- Utility function to show notification with cooldown
local function showNotification(message, type)
    local currentTime = GetGameTimer()

    -- Ensure lastNotificationTime is initialized
    if lastNotificationTime == nil then
        lastNotificationTime = currentTime
    end

    -- Check if enough time has passed since the last notification
    if currentTime - lastNotificationTime > notificationCooldown then
        ESX.ShowNotification(message, type)
        lastNotificationTime = currentTime -- Update lastNotificationTime
    end
end


-- Optimized thread for handling inputs and activity locations
Citizen.CreateThread(function()
    local function isPlayerInWater()
        return IsEntityInWater(playerPed)
    end

    while true do
        Citizen.Wait(50) -- Adjusted polling interval
        
        playerPos = GetEntityCoords(playerPed) -- Cache player position

        for activityName, activity in pairs(cachedConfig.activityConfigs) do
            if isPlayerInWater() or not activity.inWater then
                if isPlayerNearActivity(activity) then
                    if activity.inWater and not isPlayerInWater() then
                        showNotification("You need to be in the water to " .. activity.helpText:lower(), "info")
                    else if flags.actionInProgress == false then
                        showNotification(activity.helpText, "info")
                        if IsControlJustPressed(0, Config.inputs.Pick_up) and GetGameTimer() - lastInputTime > debounceInterval then
                            lastInputTime = GetGameTimer()
                            TriggerEvent(activity.startEvent)
                            --flags.actionInProgress = true
                        end
                        end
                end
            end
        end
    end
end
end)


-- Thread for handling quiz game inputs and timers
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50) -- Adjusted polling interval for quiz game

        if currentQuestion then
            if IsControlJustReleased(0, Config.inputs.key_true_answer) then
                DisableAllControlActions(0)
                TriggerServerEvent('FactGame:CheckAnswer', currentQuestion, true)
                TriggerEvent('cancelAction')
                currentQuestion = nil
            elseif IsControlJustReleased(0, Config.inputs.key_false_answer) then
                DisableAllControlActions(0)
                TriggerServerEvent('FactGame:CheckAnswer', currentQuestion, false)
                TriggerEvent('cancelAction')
                currentQuestion = nil
            end

            if GetGameTimer() > timers.questionTimer and not questionAnswered then
                ESX.ShowNotification("Time is up! You missed the chance.", "error")
                timers.punishmentTimer = GetGameTimer() + math.random(Config.pearlprocesstimer.a, Config.pearlprocesstimer.b)
                flags.isPunished = true
                currentQuestion = nil
                TriggerEvent('cancelAction')
                TriggerServerEvent('FactGame:GivePearlsWrongAnswer')
            end
        end

        if flags.isPunished and IsControlJustReleased(0, Config.inputs.Pick_up) then
            ESX.ShowNotification("You're too tired to continue right now. Rest for a bit.")
        end

        if flags.isPunished and GetGameTimer() > timers.punishmentTimer then
            flags.isPunished = false
            ESX.ShowNotification("You're feeling better. You can process pearls again.", "success")
        end
    end
end)


-- Function to handle progress bars
function Progressbar(minTime, maxTime, progressBarText, animation, serverEvent, flagName)
    local waitTime = math.random(minTime, maxTime)
    flags[flagName] = true
    flags.actionInProgress = true

    ESX.Progressbar(progressBarText, waitTime, {
        FreezePlayer = true,
        label = progressBarText,
        useWhileDead = false,
        canCancel = true,
        TaskStartScenarioInPlace(playerPed, animation, 0, true),
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        onFinish = function()
            TriggerServerEvent(serverEvent)
            flags[flagName] = false
            flags.actionInProgress = false
            ClearPedTasks(PlayerPedId())
        end,
        onCancel = function()
            flags[flagName] = false
            flags.actionInProgress = false
            TriggerEvent('cancelAction')
        end,
    })
end

-- Event handlers for starting actions
RegisterNetEvent('SellPearls:start')
AddEventHandler('SellPearls:start', function()
    -- No need for Citizen.CreateThread if the logic is simple
    if isPlayerNearActivity(cachedConfig.activityConfigs.pearlSelling) then
        TriggerServerEvent('SellPearls:complete')
        ClearPedTasks(PlayerId())
        flags.actionInProgress = false

    else
        ESX.ShowNotification("You need to be closer to the shop to sell pearls.")
    end
end)

RegisterNetEvent('PickUpClams:start')
AddEventHandler('PickUpClams:start', function()
    local config = cachedConfig.clamProgressConfig
    Progressbar(config[1], config[2], config[3], config[4], config[5], cachedConfig.activityConfigs.clams.flag)
end)

RegisterNetEvent('cancelAction')
AddEventHandler('cancelAction', function()
    ClearPedTasks(PlayerPedId())
    flags.actionInProgress = false
end)

RegisterNetEvent('ProcessPearls:start')
AddEventHandler('ProcessPearls:start', function()
    
    print("I Was call")
    if not flags.isPunished then
        TriggerServerEvent('FactGame:RequestQuestion')
    end
end)

RegisterNetEvent('FactGame:ReceiveQuestion')
AddEventHandler('FactGame:ReceiveQuestion', function(fact, isTrue)
    currentQuestion = fact
    currentCorrectAnswer = isTrue

    if firstQuestion then
        timers.questionTimer = GetGameTimer() + timers.questionDuration + 5000
        firstQuestion = false

        ESX.ShowAdvancedNotification("Quiz Game Controls", "Quick Guide", 
        "Welcome to the quiz game! Here's how you play:\n\n" ..
        "• Press [~g~R~s~] to answer ~b~TRUE~s~.\n" ..
        "• Press [~r~Q~s~] to answer ~r~FALSE~s~.\n" ..
        "• Take your time, especially on the first question!",
        "CHAR_ANTONIA", 2, true, true, 140)
        DisableAllControlActions(0)
        Citizen.Wait(500)

        ESX.ShowNotification("Here's your first question! Take your time.\nQuestion: " .. fact, "info", timers.questionDuration + 5000)
    else
        timers.questionTimer = GetGameTimer() + timers.questionDuration
        ESX.ShowNotification("Quick! Answer this: " .. fact, "info", timers.questionDuration)
    end

    questionAnswered = false
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_HAMMERING', 0, true)
end)

RegisterNetEvent('FactGame:AnswerResult')
AddEventHandler('FactGame:AnswerResult', function(isCorrect)
    print('Answered question: ' .. tostring(isCorrect))
    ClearPedTasks(PlayerPedId())

    if isCorrect then
        ESX.ShowNotification("Correct! Good job.", 'success')
    else
        ESX.ShowNotification("Incorrect! Better luck next time.", "error")
        timers.punishmentTimer = GetGameTimer() + math.random(Config.pearlprocesstimer.a, Config.pearlprocesstimer.b)
        flags.isPunished = true
    end

    questionAnswered = true
end)

-- Thread to handle PED and its state
Citizen.CreateThread(function()
    RequestModel(cachedConfig.pearlModelHash)
    while not HasModelLoaded(cachedConfig.pearlModelHash) do
        Citizen.Wait(100) -- Adjusted wait time
    end

    local ped = CreatePed(4, cachedConfig.pearlModelHash, Config.locations.PearlBlackMarket.x, Config.locations.PearlBlackMarket.y, Config.locations.PearlBlackMarket.z, Config.locations.PearlBlackMarketHeading, true, true)
    local netId = NetworkGetNetworkIdFromEntity(ped)
    SetNetworkIdCanMigrate(netId, true)
    SetNetworkIdExistsOnAllMachines(netId, true)

    Citizen.Wait(250)

    if DoesEntityExist(ped) then
        print("Ped ID is " .. ped)
        print('Successfully Spawned Ped!')

        FreezeEntityPosition(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityCanBeDamaged(ped, false)
    else
        print('Failed to Spawn Ped!')
    end
end)

-- Fix slow quessin time and wrong answer / time out happening for first questionTimer
-- Animations not possible playing while selling pearls