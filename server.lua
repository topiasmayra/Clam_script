ESX.RegisterUsableItem('clam', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('esx:showNotification', source, "You can't eat clams.")
end)

ESX.RegisterUsableItem('clam_fork', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('esx:showNotification', source, "You have equipt fork.")
end)



RegisterNetEvent('PickUpClams')
AddEventHandler('PickUpClams', function()
    local amount
    PlayerId =source
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    if xPlayer.getInventoryItem('clam_fork').count < 1 then
        TriggerClientEvent('esx:showNotification', PlayerId, "You need a clam fork to be able to pick up the clams.")
    elseif not xPlayer.canCarryItem('clam', amount) then
        TriggerClientEvent('esx:showNotification', PlayerId, "You can't carry more clams")
    else
        TriggerClientEvent('PickUpClams:start', PlayerId)
        TriggerClientEvent('esx:showNotification', PlayerId, "You found clams: " .. amount)
        xPlayer.addInventoryItem('clam', amount)
        TriggerClientEvent('PickUpClams:stop', PlayerId)
    end
    

end)
