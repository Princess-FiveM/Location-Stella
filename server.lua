ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('car_rental:rentVehicle', function(model, price, duration)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)

        TriggerClientEvent('car_rental:spawnVehicle', source, model, duration)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            title = 'Location échouée',
            description = 'Tu as pas de sous'
        })
    end
end)

lib.callback.register('car_rental:removeKey', function(source)
    exports.ox_inventory:RemoveItem(source, 'rental_keys', 1)
    return true
end)

RegisterNetEvent('car_rental:returnDeposit', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(50) -- Montant de la caution à rendre
    end
end)