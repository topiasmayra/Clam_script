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

RegisterNetEvent('Pearlprocess')
AddEventHandler('Pearlprocess', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local clams = xPlayer.getInventoryItem('clam').count
    local amount = math.random(1, 3)
   
    if clams >= 3 and  ESX.GetPlayerFromId(source).canCarryItem('pearl',amount) then
        xPlayer.removeInventoryItem('clam', 3)
        xPlayer.addInventoryItem('pearl', amount)
        TriggerClientEvent('esx:showNotification', source, "You have successfully processed your clams into pearls and received " .. amount .. " pearls.")
    else
        TriggerClientEvent('esx:showNotification', source, "You don't have enough clams to process.")
    end
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

--TODO IF PLAYER ANSWER QUESTION CORRECTLY IT WILL INGREASE THEIR LUCK FOR PROGERSSING PEARLS
--TODO IF PLAYER ANSWER QUESTION INCORRECTLY IT WILL DECREASE THEIR LUCK FOR PROGERSSING PEARLS