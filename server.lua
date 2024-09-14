ESX = nil
Config = Config or {}
local playerPurchaseCounts = {} -- Initialize playerPurchaseCounts as an empty table

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

RegisterCommand('testRemoveShopNpc', function()
    print("Testing removal of Shop NPC...")
    -- Remove the Shop NPC and its blip
    TriggerEvent('custom:removeShopNpc')

    -- Optionally, reset any additional states if needed
    plugInJail = false
    currentShopLocation = selectRandomLocation(Config.ShopLocations)

    -- Simulate a restart by spawning the NPC again
    TriggerEvent('custom:spawnShopNpc', plugInJail)
end)

-- Function to notify clients to spawn the Waypoint NPC (Middle Man)
RegisterNetEvent('custom:spawnWaypointNpc')
AddEventHandler('custom:spawnWaypointNpc', function()
    print('Server: Spawning Waypoint NPC...')
    TriggerClientEvent('custom:clientSpawnWaypointNpc', -1)
end)

-- Function to notify clients to spawn the Shop NPC (Plug)
RegisterNetEvent('custom:spawnShopNpc')
AddEventHandler('custom:spawnShopNpc', function(plugInJail)
    print('Server: Spawning Shop NPC (Plug)... Jail status: ' .. tostring(plugInJail))
    TriggerClientEvent('custom:clientSpawnShopNpc', -1, plugInJail)
end)

-- Function to notify clients to spawn the Gun NPC
RegisterNetEvent('custom:spawnGunNpc')
AddEventHandler('custom:spawnGunNpc', function(gunInJail)
    print('Server: Spawning Gun NPC... Jail status: ' .. tostring(gunInJail))
    TriggerClientEvent('custom:clientSpawnGunNpc', -1, gunInJail)
end)

-- Handling Player Purchases
RegisterNetEvent('custom:buyItem')
AddEventHandler('custom:buyItem', function(item, price, npcType)
    local source = source  -- Always use the source variable as the player ID
    local xPlayer = ESX.GetPlayerFromId(source)

    print('Server: custom:buyItem event triggered')
    print('Server: Player attempting to buy item (' .. tostring(item) .. ') from NPC (' .. tostring(npcType) .. ') for $' .. tostring(price))

    -- Check if xPlayer is valid
    if not xPlayer then
        print('Server: Error - xPlayer is nil')
        return
    end

    -- Initialize purchase count for the player if it doesn't exist
    playerPurchaseCounts[source] = playerPurchaseCounts[source] or 0

    -- Increment the purchase count for the player
    playerPurchaseCounts[source] = playerPurchaseCounts[source] + 1

    -- Check if the player has enough money
    local playerMoney = xPlayer.getMoney()
    print('Server: Player has $' .. tostring(playerMoney) .. ', Item price is $' .. tostring(price))

    if playerMoney >= price then
        -- Remove the money and add the item
        xPlayer.removeMoney(price)
        local success = exports.ox_inventory:AddItem(source, item, 1)

        if success then
            print('Server: Item (' .. tostring(item) .. ') purchased successfully.')
            TriggerClientEvent('esx:showNotification', source, ('Success: You have purchased %s!'):format(item))

            -- Trigger the jail chance checks after purchase
            if npcType == 'plug' then
                TriggerEvent('custom:checkPlugJailChance', source, 'plug')
            elseif npcType == 'gun' then
                TriggerEvent('custom:checkGunJailChance', source, 'gun')
            end

        else
            print('Server: Failed to add item (' .. tostring(item) .. ') to inventory.')
            TriggerClientEvent('esx:showNotification', source, 'Error: Failed to add item to inventory! Please try again.')
        end
    else
        print('Server: Player does not have enough money to purchase item (' .. tostring(item) .. ').')
        TriggerClientEvent('esx:showNotification', source, ('Error: You do not have enough money to purchase %s!'):format(item))
    end
end)

-- Event to clean up jailed Plug NPC after bail
RegisterNetEvent('custom:cleanupJailedNpc')
AddEventHandler('custom:cleanupJailedNpc', function()
    print("Cleaning up jailed NPCs...")

    if plugInJail and shopNpc and DoesEntityExist(shopNpc) then
        DeleteEntity(shopNpc)
        shopNpc = nil
        plugInJail = false
        print("Plug NPC cleaned up and removed from jail.")
    else
        print("No jailed Plug NPC to clean up.")
    end

    if shopBlip and DoesBlipExist(shopBlip) then
        RemoveBlip(shopBlip)
        shopBlip = nil
        print("Plug NPC blip removed.")
    else
        print("No Plug NPC blip found to remove.")
    end
end)

