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
    if clams >= 3 then
        local amount = math.random(1, 3)
        xPlayer.removeInventoryItem('clam', 3)
        xPlayer.addInventoryItem('pearl', amount)
        TriggerClientEvent('esx:showNotification', source, "You have successfully processed your clams into pearls and received " .. amount .. " pearls.")
    else
        TriggerClientEvent('esx:showNotification', source, "You don't have enough clams to process.")
    end
end)

-- TODO Check if player can carry x amount of pearls 