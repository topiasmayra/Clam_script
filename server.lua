ESX.RegisterUsableItem('clam', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('esx:showNotification', source, "You can't eat clams.")
end)

RegisterNetEvent('Giveclams')
AddEventHandler('Giveclams',function ()
    
    local amount
    PlayerId =source
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    amount = math.random(1, 3)     
    TriggerClientEvent('esx:showNotification', PlayerId, "You found clams: " .. amount)
    xPlayer.addInventoryItem('clam', amount)
end)

RegisterNetEvent('PickUpClams')
AddEventHandler('PickUpClams', function()
    local amount
    PlayerId =source
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    amount = math.random(1, 3) 
    if xPlayer.canCarryItem('clam', amount) then
        TriggerClientEvent('PickUpClams:start', PlayerId)

    else
        TriggerClientEvent('esx:showNotification', PlayerId, "You can't carry more clams")
    end
end)
    

-- pearl processing

ESX.RegisterUsableItem('pearl', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('esx:showNotification', source, "You can't eat pearls.")
    Citizen.Wait(5000)
end)

RegisterNetEvent('Pearlprocess')
AddEventHandler('Pearlprocess', function()
    print('Hello')
    local xPlayer = ESX.GetPlayerFromId(source)
    local clams = xPlayer.getInventoryItem('clam').count
    local pearls = xPlayer.getInventoryItem('pearl').count
    if clams >= 3 then
        local amount = math.random(1, 3)
        xPlayer.removeInventoryItem('clam', 3)
        xPlayer.addInventoryItem('pearl', amount)
        TriggerClientEvent('esx:showNotification', source(), "You have successfully processed your pear)}")
    end
end)