-- Bail the NPC out of jail
RegisterNetEvent('custom:bailNpc')
AddEventHandler('custom:bailNpc', function(npcType)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bailAmount = Config.BailAmount

    if not npcType then
        print('Server: npcType is nil, cannot proceed with bail.')
        return
    end

    print('Server: Player attempting to bail out NPC (' .. npcType .. ') for $' .. bailAmount)

    -- Check if the player has enough money
    if xPlayer.getMoney() >= bailAmount then
        xPlayer.removeMoney(bailAmount)
        TriggerClientEvent('custom:resetNpcAndMiddleMan', -1)
        TriggerClientEvent('ZSX_UI:AddNotify', source, 'fa-solid fa-info-circle', 'Success', 'You have bailed out the NPC!', 5000)
    else
        TriggerClientEvent('ZSX_UI:AddNotify', source, 'fa-solid fa-times-circle', 'Error', 'You do not have enough money to bail out the NPC!', 5000)
    end
end)

-- Reset logic after bail payment or other triggers
RegisterNetEvent('custom:resetLogic')
AddEventHandler('custom:resetLogic', function(npcType)
    if not npcType then
        print("Server: npcType is nil, cannot reset logic.")
        return
    end

    print("Server: Reset logic triggered for NPC: " .. npcType)

    if npcType == "plug" then
        plugInJail = false
        TriggerClientEvent('custom:setNpcInJail', -1, false, "plug")
        TriggerEvent('custom:removeShopNpc') -- Remove the Plug NPC
        TriggerClientEvent('custom:revealShopNpc', -1, false) -- Don't reveal the shop NPC until Middle Man is interacted with
        print("Server: Shop NPC (Plug) logic reset.")
    elseif npcType == "gun" then
        gunInJail = false
        TriggerClientEvent('custom:setNpcInJail', -1, false, "gun")
        TriggerEvent('custom:removeGunNpc') -- Remove the Gun NPC
        TriggerClientEvent('custom:revealGunNpc', -1, false) -- Don't reveal the gun NPC until Middle Man is interacted with
        print("Server: Gun NPC logic reset.")
    end

    hasPurchasedWaypoint = false
    TriggerEvent('custom:removeCopNpc') -- Remove the Cop NPC after bail is paid
end)

