-- Utility function to handle inventory transactions
    local function processItems(PlayerId, inputItem, inputAmount, outputItem, outputAmountRange, successMessage, removeOnFailure, outputOnFailure)
        local xPlayer = ESX.GetPlayerFromId(PlayerId)
        if not xPlayer then
            print('Error: Player not found with ID ' .. tostring(PlayerId))
            return
        end
    
        local item = xPlayer.getInventoryItem(inputItem)
        local itemCount = item and item.count or 0
        local outputAmount = math.random(outputAmountRange.a, outputAmountRange.b)
    
        if itemCount >= inputAmount and xPlayer.canCarryItem(outputItem, outputAmount) then
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
        processItems(PlayerId, 'clam', Config.amount.pearl_process_tax, 'pearl', {a = 0, b = 0}, "", "", true, Config.amount.pearl_process_tax)
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
    