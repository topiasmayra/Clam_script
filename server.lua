-- Function to process items (e.g., clams and pearls)
local function processItems(PlayerId, inputItem, inputAmount, outputItem, outputAmountRange, successMessage, removeOnFailure, outputOnFailure)
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    if not xPlayer then
        print('Error: Player not found with ID ' .. tostring(PlayerId))
        return
    end

    local inputItemCount = xPlayer.getInventoryItem(inputItem).count or 0
    local outputAmount = math.random(outputAmountRange.a, outputAmountRange.b)

    -- Check if the player has enough input items
    if inputItemCount < inputAmount then
        TriggerClientEvent('esx:showNotification', PlayerId, "You don't have enough " .. inputItem .. "(s) to process.")
        return
    end

    -- Check if the player can carry the output item
    if outputItem and not xPlayer.canCarryItem(outputItem, outputAmount) then
        TriggerClientEvent('esx:showNotification', PlayerId, "You don't have enough space in your inventory to carry the " .. outputItem .. "(s).")
        return
    end

    -- Proceed with processing
    if inputItemCount >= inputAmount then
        -- Remove input items
        if inputItem then
            xPlayer.removeInventoryItem(inputItem, inputAmount)
        end
        -- Add output items
        if outputItem then
            if xPlayer.canCarryItem(outputItem, outputAmount) then
                xPlayer.addInventoryItem(outputItem, outputAmount)
                TriggerClientEvent('esx:showNotification', PlayerId, successMessage .. outputAmount .. " " .. outputItem .. "(s).")
            else
                -- If there isn't enough space, handle failure
                if removeOnFailure and inputItemCount >= outputOnFailure then
                    xPlayer.addInventoryItem(inputItem, inputAmount)  -- Revert item removal
                    TriggerClientEvent('esx:showNotification', PlayerId, "You don't have enough space for " .. outputAmount .. " " .. outputItem .. "(s).")
                end
            end
        else
            TriggerClientEvent('esx:showNotification', PlayerId, successMessage)
        end
    else
        -- Handle failure scenario
        if removeOnFailure and inputItemCount >= outputOnFailure then
            xPlayer.removeInventoryItem(inputItem, outputOnFailure)
            TriggerClientEvent('esx:showNotification', PlayerId, "You lost " .. outputOnFailure .. " " .. inputItem .. "(s).")
        end
    end
end

-- Event to give clams to the player
RegisterNetEvent('Giveclams')
AddEventHandler('Giveclams', function()
    local PlayerId = source
    local xPlayer = ESX.GetPlayerFromId(PlayerId)

    if not xPlayer then
        print('Error: Player not found with ID ' .. tostring(PlayerId))
        return
    end

    local clamCount = xPlayer.getInventoryItem('clam').count or 0
    local maxClams = 100 -- Assume a max limit; adjust as needed

    -- Check if the player has enough space for clams
    if not xPlayer.canCarryItem('clam', Config.amount.b) then
        TriggerClientEvent('esx:showNotification', PlayerId, "You don't have enough space for more clams.")
        return
    end

    processItems(PlayerId, nil, 0, 'clam', {a = Config.amount.a, b = Config.amount.b}, "You found clams: ", "You can't carry more clams.", false, 0)
end)

-- Event for giving pearls if the answer is correct
RegisterNetEvent('FactGame:GivePearlsRightAnswer')
AddEventHandler('FactGame:GivePearlsRightAnswer', function(PlayerId)
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    if xPlayer and xPlayer.getInventoryItem('clam').count >= 2 then
        processItems(PlayerId, 'clam', Config.amount.pearl_process_tax, 'pearl', {a = Config.amount.a, b = Config.amount.c}, "You found ", "You can't carry any more pearls.", false, 0)
    else
        TriggerClientEvent('esx:showNotification', PlayerId, "You don't have 2 clams to open.")
    end
end)

-- Event for giving pearls if the answer is wrong
RegisterNetEvent('FactGame:GivePearlsWrongAnswer')
AddEventHandler('FactGame:GivePearlsWrongAnswer', function(PlayerId)
    processItems(PlayerId, 'clam', Config.amount.pearl_process_tax, 'pearl', {a = 0, b = 0}, "You found", "", true, Config.amount.pearl_process_tax)
end)

-- Event to request a question for the quiz game
RegisterNetEvent('FactGame:RequestQuestion')
AddEventHandler('FactGame:RequestQuestion', function()
    local PlayerId = source
    local question = Config.sealfacts[math.random(#Config.sealfacts)]
    TriggerClientEvent('FactGame:ReceiveQuestion', PlayerId, question.fact, question.isTrue)
end)

-- Event to check the player's answer
RegisterNetEvent('FactGame:CheckAnswer')
AddEventHandler('FactGame:CheckAnswer', function(fact, playerAnswer)
    local PlayerId = source
    local correctAnswer

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

-- Event to synchronize Ped state
RegisterNetEvent('syncPedState')
AddEventHandler('syncPedState', function(netId, stateKey, stateValue)
    local pedEntity = NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(pedEntity) then
        -- Update the state for the Ped and synchronize it across all clients
        Entity(pedEntity).state:set(stateKey, stateValue, true)

        -- Optionally, broadcast to all clients for additional sync
        TriggerClientEvent('updatePedState', -1, netId, stateKey, stateValue)
    end
end)

-- Function to handle selling pearls
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

    -- Check if the player has any pearls
    if itemCount <= 0 then
        TriggerClientEvent('esx:showNotification', source, "You don't have any pearls to sell.")
        return
    end

    -- Set the maximum pearls that can be sold
    local maxSellAmount = 2
    local sellAmount = math.min(itemCount, math.random(1, maxSellAmount)) -- Ensure we don’t sell more pearls than the player has

    local price = math.random(minPrice, maxPrice)
    local total = sellAmount * price

    if sellAmount > 0 then
        xPlayer.removeInventoryItem('pearl', sellAmount)
        xPlayer.addMoney(total)
        TriggerClientEvent('esx:showNotification', source, "You sold " .. sellAmount .. " pearls for $" .. total)
    else
        TriggerClientEvent('esx:showNotification', source, "You don't have any pearls to sell.")
    end
end

-- Register the event for completing the sale
RegisterNetEvent('SellPearls:complete')
AddEventHandler('SellPearls:complete', function()
    sellpearls(source)
end)