-- Update server-side NPC jail state
RegisterNetEvent('custom:setNpcInJail')
AddEventHandler('custom:setNpcInJail', function(state, npcType)
    if not npcType then
        print("Server: npcType is nil, cannot set NPC Jail State.")
        return
    end

    print("Server: Setting NPC Jail State: " .. npcType .. " to " .. tostring(state))
    
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

-- Function to check the jail chance for the Plug NPC
RegisterNetEvent('custom:checkPlugJailChance')
AddEventHandler('custom:checkPlugJailChance', function(playerId, npcType)
    local purchaseCount = playerPurchaseCounts[playerId] or 0

    if not npcType then
        print("Server: npcType is nil, cannot check jail chance.")
        return
    end

    print("Server: Checking Plug NPC jail chance. Purchase count: " .. tostring(purchaseCount))
    if purchaseCount >= Config.PurchaseThreshold and not plugInJail then
        local jailChance = math.random(1, 100)
        print("Server: Jail chance roll for Plug NPC: " .. jailChance)
        if jailChance <= Config.JailChance then
            -- Send the NPC to jail if the chance meets the condition
            TriggerEvent('custom:sendPlugToJail', playerId, npcType)
        else
            print("Server: Plug NPC did not go to jail. Jail chance roll: " .. jailChance)
        end
    else
        print("Server: Jail chance not checked. Purchase count: " .. purchaseCount .. ", plugInJail: " .. tostring(plugInJail))
    end
end)

-- Function to check the jail chance for the Gun NPC
RegisterNetEvent('custom:checkGunJailChance')
AddEventHandler('custom:checkGunJailChance', function(playerId, npcType)
    local purchaseCount = playerPurchaseCounts[playerId] or 0

    if not npcType then
        print("Server: npcType is nil, cannot check jail chance.")
        return
    end

    print("Server: Checking Gun NPC jail chance. Purchase count: " .. tostring(purchaseCount))
    if purchaseCount >= Config.PurchaseThreshold and not gunInJail then
        local jailChance = math.random(1, 100)
        print("Server: Jail chance roll for Gun NPC: " .. jailChance)
        if jailChance <= Config.JailChance then
            -- Send the NPC to jail if the chance meets the condition
            TriggerEvent('custom:sendGunToJail', playerId, npcType)
        else
            print("Server: Gun NPC did not go to jail. Jail chance roll: " .. jailChance)
        end
    else
        print("Server: Jail chance not checked. Purchase count: " .. purchaseCount .. ", gunInJail: " .. tostring(gunInJail))
    end
end)

RegisterNetEvent('custom:sendPlugToJail')
AddEventHandler('custom:sendPlugToJail', function(playerId, npcType)
    if not npcType then
        print("Server: npcType is nil, cannot send NPC to jail.")
        return
    end

    if not plugInJail then
        plugInJail = true
        print("Server: Sending Plug NPC to jail...")

        -- Remove the Plug NPC and its blip
        TriggerEvent('custom:removeShopNpc') -- Custom event to remove the Plug NPC and blip from the shop
        
        -- Reset the purchase count for the player after sending NPC to jail
        playerPurchaseCounts[playerId] = 0

        -- Notify clients and respawn the Plug NPC in jail
        TriggerClientEvent('custom:setNpcInJail', -1, true, npcType) -- Synchronize jail state across clients
        TriggerClientEvent('custom:clientSpawnShopNpc', -1, plugInJail) -- Respawn Plug NPC in jail
        TriggerClientEvent('custom:spawnCopNpc', -1) -- Spawn the Cop NPC for bail payments
        
        -- Notify the player
        TriggerClientEvent('esx:showNotification', playerId, 'The Plug has been sent to jail!')
    else
        print("Server: Plug NPC is already in jail.")
    end
end)

RegisterNetEvent('custom:sendGunToJail')
AddEventHandler('custom:sendGunToJail', function(playerId, npcType)
    if not npcType then
        print("Server: npcType is nil, cannot send NPC to jail.")
        return
    end

    if not gunInJail then
        gunInJail = true
        print("Server: Sending Gun NPC to jail...")

        -- Remove the NPC and its blip
        TriggerEvent('custom:removeGunNpc') -- Custom event to remove the NPC and blip from the gun shop
        
        -- Reset the purchase count for the player after sending NPC to jail
        playerPurchaseCounts[playerId] = 0

        -- Notify clients and respawn the NPC in jail
        TriggerClientEvent('custom:setNpcInJail', -1, true, npcType) -- Synchronize jail state across clients
        TriggerClientEvent('custom:clientSpawnGunNpc', -1, gunInJail) -- Respawn NPC in jail
        TriggerClientEvent('custom:spawnCopNpc', -1) -- Spawn the Cop NPC for bail payments
        
        -- Notify the player
        TriggerClientEvent('esx:showNotification', playerId, 'The Gun Dealer has been sent to jail!')
    else
        print("Server: Gun NPC is already in jail.")
    end
end)

-- Client-side event to remove the Plug blip and NPC
RegisterNetEvent('custom:removePlugBlipAndNpc')
AddEventHandler('custom:removePlugBlipAndNpc', function()
    if shopBlip and DoesBlipExist(shopBlip) then
        RemoveBlip(shopBlip)
        shopBlip = nil
        print("Client: Removed Plug blip.")
    end

    if shopNpc and DoesEntityExist(shopNpc) then
        DeleteEntity(shopNpc)
        shopNpc = nil
        print("Client: Removed Plug NPC.")
    end
end)

-- Server-side event to handle police alerts
RegisterNetEvent('custom:sendPoliceAlert')
AddEventHandler('custom:sendPoliceAlert', function(coords, streetName)
    print("Server: Sending police alert for suspicious activity at " .. streetName)
    TriggerClientEvent('cd_dispatch:AddNotification', -1, {
        job_table = {'police'}, 
        coords = coords,
        title = '10-15 - Suspicious Activity',
        message = 'A suspicious individual is conducting illegal activities at ' .. streetName, 
        flash = 0,
        sound = 1,
        blip = {
            sprite = 431, 
            scale = 1.2, 
            colour = 3,
            flashes = false, 
            text = '911 - Suspicious Activity',
            time = 5,
            radius = 0,
        }
    })
end)
