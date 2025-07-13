local rentalPed = nil
local activeVehicle = nil

CreateThread(function()
    for _, loc in pairs(Config.Locations) do
        RequestModel(`a_m_y_business_01`)
        while not HasModelLoaded(`a_m_y_business_01`) do Wait(0) end

        rentalPed = CreatePed(0, `a_m_y_business_01`, loc.coords, loc.heading, false, false)
        FreezeEntityPosition(rentalPed, true)
        SetEntityInvincible(rentalPed, true)
        SetBlockingOfNonTemporaryEvents(rentalPed, true)

        exports.ox_target:addLocalEntity(rentalPed, {
            {
                name = 'car_rental',
                label = 'Louer un véhicule',
                icon = 'fas fa-car',
                onSelect = function()
                    openRentalMenu()
                end,
            }
        })
    end
end)

-- 📍 Ajout des blips pour chaque point de location
CreateThread(function()
    for _, loc in pairs(Config.Locations) do
        local blip = AddBlipForCoord(loc.coords)
        SetBlipSprite(blip, 225)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(loc.label or "Location de voiture")
        EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    for _, loc in pairs(Config.ReturnLocations) do
        local blip = AddBlipForCoord(loc.coords)
        SetBlipSprite(blip, 605)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(loc.label or "Retour de voiture")
        EndTextCommandSetBlipName(blip)
    end
end)

function openRentalMenu()
    local options = {}

    for _, vehicle in pairs(Config.Vehicles) do
        table.insert(options, {
            title = ("%s - $%s (%d min)"):format(vehicle.label, vehicle.price, vehicle.duration),
            description = "Louer ce véhicule pour un temps limité",
            icon = "car",
            onSelect = function()
                TriggerServerEvent('car_rental:rentVehicle', vehicle.model, vehicle.price, vehicle.duration)
            end
        })
    end

    lib.registerContext({
        id = 'car_rental_menu',
        title = 'Location de Véhicule',
        options = options
    })

    lib.showContext('car_rental_menu')
end

RegisterNetEvent('car_rental:spawnVehicle', function(model, duration)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    local vehicleHash = GetHashKey(model)
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do Wait(0) end

    if activeVehicle and DoesEntityExist(activeVehicle) then
        DeleteEntity(activeVehicle)
    end

    activeVehicle = CreateVehicle(vehicleHash, coords.x + 2.0, coords.y, coords.z, heading, true, false)
    TaskWarpPedIntoVehicle(playerPed, activeVehicle, -1)
    SetVehicleNumberPlateText(activeVehicle, "RENTAL" .. math.random(100,999))
end)

CreateThread(function()
    for _, loc in pairs(Config.ReturnLocations) do
        local point = lib.points.new({
            coords = loc.coords,
            distance = 2.5,
        })

        function point:nearby()
            DrawMarker(1, self.coords.x, self.coords.y, self.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 50, 200, 50, 150, false, true, 2, nil, nil, false)
            
            if self.currentDistance < 1.5 and IsControlJustReleased(0, 38) then
                openReturnMenu()
            end
        end
    end
end)

function openReturnMenu()
    lib.registerContext({
        id = 'rental_return_menu',
        title = 'Retour de véhicule de location',
        options = {
            {
                title = 'Rendre le véhicule',
                icon = '🚗',
                onSelect = function()
                    local ped = PlayerPedId()
                    if IsPedInAnyVehicle(ped, false) then
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        -- Optionnel : check plaque ou modèle ici
                        TaskLeaveVehicle(ped, vehicle, 0)
                        Wait(1000)
                        DeleteVehicle(vehicle)
                        lib.notify({
                            title = 'Véhicule rendu',
                            description = 'Merci d’avoir utilisé notre service !',
                            type = 'success'
                        })
                        -- Optionnel : donner un remboursement
                        -- TriggerServerEvent('car_rental:returnDeposit')
                    else
                        lib.notify({
                            title = 'Erreur',
                            description = 'Tu dois être dans un véhicule à rendre.',
                            type = 'error'
                        })
                    end
                end
            },
        }
    })

    lib.showContext('rental_return_menu')
end

RegisterCommand("getkey", function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        lib.notify({
            title = "Erreur",
            description = "Tu dois être dans un véhicule.",
            type = "error"
        })
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    local plate = GetVehicleNumberPlateText(vehicle)

    TriggerServerEvent("car_rental:giveKeyToPlayer", plate)
end, false)