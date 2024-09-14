ESX = nil
Config = Config or {}
local shopNpc = nil
local shopBlip = nil
local copNpc = nil
local copBlip = nil
local gunNpc = nil
local gunBlip = nil
local plugInJail = false
local gunInJail = false
local playerPurchaseCounts = {} -- Track purchases per player
local hasPurchasedWaypoint = false
local currentWaypointLocation = nil
local currentShopLocation = nil
local currentGunNpcLocation = nil

-- Function to select a random location from the list
local function selectRandomLocation(locations)
    print("Selecting random location...")
    return locations[math.random(#locations)]
end

-- Function to reset the script state on restart
local function resetScriptState()
    print("Resetting script state...")
    plugInJail = false
    gunInJail = false
    playerPurchaseCounts = {} -- Reset purchase counts for all players
    hasPurchasedWaypoint = false
    currentWaypointLocation = selectRandomLocation(Config.WaypointLocations)
    currentShopLocation = selectRandomLocation(Config.ShopLocations)
    currentGunNpcLocation = selectRandomLocation(Config.GunNpcLocations)
    TriggerServerEvent('custom:spawnWaypointNpc')
    print("Script state reset complete.")
end

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(10)
    end

    print("ESX initialized.")
    resetScriptState()
end)

-- Function to spawn the Waypoint NPC (Middle Man)
RegisterNetEvent('custom:clientSpawnWaypointNpc')
AddEventHandler('custom:clientSpawnWaypointNpc', function()
    print("Spawning Waypoint NPC...")
    RequestModel(GetHashKey(Config.WaypointNpcModel))
    while not HasModelLoaded(GetHashKey(Config.WaypointNpcModel)) do
        Citizen.Wait(10)
    end

    local waypointNpc = CreatePed(4, GetHashKey(Config.WaypointNpcModel), currentWaypointLocation.coords.x, currentWaypointLocation.coords.y, currentWaypointLocation.coords.z, currentWaypointLocation.heading, false, true)
    TaskStartScenarioInPlace(waypointNpc, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    SetEntityAsMissionEntity(waypointNpc, true, true)
    SetModelAsNoLongerNeeded(GetHashKey(Config.WaypointNpcModel))

    -- Create blip for Middle Man
    local waypointBlip = AddBlipForCoord(currentWaypointLocation.coords.x, currentWaypointLocation.coords.y, currentWaypointLocation.coords.z)
    SetBlipSprite(waypointBlip, 280)
    SetBlipDisplay(waypointBlip, 4)
    SetBlipScale(waypointBlip, 0.8)
    SetBlipColour(waypointBlip, 5)
    SetBlipAsShortRange(waypointBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Middle Man")
    EndTextCommandSetBlipName(waypointBlip)

    if DoesEntityExist(waypointNpc) then
        print("Waypoint NPC spawned successfully.")
    else
        print("Failed to spawn Waypoint NPC.")
    end

    if DoesBlipExist(waypointBlip) then
        print("Waypoint blip created successfully.")
    else
        print("Failed to create Waypoint blip.")
    end

    -- Register the NPC entity with ox_target
    exports.ox_target:addLocalEntity(waypointNpc, {
        {
            name = 'buy_waypoint_plug',
            label = 'Buy Waypoint to Plug ($'..Config.WaypointToPlugCost..')',
            icon = 'fa-map-marker-alt',
            onSelect = function()
                if not hasPurchasedWaypoint then
                    ESX.TriggerServerCallback('esx:getPlayerData', function(data)
                        local playerMoney = data.money
                        if playerMoney >= Config.WaypointToPlugCost then
                            hasPurchasedWaypoint = true
                            TriggerServerEvent('custom:deductMoney', Config.WaypointToPlugCost)
                            SetNewWaypoint(currentShopLocation.coords.x, currentShopLocation.coords.y)
                            TriggerEvent('custom:revealShopNpc')
                            ESX.ShowNotification('Waypoint to Plug purchased successfully!')
                        else
                            ESX.ShowNotification('You do not have enough money!')
                        end
                    end)
                else
                    ESX.ShowNotification('You can only purchase one waypoint per session!')
                end
            end
        },
        {
            name = 'buy_waypoint_gun',
            label = 'Buy Waypoint to Gun Dealer ($'..Config.WaypointToGunNpcCost..')',
            icon = 'fa-map-marker-alt',
            onSelect = function()
                if not hasPurchasedWaypoint then
                    ESX.TriggerServerCallback('esx:getPlayerData', function(data)
                        local playerMoney = data.money
                        if playerMoney >= Config.WaypointToGunNpcCost then
                            hasPurchasedWaypoint = true
                            TriggerServerEvent('custom:deductMoney', Config.WaypointToGunNpcCost)
                            SetNewWaypoint(currentGunNpcLocation.coords.x, currentGunNpcLocation.coords.y)
                            TriggerEvent('custom:revealGunNpc')
                            ESX.ShowNotification('Waypoint to Gun Dealer purchased successfully!')
                        else
                            ESX.ShowNotification('You do not have enough money!')
                        end
                    end)
                else
                    ESX.ShowNotification('You can only purchase one waypoint per session!')
                end
            end
        }
    }, 2.0)
end)

-- Shop NPC spawn
RegisterNetEvent('custom:clientSpawnShopNpc')
AddEventHandler('custom:clientSpawnShopNpc', function(isInJail)
    print("Spawning Shop NPC (Plug)... Jail status: " .. tostring(isInJail))
    local location = isInJail and Config.PlugJailLocation or currentShopLocation
    local locale = Locales['en']

    if not locale then
        print("Error: Locale 'en' is not properly configured. Please check your Locales table.")
        return
    end

    -- Load the NPC model
    RequestModel(GetHashKey(Config.ShopNpcModel))
    while not HasModelLoaded(GetHashKey(Config.ShopNpcModel)) do
        Citizen.Wait(10)
    end

    -- Spawn the NPC
    shopNpc = CreatePed(4, GetHashKey(Config.ShopNpcModel), location.coords.x, location.coords.y, location.coords.z, location.heading, false, true)
    TaskStartScenarioInPlace(shopNpc, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    SetEntityAsMissionEntity(shopNpc, true, true)
    SetModelAsNoLongerNeeded(GetHashKey(Config.ShopNpcModel))

    -- Check if the NPC was created successfully
    if DoesEntityExist(shopNpc) then
        print("Plug NPC spawned successfully.")
    else
        print("Failed to spawn Plug NPC.")
        return -- Early return if the NPC couldn't be created
    end

    -- Create the blip for the NPC
    shopBlip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
    SetBlipSprite(shopBlip, isInJail and 459 or 52)
    SetBlipDisplay(shopBlip, 4)
    SetBlipScale(shopBlip, 0.8)
    SetBlipColour(shopBlip, isInJail and 3 or 1)
    SetBlipAsShortRange(shopBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(isInJail and "Plug (In Jail)" or "Plug")
    EndTextCommandSetBlipName(shopBlip)

    -- Check if the blip was created successfully
    if DoesBlipExist(shopBlip) then
        print("Plug blip created successfully.")
    else
        print("Failed to create Plug blip.")
    end

    -- Register the NPC entity with ox_target for interactions
    local options = {}

    if not isInJail then
        for _, item in ipairs(Config.PlugItems) do
            -- Check each field for nil values
            if not item.name or not item.label or not item.price then
                print("Error: One or more fields are nil in PlugItems. Name: " .. tostring(item.name) .. ", Label: " .. tostring(item.label) .. ", Price: " .. tostring(item.price))
            else
                -- Debugging print to ensure all fields are correctly populated
                print("Debug: Plug Item - Name: " .. tostring(item.name) .. ", Label: " .. tostring(item.label) .. ", Price: " .. tostring(item.price))

                table.insert(options, {
                    name = 'buy_' .. item.name,
                    label = locale[item.label]:format(item.price),
                    icon = 'fa-solid fa-capsules',
                    onSelect = function()
                        print("Client: Triggering buy event for item:", item.name)
                        TriggerServerEvent('custom:buyItem', item.name, item.price, 'plug')
                        TriggerServerEvent('custom:checkSnitchChance', 'plug')
                        TriggerServerEvent('custom:checkPlugJailChance', source, 'plug')
                    end                    
                })
            end
        end
    end

    -- Add options to ox_target only if options are valid
    if #options > 0 then
        print("Registering Plug NPC with ox_target...")
        exports.ox_target:addLocalEntity(shopNpc, options, 2.0)
    else
        print("Error: No valid options to register with ox_target for the Plug NPC.")
    end
end)

-- Spawn the Gun NPC
RegisterNetEvent('custom:clientSpawnGunNpc')
AddEventHandler('custom:clientSpawnGunNpc', function(isInJail)
    print("Spawning Gun NPC... Jail status: " .. tostring(isInJail))
    local location = isInJail and Config.GunJailLocation or currentGunNpcLocation
    local locale = Locales['en']

    RequestModel(GetHashKey(Config.GunNpcModel))
    while not HasModelLoaded(GetHashKey(Config.GunNpcModel)) do
        Citizen.Wait(10)
    end

    gunNpc = CreatePed(4, GetHashKey(Config.GunNpcModel), location.coords.x, location.coords.y, location.coords.z, location.heading, false, true)
    
    if isInJail then
        TaskStartScenarioInPlace(gunNpc, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    end
    
    SetEntityAsMissionEntity(gunNpc, true, true)
    SetModelAsNoLongerNeeded(GetHashKey(Config.GunNpcModel))

    -- Blip setup
    gunBlip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
    SetBlipSprite(gunBlip, isInJail and 459 or 52)
    SetBlipDisplay(gunBlip, 4)
    SetBlipScale(gunBlip, 0.8)
    SetBlipColour(gunBlip, isInJail and 3 or 1)
    SetBlipAsShortRange(gunBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(isInJail and "Gun Dealer (In Jail)" or "Gun Dealer")
    EndTextCommandSetBlipName(gunBlip)

    if DoesEntityExist(gunNpc) then
        print("Gun NPC spawned successfully.")
    else
        print("Failed to spawn Gun NPC.")
    end

    if DoesBlipExist(gunBlip) then
        print("Gun blip created successfully.")
    else
        print("Failed to create Gun blip.")
    end

    -- Register the NPC entity with ox_target for interactions
    local options = {}

    if not isInJail then
        for _, item in ipairs(Config.GunItems) do
            if not item.name or not item.label or not item.price then
                print("Error: One or more fields are nil in GunItems. Name: " .. tostring(item.name) .. ", Label: " .. tostring(item.label) .. ", Price: " .. tostring(item.price))
            else
                table.insert(options, {
                    name = 'buy_' .. item.name,
                    label = locale[item.label]:format(item.price),
                    icon = 'fa-solid fa-capsules',
                    onSelect = function()
                        print("Client: Triggering buy event for item:", item.name)
                        TriggerServerEvent('custom:buyItem', item.name, item.price, 'gun')
                        TriggerServerEvent('custom:checkSnitchChance', 'gun')
                        TriggerServerEvent('custom:checkGunJailChance', source, 'gun')
                    end                    
                })
            end
        end
    end

    -- Add options to ox_target only if options are valid
    if #options > 0 then
        print("Registering Gun NPC with ox_target...")
        exports.ox_target:addLocalEntity(gunNpc, options, 2.0)
    else
        print("Error: No valid options to register with ox_target for the Gun NPC.")
    end
end)



-- Setting NPC in jail
RegisterNetEvent('custom:setNpcInJail')
AddEventHandler('custom:setNpcInJail', function(state, npcType)
    print("Setting NPC in jail: " .. npcType .. " State: " .. tostring(state))
    if npcType == "plug" then
        plugInJail = state
        if state == true then
            -- Trigger the removal of the Shop NPC when the Plug is sent to jail
            TriggerEvent('custom:removeShopNpc')
        end
    elseif npcType == "gun" then
        gunInJail = state
        if state == true then
            -- Trigger the removal of the Gun NPC if needed
            TriggerEvent('custom:removeGunNpc')
        end
    end
end)

-- Spawn the Cop NPC during the NPC's jail time
RegisterNetEvent('custom:spawnCopNpc')
AddEventHandler('custom:spawnCopNpc', function()
    print("Spawning Cop NPC...")
    RequestModel(GetHashKey(Config.CopNpcModel))
    while not HasModelLoaded(GetHashKey(Config.CopNpcModel)) do
        Citizen.Wait(10)
    end

    copNpc = CreatePed(4, GetHashKey(Config.CopNpcModel), Config.CopNpcLocation.coords.x, Config.CopNpcLocation.coords.y, Config.CopNpcLocation.coords.z, Config.CopNpcLocation.heading, false, true)
    TaskStartScenarioInPlace(copNpc, "WORLD_HUMAN_COP_IDLES", 0, true)
    SetEntityAsMissionEntity(copNpc, true, true)
    SetModelAsNoLongerNeeded(GetHashKey(Config.CopNpcModel))

    -- Create blip for Cop
    copBlip = AddBlipForCoord(Config.CopNpcLocation.coords.x, Config.CopNpcLocation.coords.y, Config.CopNpcLocation.coords.z)
    SetBlipSprite(copBlip, 60) -- Cop blip sprite
    SetBlipDisplay(copBlip, 4)
    SetBlipScale(copBlip, 0.8)
    SetBlipColour(copBlip, 3)
    SetBlipAsShortRange(copBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Bail Cop")
    EndTextCommandSetBlipName(copBlip)

    if DoesEntityExist(copNpc) then
        print("Cop NPC spawned successfully.")
    else
        print("Failed to spawn Cop NPC.")
    end

    if DoesBlipExist(copBlip) then
        print("Cop blip created successfully.")
    else
        print("Failed to create Cop blip.")
    end
    -- Register the NPC entity with ox_target
    exports.ox_target:addLocalEntity(copNpc, {
        {
            name = 'pay_bail',
            label = 'Pay Bail ($'..Config.BailAmount..')',
            icon = 'fa-money-bill-wave',
            onSelect = function()
                TriggerServerEvent('custom:bailNpc', 'plug')
            end
        }
    }, 2.0)    
end)

RegisterNetEvent('custom:removeCopNpc')
AddEventHandler('custom:removeCopNpc', function()
    print("Removing Cop NPC...")
    if copNpc and DoesEntityExist(copNpc) then
        DeleteEntity(copNpc)
        copNpc = nil
        print("Cop NPC removed.")
    else
        print("No Cop NPC found to remove.")
    end

    if copBlip and DoesBlipExist(copBlip) then
        RemoveBlip(copBlip)
        copBlip = nil
        print("Cop blip removed.")
    else
        print("No Cop blip found to remove.")
    end
end)

RegisterNetEvent('custom:removeShopNpc')
AddEventHandler('custom:removeShopNpc', function()
    print("Removing Shop NPC...")

    if shopNpc and DoesEntityExist(shopNpc) then
        DeleteEntity(shopNpc)
        shopNpc = nil
        print("Shop NPC removed.")
    else
        print("No Shop NPC found to remove.")
    end

    if shopBlip and DoesBlipExist(shopBlip) then
        RemoveBlip(shopBlip)
        shopBlip = nil
        print("Shop blip removed.")
    else
        print("No Shop blip found to remove.")
    end
end)

RegisterNetEvent('custom:removeGunNpc')
AddEventHandler('custom:removeGunNpc', function()
    print("Removing Gun NPC...")
    if gunNpc and DoesEntityExist(gunNpc) then
        DeleteEntity(gunNpc)
        gunNpc = nil
        print("Gun NPC removed.")
    else
        print("No Gun NPC found to remove.")
    end

    if gunBlip and DoesBlipExist(gunBlip) then
        RemoveBlip(gunBlip)
        gunBlip = nil
        print("Gun blip removed.")
    else
        print("No Gun blip found to remove.")
    end
end)

-- Server event to deduct money
RegisterNetEvent('custom:deductMoney')
AddEventHandler('custom:deductMoney', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeMoney(amount)
end)

-- Reveal the NPCs
RegisterNetEvent('custom:revealShopNpc')
AddEventHandler('custom:revealShopNpc', function()
    print("Revealing Plug NPC") -- Debug message
    TriggerServerEvent('custom:spawnShopNpc', plugInJail)
end)

RegisterNetEvent('custom:revealGunNpc')
AddEventHandler('custom:revealGunNpc', function()
    print("Revealing Gun NPC") -- Debug message
    TriggerServerEvent('custom:spawnGunNpc', gunInJail)
end)

-- Event to reset the NPCs after bail is paid
RegisterNetEvent('custom:resetNpcAndMiddleMan')
AddEventHandler('custom:resetNpcAndMiddleMan', function()
    print("Resetting NPCs and Middle Man...")
    plugInJail = false
    gunInJail = false
    playerPurchaseCounts = {} -- Reset purchase counts for all players
    hasPurchasedWaypoint = false
    TriggerServerEvent('custom:setNpcInJail', false, "plug") -- Ensure state reset across clients
    TriggerServerEvent('custom:setNpcInJail', false, "gun") -- Ensure state reset across clients
    TriggerServerEvent('custom:spawnWaypointNpc')
    TriggerEvent('custom:removeCopNpc') -- Remove the Cop NPC after bail is paid
    TriggerEvent('custom:removeShopNpc') -- Ensure the jailed NPC is removed
    TriggerEvent('custom:removeGunNpc') -- Ensure the jailed NPC is removed
    resetScriptState() -- Reset the script state to start from the beginning
    print("NPCs and Middle Man reset complete.")
end)
