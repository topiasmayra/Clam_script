AddEventHandler('playerJoining', function()
    local playerId = source
    TriggerClientEvent('Client:AssignPlayerId', playerId, playerId)
    print("Player joined: " .. GetPlayerName(playerId) .. ", ID: " .. playerId)
end)
local function processItems(PlayerId, inputItem, inputAmount, outputItem, outputAmountRange, successMessage, removeOnFailure, outputOnFailure)
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    if not xPlayer then
        print('Error: Player not found with ID ' .. tostring(PlayerId))
        return
    end

    local item = xPlayer.getInventoryItem(inputItem)
    local itemCount = item and item.count or 0
    local outputAmount = math.random(outputAmountRange.a, outputAmountRange.b)

    -- Check if the player has enough of the input item (clams)
    if itemCount < inputAmount then
        TriggerClientEvent('esx:showNotification', PlayerId, "You don't have enough " .. inputItem .. "(s) to process.")
        return
    end

    -- Check if the player can carry the output item
    if not xPlayer.canCarryItem(outputItem, outputAmount) then
        TriggerClientEvent('esx:showNotification', PlayerId, "You don't have enough space in your inventory to carry the " .. outputItem .. "(s).")
        return
    end

    -- Process the item exchange if the player has enough items and can carry the output
    if itemCount >= inputAmount then
        if inputItem then
            xPlayer.removeInventoryItem(inputItem, inputAmount)
        end
        if outputItem then
            xPlayer.addInventoryItem(outputItem, outputAmount)
            TriggerClientEvent('esx:showNotification', PlayerId, successMessage .. outputAmount .. " " .. outputItem .. "(s).")
        else
            TriggerClientEvent('esx:showNotification', PlayerId, successMessage)
        end
    else
        -- Handle failure scenario
        if removeOnFailure and itemCount >= outputOnFailure then
            xPlayer.removeInventoryItem(inputItem, outputOnFailure)
            TriggerClientEvent('esx:showNotification', PlayerId, "You lost " .. outputOnFailure .. " " .. inputItem .. "(s).")
        end
    end
end
    
    
    -- Event handlers
    RegisterNetEvent('Giveclams')
    AddEventHandler('Giveclams', function()
        local PlayerId = source
        processItems(PlayerId, nil, 0, 'clam', {a = Config.amount.a, b = Config.amount.b}, "You found clams: ", "You can't carry more clams.", false, 0)
    end)
    
    RegisterNetEvent('FactGame:GivePearlsRightAnswer')
    AddEventHandler('FactGame:GivePearlsRightAnswer', function(PlayerId)
        local xPlayer = ESX.GetPlayerFromId(PlayerId)
        if xPlayer and xPlayer.getInventoryItem('clam').count >= 2 then
            processItems(PlayerId, 'clam', Config.amount.pearl_process_tax, 'pearl', {a = Config.amount.a, b = Config.amount.c}, "You found ", "You can't carry any more pearls.", false, 0)
        else
            TriggerClientEvent('esx:showNotification', PlayerId, "You don't have 2 clams to open.")
        end
    end)
    
    RegisterNetEvent('FactGame:GivePearlsWrongAnswer')
    AddEventHandler('FactGame:GivePearlsWrongAnswer', function(PlayerId)
        processItems(PlayerId, 'clam', Config.amount.pearl_process_tax, 'pearl', {a = 0, b = 0}, "You found" , "", true, Config.amount.pearl_process_tax)
    end)

    RegisterNetEvent('FactGame:RequestQuestion')
    AddEventHandler('FactGame:RequestQuestion', function()
        local PlayerId = source
        local question = Config.sealfacts[math.random(#Config.sealfacts)]
        TriggerClientEvent('FactGame:ReceiveQuestion', PlayerId, question.fact, question.isTrue)
    end)
    
    RegisterNetEvent('FactGame:CheckAnswer')
    AddEventHandler('FactGame:CheckAnswer', function(fact, playerAnswer)
        local PlayerId = source
        local correctAnswer = nil
    
        for _, v in ipairs(Config.sealfacts) do
            if v.fact == fact then
                correctAnswer = v.isTrue
                break
            end
        end
    
        if correctAnswer == nil then
            print('Error: Question not found in config.')
            return
        end
    
        if playerAnswer == correctAnswer then
            TriggerClientEvent('FactGame:AnswerResult', PlayerId, true)
            TriggerEvent('FactGame:GivePearlsRightAnswer', PlayerId)
        else
            TriggerClientEvent('FactGame:AnswerResult', PlayerId, false)
            TriggerEvent('FactGame:GivePearlsWrongAnswer', PlayerId)
        end
    end)

-- Function to handle the actual pearl selling
local function sellpearls(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        print("Error: Could not retrieve player with ID " .. tostring(source))
        return
    end
    
    local item = xPlayer.getInventoryItem('pearl')
    local itemCount = item and item.count or 0
    local minPrice = Config.activityConfigs.pearlSelling.price.min
    local maxPrice = Config.activityConfigs.pearlSelling.price.max
    
    if minPrice <= 0 or maxPrice <= 0 then
        print("Error: Invalid pearl price configuration.")
        TriggerClientEvent('esx:showNotification', source, "Error: Invalid pearl price configuration.")
        return
    end
    
    if itemCount <= 0 then
        TriggerClientEvent('esx:showNotification', source, "You don't have any pearls to sell.")
        return
    end
    
    local price = math.random(minPrice, maxPrice)
    local total = itemCount * price
    
    xPlayer.removeInventoryItem('pearl', itemCount)
    xPlayer.addMoney(total)
    print("Player " .. GetPlayerName(source) .. " sold " .. itemCount .. " pearls for $" .. total)
    TriggerClientEvent('esx:showNotification', source, "You sold " .. itemCount .. " pearls for $" .. total)
end

-- Register the event for completing the sale
RegisterNetEvent('SellPearls:complete')
AddEventHandler('SellPearls:complete', function()
    sellpearls(source)
end)

-- Event handler for successful pearl sale
RegisterNetEvent('SellPearls:success')
AddEventHandler('SellPearls:success', function()
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_MUSCLE_FLEX', 0, true)
    Citizen.Wait(3000) -- Duration of the scenario in milliseconds
    ClearPedTasks(PlayerPedId())
    print("Sell scenario completed.")
end)