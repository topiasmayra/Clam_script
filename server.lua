ESX.RegisterUsableItem('clam', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('esx:showNotification', source, "You can't eat clams.")
end)

ESX.RegisterUsableItem('clam_fork', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local clam_fork_in_use = false
    if clam_fork_in_use == false then
        TriggerClientEvent('esx:showNotification', xPlayer, "You have equipt fork.") 
else
    TriggerClientEvent('esx:showNotification', xPlayer, "Clam fork is already in use.")
    clam_fork_in_use = true
    Citizen.Wait(500)
end
end)


RegisterNetEvent('Giveclams')
AddEventHandler('Giveclams',function ()
    
    local amount
    PlayerId =source
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    amount = math.random(1, 3)     
    TriggerClientEvent('eslocations, Configtions, Configtions, ConfigowNotification', PlayerId, "You found clams: " .. amount)
    xPlayer.addInventoryItem('clam', amount)
end)

RegisterNetEvent('PickUpClams')
AddEventHandler('PickUpClams', function()
    local amount
    PlayerId =source
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    amount = math.random(1, 3) 
    if xPlayer.getInventoryItem('clam_fork').count < 1 then
        TriggerClientEvent('esx:showNotification', PlayerId, "You need a clam fork to be able to pick up the clams.")
    elseif xPlayer.canCarryItem('clam', amount) then
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
