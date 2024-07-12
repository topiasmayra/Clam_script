ESX.RegisterUsableItem('clam', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerClientEvent('esx:showNotification', source, "You can't use clams directly.")
end)

RegisterServerEvent('PickUpClams')
AddEventHandler('PickUpClams', function()
    local amount
    PlayerId =source
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    amount = math.random(1, 3) -- Adjust amount as per your configuration
    if xPlayer.canCarryItem('clam', 1) then
        TriggerClientEvent('esx:showNotification', PlayerId, "You found clams: " .. amount)
        TriggerClientEvent('PickUpClams:start', PlayerId)
        xPlayer.addInventoryItem('clam', 1)
    else
        TriggerClientEvent('esx:showNotification', PlayerId, "You can't carry more clams")
    end
end)
