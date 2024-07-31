ESX.RegisterUsableItem('clam', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('esx:showNotification', source, "You can't eat clams.")
end)

RegisterNetEvent('Giveclams')
AddEventHandler('Giveclams', function()
    local amount = math.random(Config.amount.a, Config.amount.b)
    if ESX.GetPlayerFromId(source).canCarryItem('clam', amount)then
        TriggerClientEvent('esx:showNotification', source, "You found clams: " .. amount)
        ESX.GetPlayerFromId(source).addInventoryItem('clam', amount)
    else
        TriggerClientEvent('esx:showNotification', source, "You can't carry more clams")
    end
end)



ESX.RegisterUsableItem('pearl', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('esx:showNotification', source, "You can't eat pearls.")
end)


local json = require('json')  -- Ensure the JSON library is available

RegisterNetEvent('FactGame:RequestQuestion')
AddEventHandler('FactGame:RequestQuestion', function()
    local src = source
    local question = Config.sealfacts[math.random(#Config.sealfacts)]
    print('Question from server side: ' .. question.fact)
    TriggerClientEvent('FactGame:ReceiveQuestion', src, question.fact, question.isTrue)
end)

RegisterNetEvent('FactGame:CheckAnswer')
AddEventHandler('FactGame:CheckAnswer', function(fact, playerAnswer)
    local src = source
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
        TriggerClientEvent('FactGame:AnswerResult', src, true)
    else
        TriggerClientEvent('FactGame:AnswerResult', src, false)
    end
end)

--pearl prosessing 



RegisterNetEvent('Pearlprocess:successfullyProcessed')
AddEventHandler('Pearlprocess', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local clams = xPlayer.getInventoryItem('clam').count
    local amount = math.random(Config.amount.a, Config.amount.c)
    local clams_amount_for_process = Config.amount.pearl_process_tax
   
    if clams >= clams_amount_for_process and  ESX.GetPlayerFromId(source).canCarryItem('pearl',amount) then
        xPlayer.removeInventoryItem('clam', clams_amount_for_process)
        xPlayer.addInventoryItem('pearl', amount)
        TriggerClientEvent('esx:showNotification', source, "You have successfully processed your clams into pearls and received " .. amount .. " pearls.")
    else
        TriggerClientEvent('esx:showNotification', source, "You don't have enough clams to process.")
    end
end)




--TODO IF PLAYER ANSWER QUESTION CORRECTLY IT  you get 1 or 2 pearls times more pearls
--TODO IF PLAYER ANSWER QUESTION INCORRECTLY you will lose 2  pearls 