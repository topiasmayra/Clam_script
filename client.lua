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
        Citizen.Wait(50) -- Polling interval

        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)

        for _, activity in pairs(Config.activityConfigs) do
            local distance = #(pos - activity.location) -- Ensure activity.location is a vector3

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

RegisterNetEvent('SellPearls:start')
AddEventHandler('SellPearls:start', function()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    local sellingLocation = Config.activityConfigs.pearlSelling.location
    local distance = #(pos - sellingLocation)

    if distance <= Config.activityConfigs.pearlSelling.distance then
        -- Ensure the player is at the selling location
        TriggerServerEvent('SellPearls:complete')
        
    actionInProgress = false  -- Reset the action flag

        
-- Event handlers for actions
RegisterNetEvent('PickUpClams:start')
AddEventHandler('PickUpClams:start', function()
    local config = Config.activityConfigs.clams.progress
    Progressbar(config[1], config[2], config[3], config[4], config[5], Config.activityConfigs.clams.flag)
end)
    else
        ESX.ShowNotification("You need to be closer to the shop to sell pearls.")
    end
end)

-- Need fix this so you can rellsell things
-- Add sound 


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

local firstQuestion = true -- Track if it's the first question

RegisterNetEvent('FactGame:ReceiveQuestion')
AddEventHandler('FactGame:ReceiveQuestion', function(fact, isTrue)
    currentQuestion = fact
    currentCorrectAnswer = isTrue

    if firstQuestion then
        questionTimer = GetGameTimer() + questionDuration + 5000 -- Give extra 5 seconds for the first question
        firstQuestion = false

        ESX.ShowAdvancedNotification("Quiz Game Controls", "Quick Guide", 
        "Welcome to the quiz game! Here's how you play:\n\n" ..
        "• Press [~g~E~s~] to answer ~b~TRUE~s~.\n" ..
        "• Press [~r~Q~s~] to answer ~r~FALSE~s~.\n" ..
        "• Take your time, especially on the first question!",
        "CHAR_ANTONIA", 2, true, true, 140)
        DisableAllControlActions(0)
        -- Wait for 3 seconds (3000 milliseconds) before showing the first question
        Citizen.Wait(1000)

        -- Show the first question with an extended duration
        ESX.ShowNotification("Here's your first question! Take your time.\nQuestion: " .. fact, "info", questionDuration + 5000)


    else
        questionTimer = GetGameTimer() + questionDuration
        ESX.ShowNotification("Quick! Answer this: " .. fact, "info", questionDuration)
    end

    questionAnswered = false
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_HAMMERING', 0, true) -- Play animation while processing
end)

RegisterNetEvent('FactGame:AnswerResult')
AddEventHandler('FactGame:AnswerResult', function(isCorrect)
    ClearPedTasks(PlayerPedId()) -- Stop animation when the answer is received

    if isCorrect then
        ESX.ShowNotification("Correct! Good job.", 'success')
    else
        ESX.ShowNotification("Incorrect! Better luck next time.", "error")
        punishmentTimer = GetGameTimer() + math.random(Config.pearlprocesstimer.a, Config.pearlprocesstimer.b)
        isPunished = true
    end

    questionAnswered = true
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)

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

            if GetGameTimer() > questionTimer and not questionAnswered then
                ESX.ShowNotification("Time is up! You missed the chance.", "error")
                punishmentTimer = GetGameTimer() + math.random(Config.pearlprocesstimer.a, Config.pearlprocesstimer.b)
                isPunished = true
                currentQuestion = nil
                TriggerEvent('cancelAction')
                TriggerServerEvent('FactGame:GivePearlsWrongAnswer')
            end
        end

        if isPunished and IsControlJustReleased(0, Config.inputs.Pick_up) then
            ESX.ShowNotification("You're too tired to continue right now. Rest for a bit.")
        end

        if isPunished and GetGameTimer() > punishmentTimer then
            isPunished = false
            ESX.ShowNotification("You're feeling better. You can process pearls again.", "success")
        end
    end
end)

--PED TEST 

local model = GetHashKey('a_f_m_fatcult_01') -- Use the model hash
local coords = Config.locations.PearlBlackMarket
local heading = Config.locations.PearlBlackMarketHeading -- Set the heading

-- Load the model if it's not already loaded
RequestModel(model)
while not HasModelLoaded(model) do
    Wait(0)
end

-- Create the Ped
local ped = CreatePed(4, model, coords.x, coords.y, coords.z, heading, true, true)

-- Ensure the Ped is a network entity
local netId = NetworkGetNetworkIdFromEntity(ped)
SetNetworkIdCanMigrate(netId, true)
SetNetworkIdExistsOnAllMachines(netId, true)

-- Wait a bit to ensure the Ped is created properly
Wait(250)

-- Check if the Ped exists
if DoesEntityExist(ped) then
    print("Ped ID is " .. ped)
    print('Successfully Spawned Ped!')

    -- Freeze the Ped in place
    FreezeEntityPosition(ped, true)

    -- Prevent the Ped from fleeing and block non-temporary events
    SetPedFleeAttributes(ped, 0, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    

    -- Set up state bags for synchronization
    Entity(ped).state:set('exampleState', 'someValue', true) -- Syncs to all clients

    -- Notify the server to sync this state with other clients
    TriggerServerEvent('syncPedState', netId, 'exampleState', 'someValue')
else
    print('Failed to Spawn Ped!')
end
-- Make Clam pick up more resource effective (0.8ms per clam)
-- Optimize
-- Make Blimps