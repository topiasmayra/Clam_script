ESX.RegisterUsableItem('clam', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerClientEvent('esx:showNotification', source, "You can't use clams directly.")
end)

RegisterNetEvent('PickUpClams')
AddEventHandler('PickUpClams', function()
    local PlayerId = source
    local amount
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    
    amount = math.random(1, 3) -- Adjust amount as per your configuration
    
    TriggerClientEvent('PickUpClams:start', PlayerId) -- Trigger client event to start animation or process

    if xPlayer.canCarryItem('clam', amount) then
        TriggerClientEvent('esx:showNotification', PlayerId, "You found clams: " .. amount)
        xPlayer.addInventoryItem('clam', amount)
    else
        TriggerClientEvent('esx:showNotification', PlayerId, "You can't carry more clams")
    end
end)
